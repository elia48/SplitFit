class TrainingsController < ApplicationController
  before_action :set_training, only: %i[show edit update]

  def index
    @trainings = policy_scope(Training)
  end

  def show
    authorize @training
    @coach = @training.user
  end

  def new
    @training = Training.new
    authorize @training
  end

  def create
    @training = Training.new(training_params)
    @training.user = current_user
    authorize @training
    if @training.save
      redirect_to @training, notice: "Training created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @training
  end

  def update
    authorize @training
    if @training.update(training_params)
      redirect_to @training, notice: "Training updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_training
    @training = Training.find(params[:id])
  end

  def training_params
    params.require(:training).permit(
      :coach_price, :duration, :date, :place, :workout_type, :min_people, :max_people, :status
    )
  end
end
