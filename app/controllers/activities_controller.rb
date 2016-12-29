class ActivitiesController < ApplicationController
  before_filter :set_activity, only: [:update, :edit, :show, :destroy]

  def index
    @activities = Activity.all
  end

  def show
  end

  def new
    @activity = Activity.new
  end

  def edit
  end

  def create
    @activity = Activity.new(params[:activity])

    if @activity.save
      redirect_to @activity, notice: 'Activity was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @activity.update_attributes(params[:activity])
      redirect_to @activity, notice: 'Activity was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @activity.destroy
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  end
end
