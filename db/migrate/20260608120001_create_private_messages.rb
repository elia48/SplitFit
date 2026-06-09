class CreatePrivateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :private_messages do |t|
      t.references :private_chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end
  end
end
