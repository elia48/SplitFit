class AddPaymentFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :amount_cents, :integer, default: 0, null: false
    add_column :bookings, :final_amount_cents, :integer
    add_column :bookings, :refunded_cents, :integer, default: 0, null: false
    add_column :bookings, :checkout_session_id, :string
    add_column :bookings, :payment_intent_id, :string
    add_column :bookings, :estimated_people_count_at_payment, :integer
  end
end
