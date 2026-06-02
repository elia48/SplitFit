class CreateTrainings < ActiveRecord::Migration[8.1]
  def change
    create_table :trainings do |t|
      t.integer :coach_price
      t.integer :duration
      t.datetime :date
      t.string :place
      t.string :workout_type
      t.integer :min_people
      t.integer :max_people
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
