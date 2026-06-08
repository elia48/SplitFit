class CreatePrivateChats < ActiveRecord::Migration[8.1]
  def change
    create_table :private_chats do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :private_chats, [:sender_id, :recipient_id], unique: true
  end
end
