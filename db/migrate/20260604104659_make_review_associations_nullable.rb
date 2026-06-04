class MakeReviewAssociationsNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :reviews, :user_id, true
    change_column_null :reviews, :training_id, true
  end
end
