class StripeCheckoutSessionService
  def call(event)
    Rails.logger.info "STRIPE SERVICE CALLED"

    session = event.data.object
    booking = Booking.find_by(checkout_session_id: session.id)

    Rails.logger.info "BOOKING FOUND: #{booking&.id}"

    booking.update!(
      status: "paid",
      payment_intent_id: session.payment_intent
    )
  end
end
