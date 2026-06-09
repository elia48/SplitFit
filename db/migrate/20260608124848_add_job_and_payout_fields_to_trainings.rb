class AddJobAndPayoutFieldsToTrainings < ActiveRecord::Migration[8.1]
  def change
    add_column :trainings, :close_job_id, :string
    add_column :trainings, :coach_payout_id, :string
  end
end
