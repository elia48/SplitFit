class CloseTrainingJob < ApplicationJob
  queue_as :default

  def perform(training_id)
    training = Training.find_by(id: training_id)
    return unless training
    return unless training.status == "open"
    return if Time.current < training.date + training.duration.minutes

    TrainingRefundService.new(training).call
    CoachPayoutService.new(training).call
    training.update!(status: "closed")
  rescue Stripe::StripeError => e
    Rails.logger.error "[CloseTrainingJob] Stripe error for training #{training_id}: #{e.message}"
    raise
  end
end
