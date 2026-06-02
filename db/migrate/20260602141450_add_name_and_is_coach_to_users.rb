class AddNameAndIsCoachToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :is_coach, :boolean, default: false, null: false
  end
end
