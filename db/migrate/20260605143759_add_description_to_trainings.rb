class AddDescriptionToTrainings < ActiveRecord::Migration[8.1]
  def change
    add_column :trainings, :description, :text
  end
end
