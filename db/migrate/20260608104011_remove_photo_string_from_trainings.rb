class RemovePhotoStringFromTrainings < ActiveRecord::Migration[8.1]
  def change
    remove_column :trainings, :photo, :string
  end
end
