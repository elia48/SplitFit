class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]

  def show
    authorize @user

    @own_profile = current_user == @user

    if @user.is_coach?
      @trainings      = @user.trainings.where.not(status: "closed").where("date > ?", Time.current)
      @past_trainings = @user.trainings.where("date <= ?", Time.current).order(date: :desc)
    else
      now = Time.current
      @confirmed_bookings = @user.bookings.joins(:training)
                                 .where(status: "confirmed")
                                 .where("trainings.date > ?", now)
                                 .includes(:training)
      @pending_bookings   = @user.bookings.joins(:training)
                                 .where(status: "pending")
                                 .where("trainings.date > ?", now)
                                 .includes(:training)
      @past_bookings      = @user.bookings.joins(:training)
                                 .where("trainings.date <= ?", now)
                                 .includes(:training)
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
      :score,
      :address,
      :payment_method
    )
  end
end
