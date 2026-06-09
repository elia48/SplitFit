class CoachPayoutService
  def initialize(training)
    @training = training
  end

  def call
    return if @training.coach_payout_id.present?

    coach = @training.user
    unless coach.stripe_account_id.present?
      Rails.logger.warn "[CoachPayoutService] Coach #{coach.id} has no Stripe account for training #{@training.id}"
      return
    end

    payout_amount = @training.coach_price_cents
    return unless payout_amount.to_i.positive?

    transfer = Stripe::Transfer.create(
      amount: payout_amount,
      currency: "eur",
      destination: coach.stripe_account_id,
      description: "Payout for training ##{@training.id}"
    )
    Rails.logger.info "[CoachPayoutService] Transfer #{transfer.id} issued for training #{@training.id}"

    @training.update_column(:coach_payout_id, transfer.id)
  end
end
