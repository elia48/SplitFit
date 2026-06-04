class AddCoachProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :speciality, :string
    add_column :users, :description, :text
    add_column :users, :score, :float, default: 0
    add_column :users, :address, :string
    add_column :users, :payment_method, :string
  end
end
