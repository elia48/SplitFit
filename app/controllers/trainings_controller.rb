class TrainingsController < ApplicationController
  before_action :set_training, only: %i[show edit update cancel publish close]
  def index
    @trainings = policy_scope(Training).where(status: %w[open full])
    @markers = @trainings.geocoded.map do |training|
      {
        lat: training.latitude,
        lng: training.longitude,
        info_window_html: render_to_string(
          partial: "info_window",
          locals: { training: training }
        )
      }
    end

    if params[:query].present?
    @trainings = @trainings.where(
      "workout_type ILIKE :query OR place ILIKE :query",
      query: "%#{params[:query]}%"
    )
    end

    if params[:location].present?
      @trainings = @trainings.near(
        params[:location],
        params[:distance].presence || 5
      )
    end

    if params[:within_hours].present?
      @trainings = @trainings.where(
        date: Time.current..params[:within_hours].to_i.hours.from_now
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

    booked_scope = @trainings.unscope(:select, :order).select(:id)
    @my_booked_training_ids = current_user.bookings.where(training_id: booked_scope).pluck(:training_id).to_set
    @trainings = @trainings.includes(:bookings, :photo_attachment, user: %i[received_reviews avatar_attachment])
  end

  def show
    authorize @training
    @coach = @training.user
    @review = Review.new(
      training: @training,
      user: current_user,
      coach: @training.user
    )
    @markers = [
      {
        lat: @training.latitude,
        lng: @training.longitude,
        info_window_html: render_to_string(
          partial: "info_window",
          locals: { training: @training }
        )
      }
    ]
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
    if @training.update(update_params)
      redirect_to @training, notice: "Training updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    authorize @training

    TrainingCancellationService.new(@training).call
    SolidQueue::Job.find_by(active_job_id: @training.close_job_id)&.destroy if @training.close_job_id.present?
    @training.update!(status: "cancelled")

    redirect_to @training, notice: "Session cancelled and all members fully refunded."
  rescue Stripe::StripeError => e
    redirect_to @training, alert: "Stripe error: #{e.message}"
  end

  def publish
    authorize @training
    @training.update!(status: "open")
    redirect_to user_path(current_user), notice: "Session published! It's now visible to clients."
  end

  def close
    authorize @training

    TrainingRefundService.new(@training).call
    CoachPayoutService.new(@training).call
    @training.update!(status: "closed")

    redirect_to @training, notice: "Session closed, refunds and payout processed."
  rescue Stripe::StripeError => e
    redirect_to @training, alert: "Stripe error: #{e.message}"
  end

  # AI filling assistant
  def ai_fill
    authorize Training

    result = TrainingAiParserService.new(params[:prompt]).call

    render json: result
  rescue JSON::ParserError
    render json: { error: "AI response could not be parsed." }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_training
    @training = Training.find(params[:id])
  end

  def training_params
    params.require(:training).permit(
      :duration, :date, :place, :workout_type, :min_people, :max_people, :status, :photo, :description
    )
  end

  def update_params
    params.require(:training).permit(:date, :place, :duration)
  end

  def price_in_cents
    (params.dig(:training, :price).to_f * 100).to_i
  end
end
