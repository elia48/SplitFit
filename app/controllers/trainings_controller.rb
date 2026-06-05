class TrainingsController < ApplicationController
  before_action :set_training, only: %i[show edit update cancel reopen publish]

  def index
    @trainings = policy_scope(Training)

    if params[:query].present?
    @trainings = @trainings.where(
      "workout_type ILIKE :query OR place ILIKE :query",
      query: "%#{params[:query]}%"
    )
    end

    if params[:location].present?
    @trainings = @trainings.where(
      "place ILIKE :location",
      location: "%#{params[:location]}%"
    )
    end

    if params[:workout_type].present?
    @trainings = @trainings.where(workout_type: params[:workout_type])
    end

    if params[:min_price].present?
    @trainings = @trainings.where("coach_price_cents >= ?", params[:min_price].to_i * 100)
    end

    if params[:max_price].present?
    @trainings = @trainings.where("coach_price_cents <= ?", params[:max_price].to_i * 100)
    end
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
    @training.coach_price_cents = price_in_cents
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
    @training.coach_price_cents = price_in_cents
    if @training.update(training_params)
      redirect_to @training, notice: "Training updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    authorize @training
    @training.update!(status: "cancelled")
    redirect_to @training, notice: "Session cancelled."
  end

  def reopen
    authorize @training
    @training.update!(status: "open")
    redirect_to @training, notice: "Session reopened."
  end

  def publish
    authorize @training
    @training.update!(status: "open")
    redirect_to user_path(current_user), notice: "Session published! It's now visible to clients."
  end

  private

  def set_training
    @training = Training.find(params[:id])
  end

  def training_params
    params.require(:training).permit(
      :duration, :date, :place, :workout_type, :min_people, :max_people, :status, :photo
    )
  end

  def price_in_cents
    (params.dig(:training, :price).to_f * 100).to_i
  end
end
