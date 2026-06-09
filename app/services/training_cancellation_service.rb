class TrainingCancellationService
  def initialize(training)
    @training = training
  end

  def call
    @training.bookings.paid.each do |booking|
      next if booking.payment_intent_id.blank?
      next if booking.refunded_cents.to_i.positive?

      Stripe::Refund.create(
        payment_intent: booking.payment_intent_id,
        amount: booking.amount_cents
      )
      Rails.logger.info "[CancellationService] Full refund issued for booking #{booking.id}"

      booking.update!(
        final_amount_cents: 0,
        refunded_cents: booking.amount_cents,
        status: "refunded"
      )
    end
  end
end
