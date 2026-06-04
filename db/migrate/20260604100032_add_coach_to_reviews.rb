class AddCoachToReviews < ActiveRecord::Migration[8.1]
  def change
    add_reference :reviews, :coach, foreign_key: { to_table: :users }
  end
end
