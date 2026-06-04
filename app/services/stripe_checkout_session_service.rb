class StripeCheckoutSessionService
  def call(event)
    session = event.data.object
    booking = Booking.find_by(checkout_session_id: session.id)

    booking.update!(
      status: "paid",
      payment_intent_id: session.payment_intent
    )
  end
end
