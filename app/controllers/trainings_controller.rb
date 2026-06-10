class TrainingsController < ApplicationController
  before_action :set_training, only: %i[show edit update cancel publish close]
  def index
    @trainings = policy_scope(Training).where(status: %w[open full]).where("date > ?", Time.current)
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

    types = Array(params[:workout_type]).reject(&:blank?)
    query = params[:query].presence

    if types.any? && query
      @trainings = @trainings.where(
        "workout_type IN (:types) OR workout_type ILIKE :q OR place ILIKE :q",
        types: types, q: "%#{query}%"
      )
    elsif types.any?
      @trainings = @trainings.where(workout_type: types)
    elsif query
      @trainings = @trainings.where(
        "workout_type ILIKE :q OR place ILIKE :q", q: "%#{query}%"
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

    price_per_person_sql = <<~SQL
      coach_price_cents / GREATEST(
        (SELECT COUNT(*) FROM bookings b
         WHERE b.training_id = trainings.id AND b.status = 'paid') + 1,
        min_people
      )
    SQL

    if params[:min_price].present?
      @trainings = @trainings.where("(#{price_per_person_sql}) >= ?", params[:min_price].to_i * 100)
    end

    if params[:max_price].present?
      @trainings = @trainings.where("(#{price_per_person_sql}) <= ?", params[:max_price].to_i * 100)
    end

    if params[:time_of_day].present?
      case params[:time_of_day]
      when "morning"
        @trainings = @trainings.where("EXTRACT(HOUR FROM date) >= 6 AND EXTRACT(HOUR FROM date) < 12")
      when "afternoon"
        @trainings = @trainings.where("EXTRACT(HOUR FROM date) >= 12 AND EXTRACT(HOUR FROM date) < 18")
      when "evening"
        @trainings = @trainings.where("EXTRACT(HOUR FROM date) >= 18")
      end
    end

    if params[:duration].present?
      @trainings = @trainings.where(duration: params[:duration].to_i)
    end

    if params[:group_size].present?
      case params[:group_size]
      when "duo"
        @trainings = @trainings.where(max_people: 2)
      when "small"
        @trainings = @trainings.where("max_people BETWEEN 3 AND 5")
      when "medium"
        @trainings = @trainings.where("max_people BETWEEN 6 AND 10")
      when "large"
        @trainings = @trainings.where("max_people >= 11")
      end
    end

    if params[:min_rating].present?
      min = params[:min_rating].to_f
      ids = @trainings.joins(user: :received_reviews)
                      .group("trainings.id")
                      .having("AVG(reviews.score) >= ?", min)
                      .pluck("trainings.id")
      @trainings = @trainings.where(id: ids)
    end

    booked_scope = @trainings.unscope(:select, :order).select(:id)
    @my_booked_training_ids = current_user.bookings.where(training_id: booked_scope).pluck(:training_id).to_set
    @trainings = @trainings.includes(:bookings, :photo_attachment, user: %i[received_reviews avatar_attachment])
  end

  def show
    authorize @training
    @coach = @training.user
    @pending_booking = current_user.bookings.pending.find_by(training: @training)
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
      redirect_to trainings_path, notice: "Training created."
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
