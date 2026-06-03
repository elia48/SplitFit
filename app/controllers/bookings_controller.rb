class BookingsController < ApplicationController
  before_action :set_booking, only: [:destroy]

  def create
    @training = Training.find(params[:training_id])
    @booking = Booking.new(training: @training, user: current_user, status: "pending")
    authorize @booking
    if @booking.save
      redirect_to training_path(@training), notice: "Booking confirmed!"
    else
      redirect_to training_path(@training), alert: "Could not complete booking."
    end
  end

  def index
    @bookings = policy_scope(Booking)
  end

  def destroy
    authorize @booking
    @booking.destroy
    redirect_to bookings_path, notice: "Booking cancelled."
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
