# Idempotent — safe to re-run at any time.
# Covers: draft, open (few/many), full, ready-to-close, already-closed, cancelled.
# Refund math uses integer division to match Training#current_price_cents exactly.

puts "Cleaning database..."
Review.destroy_all
Message.destroy_all
Booking.destroy_all
Training.destroy_all
User.destroy_all

# ─── Users ────────────────────────────────────────────────────────────────────

puts "Creating users..."

alice = User.create!(
  email: "alice@splitfit.com", name: "Alice Carter",
  is_coach: true, password: "password", password_confirmation: "password"
)
marco = User.create!(
  email: "marco@splitfit.com", name: "Marco Rossi",
  is_coach: true, password: "password", password_confirmation: "password"
)
jordan = User.create!(
  email: "jordan@splitfit.com", name: "Jordan Lee",
  is_coach: false, password: "password", password_confirmation: "password"
)
sam = User.create!(
  email: "sam@splitfit.com", name: "Sam Taylor",
  is_coach: false, password: "password", password_confirmation: "password"
)
riley = User.create!(
  email: "riley@splitfit.com", name: "Riley Morgan",
  is_coach: false, password: "password", password_confirmation: "password"
)
casey = User.create!(
  email: "casey@splitfit.com", name: "Casey Brooks",
  is_coach: false, password: "password", password_confirmation: "password"
)

coaches = [alice, marco]
clients = [jordan, sam, riley, casey]

# ─── Helper ───────────────────────────────────────────────────────────────────

# Mirrors Training#current_price_cents so seed amounts are always correct.
def price_at(coach_price_cents, paid_count, min_people)
  coach_price_cents / [paid_count + 1, min_people].max
end

# ─── Trainings ────────────────────────────────────────────────────────────────

puts "Creating trainings..."

# ── 1. DRAFT ──────────────────────────────────────────────────────────────────
# Test: publish flow. Not visible in index (policy_scope excludes drafts).
draft = Training.create!(
  user: alice, workout_type: "Pilates", place: "Chelsea Studio",
  status: "draft", coach_price_cents: 7000, duration: 60,
  date: 7.days.from_now, min_people: 2, max_people: 10
)

# ── 2. OPEN — few bookings ─────────────────────────────────────────────────────
# Test: book as a client, price drops after each booking.
# coach_price=6000, min=2, max=8
# jordan paid: 6000/max(1,2) = 3000
# If you book now: 6000/max(2,2) = 3000 (same, min_people floor)
# If a 3rd books:  6000/max(3,2) = 2000 (price drops)
open_few = Training.create!(
  user: alice, workout_type: "HIIT", place: "Brooklyn Gym",
  status: "open", coach_price_cents: 6000, duration: 45,
  date: 5.days.from_now, min_people: 2, max_people: 8
)
Booking.create!(
  training: open_few, user: jordan, status: "paid",
  amount_cents: price_at(6000, 0, 2),
  payment_intent_id: "pi_seed_open_few_1",
  checkout_session_id: "cs_seed_open_few_1",
  estimated_people_count_at_payment: 1
)
# sam has a PENDING booking (checkout started, not completed) — tests that
# pending bookings don't count toward final_price_cents
Booking.create!(
  training: open_few, user: sam, status: "pending",
  amount_cents: price_at(6000, 1, 2),
  estimated_people_count_at_payment: 2
)

# ── 3. OPEN — mid fill ─────────────────────────────────────────────────────────
# Test: browse a popular session, casey can still book and will push price down.
# coach_price=9000, min=3, max=10
# 1st=3000, 2nd=3000, 3rd=3000 (min_people floor keeps price stable until >3)
open_mid = Training.create!(
  user: marco, workout_type: "CrossFit", place: "Central Park",
  status: "open", coach_price_cents: 9000, duration: 60,
  date: 10.days.from_now, min_people: 3, max_people: 10
)
[
  [jordan, 0], [sam, 1], [riley, 2]
].each_with_index do |(client, paid_before), i|
  Booking.create!(
    training: open_mid, user: client, status: "paid",
    amount_cents: price_at(9000, paid_before, 3),
    payment_intent_id: "pi_seed_open_mid_#{i + 1}",
    checkout_session_id: "cs_seed_open_mid_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 4. FULL ────────────────────────────────────────────────────────────────────
# Test: booking blocked, "full" badge shown.
# coach_price=8000, min=2, max=4
# 1st=4000, 2nd=4000, 3rd=2666, 4th=2000
full_training = Training.create!(
  user: alice, workout_type: "Boxing", place: "Chelsea Studio",
  status: "full", coach_price_cents: 8000, duration: 60,
  date: 3.days.from_now, min_people: 2, max_people: 4
)
[
  [jordan, 0], [sam, 1], [riley, 2], [casey, 3]
].each_with_index do |(client, paid_before), i|
  Booking.create!(
    training: full_training, user: client, status: "paid",
    amount_cents: price_at(8000, paid_before, 2),
    payment_intent_id: "pi_seed_full_#{i + 1}",
    checkout_session_id: "cs_seed_full_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 5. READY TO CLOSE — alice's session ────────────────────────────────────────
# Test: log in as alice, click Close → TrainingRefundService runs.
# In dev, Stripe::Refund.create will fail (fake PI IDs) — check logs.
# coach_price=6000, min=2, max=8
# jordan=3000, sam=3000, riley=2000, casey=1500
# final_price = 6000/max(4,2) = 1500
# expected refunds: jordan=1500, sam=1500, riley=500, casey=0 (skipped)
closeable_alice = Training.create!(
  user: alice, workout_type: "Yoga", place: "Riverside Track",
  status: "open", coach_price_cents: 6000, duration: 60,
  date: 2.days.ago, min_people: 2, max_people: 8
)
[
  [jordan, 0], [sam, 1], [riley, 2], [casey, 3]
].each_with_index do |(client, paid_before), i|
  Booking.create!(
    training: closeable_alice, user: client, status: "paid",
    amount_cents: price_at(6000, paid_before, 2),
    payment_intent_id: "pi_seed_closeable_alice_#{i + 1}",
    checkout_session_id: "cs_seed_closeable_alice_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 6. READY TO CLOSE — marco's session ────────────────────────────────────────
# Same scenario for marco's account.
# coach_price=9000, min=3, max=8
# jordan=3000, sam=3000, riley=3000, casey=2250
# final_price = 9000/max(4,3) = 2250
# expected refunds: jordan=750, sam=750, riley=750, casey=0 (skipped)
closeable_marco = Training.create!(
  user: marco, workout_type: "Strength", place: "Central Park",
  status: "open", coach_price_cents: 9000, duration: 45,
  date: 1.day.ago, min_people: 3, max_people: 8
)
[
  [jordan, 0], [sam, 1], [riley, 2], [casey, 3]
].each_with_index do |(client, paid_before), i|
  Booking.create!(
    training: closeable_marco, user: client, status: "paid",
    amount_cents: price_at(9000, paid_before, 3),
    payment_intent_id: "pi_seed_closeable_marco_#{i + 1}",
    checkout_session_id: "cs_seed_closeable_marco_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 7. ALREADY CLOSED ──────────────────────────────────────────────────────────
# Test: verify post-refund state. Bookings show refunded_cents. Has reviews.
# coach_price=8000, min=2, max=6
# jordan=4000, sam=4000, riley=2666, casey=2000
# final_price = 8000/max(4,2) = 2000
# refunds issued: jordan=2000, sam=2000, riley=666, casey=0 (skipped — amount==final)
closed_training = Training.create!(
  user: alice, workout_type: "HIIT", place: "Online",
  status: "closed", coach_price_cents: 8000, duration: 45,
  date: 10.days.ago, min_people: 2, max_people: 6
)
final_price_closed = 8000 / [4, 2].max  # 2000
[
  [jordan, 0], [sam, 1], [riley, 2], [casey, 3]
].each_with_index do |(client, paid_before), i|
  amount = price_at(8000, paid_before, 2)
  refund = [amount - final_price_closed, 0].max
  Booking.create!(
    training: closed_training, user: client,
    status: refund.positive? ? "refunded" : "paid",
    amount_cents: amount,
    final_amount_cents: refund.positive? ? final_price_closed : nil,
    refunded_cents: refund,
    payment_intent_id: "pi_seed_closed_#{i + 1}",
    checkout_session_id: "cs_seed_closed_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 8. CANCELLED ───────────────────────────────────────────────────────────────
# Test: reopen flow (marco logs in, clicks Reopen).
cancelled_training = Training.create!(
  user: marco, workout_type: "Pilates", place: "Online",
  status: "cancelled", coach_price_cents: 6500, duration: 50,
  date: 4.days.from_now, min_people: 2, max_people: 15
)

# ── Additional open sessions (index variety) ───────────────────────────────────
Training.create!(
  user: marco, workout_type: "Yoga", place: "Chelsea Studio",
  status: "open", coach_price_cents: 7000, duration: 60,
  date: 8.days.from_now, min_people: 3, max_people: 12
)
Training.create!(
  user: alice, workout_type: "CrossFit", place: "Brooklyn Gym",
  status: "open", coach_price_cents: 9500, duration: 60,
  date: 12.days.from_now, min_people: 4, max_people: 10
)

# ─── Reviews ──────────────────────────────────────────────────────────────────

puts "Creating reviews..."

review_texts = [
  "Great session, really pushed me to my limits!",
  "Excellent coach, very professional and motivating.",
  "Loved the workout, will definitely book again.",
  "Good intensity, learned a lot of new techniques.",
  "Amazing experience, highly recommend to everyone.",
  "Challenging but worth it. Felt great afterwards.",
]

closed_training.bookings.each do |booking|
  Review.create!(
    user: booking.user, training: closed_training, coach: closed_training.user,
    score: rand(4..5), description: review_texts.sample
  )
end

# ─── Messages ─────────────────────────────────────────────────────────────────

puts "Creating messages..."

Message.create!(training: open_mid, user: marco,  content: "Bring your own gloves and water.")
Message.create!(training: open_mid, user: jordan, content: "Will resistance bands be provided?")
Message.create!(training: open_mid, user: marco,  content: "Yes, all equipment is on site.")

# ─── Summary ──────────────────────────────────────────────────────────────────

refunded_count = Booking.where(status: "refunded").count
pending_count  = Booking.pending.count

puts ""
puts "Done!"
puts "  #{User.count} users (#{coaches.count} coaches, #{clients.count} clients)"
puts "  #{Training.count} trainings"
puts "  #{Booking.count} bookings  (#{Booking.paid.count} paid, #{refunded_count} refunded, #{pending_count} pending)"
puts "  #{Review.count} reviews"
puts "  #{Message.count} messages"
puts ""
puts "Credentials (password: password)"
puts "  Coaches : alice@splitfit.com  |  marco@splitfit.com"
puts "  Clients : jordan@splitfit.com  |  sam@splitfit.com  |  riley@splitfit.com  |  casey@splitfit.com"
puts ""
puts "Scenario map"
puts "  ##{draft.id}             Draft          alice  — publish it"
puts "  ##{open_few.id}         Open (few)      alice  — 1 paid + 1 pending; book as riley/casey to see price drop"
puts "  ##{open_mid.id}         Open (mid)      marco  — 3 paid; casey books → price stays (min_people floor)"
puts "  ##{full_training.id}         Full           alice  — booking blocked"
puts "  ##{closeable_alice.id}  Ready to close  alice  — close to trigger refunds (Stripe will error in dev; check logs)"
puts "  ##{closeable_marco.id}  Ready to close  marco  — same for marco"
puts "  ##{closed_training.id}  Closed          alice  — refunds already processed, reviews present"
puts "  ##{cancelled_training.id}  Cancelled      marco  — reopen it"
puts ""
puts "Expected refunds when closing ##{closeable_alice.id} (alice, coach_price=6000, min=2, 4 paid, final=1500)"
closeable_alice.bookings.paid.each do |b|
  expected = [b.amount_cents - 1500, 0].max
  puts "  Booking ##{b.id} (#{b.user.name}): paid=#{b.amount_cents}, refund=#{expected}"
end
puts ""
puts "Expected refunds when closing ##{closeable_marco.id} (marco, coach_price=9000, min=3, 4 paid, final=2250)"
closeable_marco.bookings.paid.each do |b|
  expected = [b.amount_cents - 2250, 0].max
  puts "  Booking ##{b.id} (#{b.user.name}): paid=#{b.amount_cents}, refund=#{expected}"
end
