class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update]

  def show
    authorize @user

    @own_profile = current_user == @user

    if @user.is_coach?
      training_includes = [:photo_attachment, user: :avatar_attachment]
      @recent_reviews  = @user.received_reviews.order(created_at: :desc).limit(5).includes(:user)
      @draft_trainings = @own_profile ? @user.trainings.where(status: "draft").includes(training_includes) : []
      @trainings       = @user.trainings.where.not(status: %w[closed cancelled draft]).where("date > ?", Time.current).includes(training_includes)
      @past_trainings  = @own_profile ? @user.trainings.where("date <= ?", Time.current).where.not(status: "draft").order(date: :desc).includes(training_includes) : []
    else
      now = Time.current
      booking_includes = { training: [:photo_attachment, user: :avatar_attachment] }
      @confirmed_bookings = @own_profile ? @user.bookings.joins(:training).where(status: "confirmed").where("trainings.date > ?", now).includes(booking_includes) : []
      @pending_bookings   = @own_profile ? @user.bookings.joins(:training).where(status: "pending").where("trainings.date > ?", now).includes(booking_includes) : []
      @past_bookings      = @own_profile ? @user.bookings.joins(:training).where("trainings.date <= ?", now).includes(booking_includes) : []
    end
  end

  def edit
    @user = current_user
    authorize @user
  end

  def update
    @user = current_user
    authorize @user

    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :name,
      :speciality,
      :description,
      :address,
      :payment_method,
      :avatar
    )
  end
end
