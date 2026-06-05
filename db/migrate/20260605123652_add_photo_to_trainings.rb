class AddPhotoToTrainings < ActiveRecord::Migration[8.1]
  def change
    add_column :trainings, :photo, :string
  end
end
