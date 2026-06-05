class TrainingRefundService
  def initialize(training)
    @training = training
  end

  def call
    final_price = @training.final_price_cents
    paid_count = @training.bookings.paid.count
    Rails.logger.info "[RefundService] Training #{@training.id}: final_price=#{final_price}, paid=#{paid_count}"

    @training.bookings.paid.each do |booking|
      next if booking.payment_intent_id.blank?
      next if booking.refunded_cents.to_i.positive?

      refund_amount = booking.amount_cents - final_price
      Rails.logger.info "[RefundService] Booking #{booking.id}: amount=#{booking.amount_cents}, refund=#{refund_amount}"
      next unless refund_amount.positive?

      Stripe::Refund.create(
        payment_intent: booking.payment_intent_id,
        amount: refund_amount
      )
      Rails.logger.info "[RefundService] Stripe refund issued for booking #{booking.id}"

      booking.update!(
        final_amount_cents: final_price,
        refunded_cents: refund_amount,
        status: "refunded"
      )
    end
  end
end
