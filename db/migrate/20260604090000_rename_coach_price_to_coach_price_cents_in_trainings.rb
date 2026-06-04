class RenameCoachPriceToCoachPriceCentsInTrainings < ActiveRecord::Migration[8.0]
  def change
    rename_column :trainings, :coach_price, :coach_price_cents
  end
end
