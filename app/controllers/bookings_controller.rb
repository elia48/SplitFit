class BookingsController < ApplicationController
  before_action :set_booking, only: [:destroy]
  def create
    @training = Training.find(params[:training_id])
    @training.close_if_due!

    if @training.status == "closed"
      return redirect_to training_path(@training), alert: "This session is no longer accepting bookings."
    end

    existing_pending = current_user.bookings.pending.find_by(training: @training)
    if existing_pending
      return redirect_to new_booking_payment_path(existing_pending),
                         notice: "You already have a pending booking — complete your payment to confirm it."
    end

    @booking = Booking.new(training: @training, user: current_user, status: "pending",
                           amount_cents: @training.current_price_cents, 
                           estimated_people_count_at_payment: @training.bookings.paid.count + 1)
    authorize @booking
    if @booking.save
      session = Stripe::Checkout::Session.create(
        payment_method_types: ["card"],
        line_items: [{
          quantity: 1,
          price_data: {
            unit_amount: @booking.amount_cents,
            currency: "eur",
            product_data: {
              name: @training.workout_type
            }
          }
        }],
        mode: "payment",
        success_url: booking_url(@booking),
        cancel_url: training_url(@training),
        metadata: {
          booking_id: @booking.id
        },
        payment_intent_data: {
          metadata: {
            booking_id: @booking.id
          }
        }
      )

      @booking.update!(checkout_session_id: session.id)

      redirect_to new_booking_payment_path(@booking)
    else
      redirect_to training_path(@training), alert: "Could not complete booking."
    end
  end

  def show
    @booking = current_user.bookings.find(params[:id])
    authorize @booking
  end

  def index
    @bookings = policy_scope(Booking).includes(training: [:photo_attachment, user: :avatar_attachment])
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
