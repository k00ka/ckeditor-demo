class ActivityDefinitionsController < ApplicationController
  before_action :set_definition, only: [:edit, :show, :destroy]

  def index
    @activity_definitions = ActivityDefinition.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @activity_definition = ActivityDefinition.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
  end

  def create
    @activity_definition = ActivityDefinition.new(params[:activity_definition])

    respond_to do |format|
      if @activity_definition.save
        format.html { redirect_to @activity_definition, notice: 'Activity definition was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @activity_definition.update_attributes(params[:activity_definition])
        format.html { redirect_to @activity_definition, notice: 'Activity definition was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @activity_definition.destroy

    respond_to do |format|
      format.html { redirect_to activity_definitions_url }
      format.json { head :no_content }
    end
  end

  private

  def set_definition
    @activity_definition = ActivityDefinition.find(params[:id])
  end
end
