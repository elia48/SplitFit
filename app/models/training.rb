class Training < ApplicationRecord
  belongs_to :user
  has_one_attached :photo
  has_many :bookings, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :participants, through: :bookings, source: :user
  has_many :reviews, dependent: :nullify
  validates :coach_price_cents, :duration, :date, :place, :workout_type, :status, :min_people, :max_people,
            presence: true
  validates :min_people, numericality: { greater_than_or_equal_to: 2 }

  geocoded_by :place
  after_validation :geocode, if: :will_save_change_to_place?

  after_commit :schedule_close_job, if: :should_reschedule_close?

  def current_price_cents
    people_count = bookings.paid.count + 1
    divisor = [people_count, min_people].max

    coach_price_cents / divisor
  end

  def final_price_cents
    paid_count = bookings.paid.count
    divisor = [paid_count, min_people].max

    coach_price_cents / divisor
  end

  private

  def should_reschedule_close?
    status == "open" &&
      date.present? && duration.present? &&
      (saved_changes.keys & %w[status date duration]).any?
  end

  def schedule_close_job
    SolidQueue::Job.find_by(active_job_id: close_job_id)&.destroy if close_job_id.present?

    run_at = date + duration.minutes
    job = CloseTrainingJob.set(wait_until: run_at).perform_later(id)
    update_column(:close_job_id, job.job_id)
  end
end
