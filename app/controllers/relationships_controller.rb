class RelationshipsController < ApplicationController
  respond_to :html, :js

  skip_filter :check_pending_invitations, only: :update
  before_filter :authorize_gmail_calendar, :only => [:show] unless Rails.env.development?
  
  def index
    authorize! :manage, @user
    @mentor_relationships = Relationship.where_mentee_is(@user).ongoing
    @mentee_relationships = Relationship.where_mentor_is(@user).ongoing
    @relationships_completed = current_user.relationships_completed
  end

  def show
    session[:busy_times] = nil
    @relationship = Relationship.includes(:mentor, :mentee, :request).find(params[:id])
    authorize! :manage, @relationship
    @mentee = @relationship.mentee
    @mentor = @relationship.mentor
    @request = @relationship.request
    @final_evaluation = @relationship.end_evaluations.find_by_user_id(current_user)
    @organization = @mentee.organization

    if @request.goals.empty?
      @request.goals.build
    end


    #TODO: put this somewhere else
    if view_context.show_activities # are activities turned on for this organization?
      @level = 0.0
      ad_query = ActionDefinition.where(organization_id: @organization.id)
      ad_query = ad_query.mentor_visible if (@user == @mentor)
      @ad = ad_query.where(level: params[:level]).first if params[:level]
      unless @ad
        level = Action.joins(:action_definition).where(relationship_id: @relationship.id).maximum(:level) || @level
        @ad = ad_query.where("level > #{level}").order(:level).first
      end
      if @ad
        @level = @ad.level
        @action = Action.where(action_definition_id: @ad.id, relationship_id: @relationship.id).first_or_initialize
        @context = "level=#{@level}"
      end
    end
    if current_user == @mentee
      @relationship_partner = @mentor
    else
      @relationship_partner = @mentee
    end
    get_events_of(@relationship_partner)


    SystemMessage.trash(@relationship.mentee, :relationship_id => @relationship) if current_user == @relationship.mentee
    SystemMessage.trash(@relationship.mentor, :relationship_id => @relationship) if current_user == @relationship.mentor
    @current_user_role_name = I18n.with_locale(:en) { @relationship.role_name_of(current_user) }
  end

  def new
    @customFields = current_organization.custom_fields.where("show_in_profile = true")
    @request = current_user.requests.find(params[:request_id])

    if @request.relationship
      relationship = @request.relationship
      redirect_to relationship_url(relationship), alert: t('controllers.relationships.invitation_sent')
    else
      @mentor = current_organization.users.find(params[:user_id])
      @relationship = @request.build_relationship
      authorize! :create, @relationship
    end
  end

  def create
    @request = current_user.requests.find(params[:request_id])

    if @request.relationship
      relationship = @request.relationship
      redirect_to relationship_url(relationship), alert: t('controllers.relationships.invitation_sent')
    else
      @mentor = current_organization.users.find(params[:mentor])
      @mentee = current_user
      @relationship = @request.build_relationship(params[:relationship])
      @relationship.assign_attributes(mentor: @mentor, mentee: @mentee, status: 'invited')
      authorize! :create, @relationship

      if @relationship.save
        @relationship.create_activity :update, owner: current_user, recipient: current_organization,
          key: "relationship.admin.create", parameters: { status: @relationship.status }
        @relationship.create_activity :update, owner: current_user, recipient: @mentor,
          key: "relationship.user.update", parameters: { status: @relationship.status }

        redirect_to @relationship, notice: t('controllers.relationships.invitation_begin', mentor: @relationship.mentor)
      else
        raise "There was a problem trying to create a relationship between #{@mentor} & #{@mentee}. Request: #{@request.id}"
      end
    end
  end

  def update
    @user = current_user
    @relationship = current_user.relationships.find(params[:id])
    request = @relationship.request
    status_before = @relationship.status

    # If the relationship is completed, do nothing.
    if @relationship.completed?
      return
    end

    if request.present?
      previous_status = @relationship.status

      if @relationship.update_attributes(params[:relationship])
        @relationship.create_updated_notifications(current_user, current_organization)

        # We don't render the relationship if it's declined.
        if @relationship.declined?
          redirect_to dashboard_path, notice: t('controllers.relationships.declined', role_partner: request.role_partner)
        else
          current_user.points_relationship_accepted(@relationship, previous_status)
          redirect_to relationship_url(@relationship), notice: t('controllers.relationships.updated')
        end
      else
        raise "There was an error trying to update a relationship. Relationship: #{@relationship}"
      end
    end
  end

  def user_management
    if current_account.role == "admin"
      @users = User.order('first_name DESC').page(params[:page]).per(1000)
    else
      redirect_to dashboard_url
    end
  end

  def status_toggle
    # This functionality is used in the organizationn dashboard as well.
    # That's why this redirect control is necessary.
    if params[:organization] && params[:members_ids] && params[:checked]

      # Set the corresponding lists.
      members_ids = params[:members_ids].split(",")
      checked = params[:checked].split(",")

      # For each id, find the member and check if the status has changed.
      members_ids.each_with_index do |member_id, index|
        member = User.find(member_id)
        # If the member status has changed, set the new status and save.
        if checked[index] != member.is_active.to_s
          member.is_active = checked[index]
          member.save!(validate: false)
        end
      end

      redirect_to members_organization_path(Organization.find(params[:organization]))
    else
      # Admin activation view.
      @user = User.where(:id => params[:users]).first
      @user.is_active ? @user.is_active = false : @user.is_active = true
      @user.save(:validate => false)
      redirect_to usermanagement_path
    end
  end

  def complete_relationship
    @relationship = Relationship.find(params[:relationship_id])
    authorize! :update, @relationship

    @relationship.update_attribute(:status, "completed")

    message = if current_user == @relationship.mentor || current_user == @relationship.mentee
      t "controllers.relationships.completed_user", partner: @relationship.partner_of(current_user)
    else
      t "controllers.relationships.completed_admin", mentor: @relationship.mentor, mentee: @relationship.mentee
    end

    redirect_to dashboard_url, notice: message
  end

private

  def google_client(calendar_user)
    client = Google::APIClient.new(application_name: 'Service account demo', application_version: '0.0.1')
    client.authorization.access_token = calendar_user.access_token
    client.authorization.refresh_token = calendar_user.refresh_token
    client.authorization.client_id = '182992951662-j76mpmkpq54d2luofkf2afee9k09u0d0.apps.googleusercontent.com'
    client.authorization.client_secret = 'M9HYe2GPHVNjMP2GR8tni5_z'
    client.authorization.refresh!
    service = client.discovered_api('calendar', 'v3')
    return client, service
  end

  
  #get free busy time slots of user
  def get_events_of(calendar_user)
    if !calendar_user.refresh_token.present?
      return
    end

    @calendar_user = calendar_user
    client, service = google_client(calendar_user)
    response_json = client.execute(
      :api_method => service.freebusy.query,
      :body => JSON.dump({
          :timeMin => Time.now.beginning_of_week,
          :timeMax => Time.now.end_of_week,
          :items => [{'id' => calendar_user.calendar.primary_calendar_id}]
        }),
      :headers => {'Content-Type' => 'application/json'})
    @busy_times_array = response_json.data.calendars[calendar_user.calendar.primary_calendar_id].busy
    calendar_user.calendar.update_attribute(:busy_times, @busy_times_array)
    session[:busy_times] = @busy_times_array
  end
end
