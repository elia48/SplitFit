class AddCoordinatesToTrainings < ActiveRecord::Migration[8.1]
  def change
    add_column :trainings, :latitude, :float
    add_column :trainings, :longitude, :float
  end
end
