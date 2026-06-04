class PaymentsController < ApplicationController
  def new
    @booking = current_user.bookings.pending.find(params[:booking_id])
    authorize @booking
  end
end
