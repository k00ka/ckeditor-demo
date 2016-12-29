class ActivityDefinitionsController < ApplicationController
  before_filter :set_definition, only: [:update, :edit, :show, :destroy]

  def index
    @activity_definitions = ActivityDefinition.all
  end

  def show
  end

  def new
    @activity_definition = ActivityDefinition.new
  end

  def edit
  end

  def create
    @activity_definition = ActivityDefinition.new(params[:activity_definition])

    if @activity_definition.save
      redirect_to @activity_definition, notice: 'Activity definition was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @activity_definition.update_attributes(params[:activity_definition])
      redirect_to @activity_definition, notice: 'Activity definition was successfully updated.'
    else
      render action: "edit"
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
