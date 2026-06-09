# Idempotent — safe to re-run at any time.
# Barcelona-based seed data with 4 coaches (Alice, Maria, Felipe, Mario).
# Covers: draft, open (few/many), full, ready-to-close, already-closed, cancelled.
# Refund math uses integer division to match Training#current_price_cents exactly.

require 'open-uri'

puts "Cleaning database..."
Review.destroy_all
Message.destroy_all
Booking.destroy_all
Training.destroy_all
User.destroy_all

# ─── Helper: attach image from URL ────────────────────────────────────────────

def attach_image(record, field, url, filename)
  record.public_send(field).attach(
    io: URI.open(url),
    filename: filename,
    content_type: "image/png"
  )
rescue => e
  puts "  Warning: could not attach #{filename} — #{e.message}"
end

# ─── Users ────────────────────────────────────────────────────────────────────

puts "Creating coaches..."

alice = User.create!(
  email: "alice@splitfit.com",
  name: "Alice Carter",
  is_coach: true,
  password: "password",
  password_confirmation: "password",
  speciality: "Yoga & CrossFit",
  description: "Certified yoga instructor and CrossFit Level 2 trainer with 8 years of experience in Barcelona. Passionate about holistic fitness and helping clients find strength through mindful movement.",
  address: "El Born, Barcelona"
)
attach_image(alice, :avatar, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013186/coach_Alice_propic_isqy4g.png", "alice_avatar.png")

maria = User.create!(
  email: "maria@splitfit.com",
  name: "Maria García",
  is_coach: true,
  password: "password",
  password_confirmation: "password",
  speciality: "Pilates",
  description: "Expert Pilates instructor with a background in physiotherapy. 10 years of experience helping clients improve posture, flexibility and core strength across Barcelona.",
  address: "Eixample, Barcelona"
)
attach_image(maria, :avatar, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013186/coach_Maria_propic_mlmy0f.png", "maria_avatar.png")

felipe = User.create!(
  email: "felipe@splitfit.com",
  name: "Felipe Rodríguez",
  is_coach: true,
  password: "password",
  password_confirmation: "password",
  speciality: "Weightlifting & HIIT",
  description: "Strength and conditioning coach specialising in Olympic weightlifting and high-intensity training. Former competitive athlete with 6 years of coaching experience in Poblenou.",
  address: "Poblenou, Barcelona"
)
attach_image(felipe, :avatar, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013186/coach_Felipe_propic_s62q0g.png", "felipe_avatar.png")

mario = User.create!(
  email: "mario@splitfit.com",
  name: "Mario Fernández",
  is_coach: true,
  password: "password",
  password_confirmation: "password",
  speciality: "Strength & Conditioning",
  description: "Personal trainer focused on functional strength and body composition. 7 years of experience working with athletes and recreational clients across Barcelona.",
  address: "Gràcia, Barcelona"
)
attach_image(mario, :avatar, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013186/coach_Mario_propic_zmorp5.png", "mario_avatar.png")

puts "Creating clients..."

laia = User.create!(
  email: "laia@splitfit.com", name: "Laia Martínez",
  is_coach: false, password: "password", password_confirmation: "password"
)
carlos = User.create!(
  email: "carlos@splitfit.com", name: "Carlos Puig",
  is_coach: false, password: "password", password_confirmation: "password"
)
sofia = User.create!(
  email: "sofia@splitfit.com", name: "Sofia López",
  is_coach: false, password: "password", password_confirmation: "password"
)
david = User.create!(
  email: "david@splitfit.com", name: "David Torres",
  is_coach: false, password: "password", password_confirmation: "password"
)
emma = User.create!(
  email: "emma@splitfit.com", name: "Emma Wilson",
  is_coach: false, password: "password", password_confirmation: "password"
)
jordi = User.create!(
  email: "jordi@splitfit.com", name: "Jordi Bosch",
  is_coach: false, password: "password", password_confirmation: "password"
)
nuria = User.create!(
  email: "nuria@splitfit.com", name: "Núria Vidal",
  is_coach: false, password: "password", password_confirmation: "password"
)
pablo = User.create!(
  email: "pablo@splitfit.com", name: "Pablo Sánchez",
  is_coach: false, password: "password", password_confirmation: "password"
)

coaches = [alice, maria, felipe, mario]
clients = [laia, carlos, sofia, david, emma, jordi, nuria, pablo]

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
  user: alice, workout_type: "Yoga",
  place: "Parc de la Ciutadella, Barcelona",
  description: "A gentle morning yoga flow to start your week right. Bring your own mat and water bottle. Suitable for all levels.",
  status: "draft", coach_price_cents: 7000, duration: 60,
  date: 7.days.from_now, min_people: 2, max_people: 10
)
attach_image(draft, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Alice_yoga_fzoriy.png", "alice_yoga.png")

# ── 2. OPEN — few bookings ─────────────────────────────────────────────────────
# Test: book as a client, price drops after each booking.
# coach_price=6000, min=2, max=8
# laia paid: 6000/max(1,2) = 3000
# If you book now: 6000/max(2,2) = 3000 (same, min_people floor)
# If a 3rd books:  6000/max(3,2) = 2000 (price drops)
open_few = Training.create!(
  user: alice, workout_type: "HIIT",
  place: "Barceloneta Beach, Barcelona",
  description: "High-intensity interval training on the beach. Expect sprints, burpees and circuit drills. Wear trainers suitable for sand.",
  status: "open", coach_price_cents: 6000, duration: 45,
  date: 5.days.from_now, min_people: 2, max_people: 8
)
attach_image(open_few, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013222/Alice_HIIT_njyoxd.png", "alice_hiit.png")

Booking.create!(
  training: open_few, user: laia, status: "paid",
  amount_cents: price_at(6000, 0, 2),
  payment_intent_id: "pi_seed_open_few_1",
  checkout_session_id: "cs_seed_open_few_1",
  estimated_people_count_at_payment: 1
)
# carlos has a PENDING booking (checkout started, not completed) — tests that
# pending bookings don't count toward final_price_cents
Booking.create!(
  training: open_few, user: carlos, status: "pending",
  amount_cents: price_at(6000, 1, 2),
  estimated_people_count_at_payment: 2
)

# ── 3. OPEN — mid fill ─────────────────────────────────────────────────────────
# Test: browse a popular session, david can still book and will push price down.
# coach_price=9000, min=3, max=10
# 1st=3000, 2nd=3000, 3rd=3000 (min_people floor keeps price stable until >3)
open_mid = Training.create!(
  user: mario, workout_type: "Strength",
  place: "SportLife Diagonal, Avinguda Diagonal 534, Barcelona",
  description: "Full-body strength session focusing on compound lifts. All levels welcome — weights and equipment provided. Bring a towel.",
  status: "open", coach_price_cents: 9000, duration: 60,
  date: 10.days.from_now, min_people: 3, max_people: 10
)
attach_image(open_mid, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Mario_strength_sjk4x7.png", "mario_strength_1.png")

[
  [laia, 0], [carlos, 1], [sofia, 2]
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
  user: alice, workout_type: "Boxing",
  place: "Boxing Club Barcelona, Carrer del Consell de Cent 310, Barcelona",
  description: "Boxing fundamentals: footwork, jab-cross combos and bag work. No experience needed. Gloves and wraps provided.",
  status: "full", coach_price_cents: 8000, duration: 60,
  date: 3.days.from_now, min_people: 2, max_people: 4
)
attach_image(full_training, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013647/Alice_boxing_m9tfph.png", "alice_boxing.png")

[
  [laia, 0], [carlos, 1], [sofia, 2], [david, 3]
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
# laia=3000, carlos=3000, sofia=2000, david=1500
# final_price = 6000/max(4,2) = 1500
# expected refunds: laia=1500, carlos=1500, sofia=500, david=0 (skipped)
closeable_alice = Training.create!(
  user: alice, workout_type: "CrossFit",
  place: "CrossFit Eixample, Carrer d'Enric Granados 86, Barcelona",
  description: "Functional fitness combining gymnastics, weightlifting and metabolic conditioning. Scaled options available for all fitness levels.",
  status: "open", coach_price_cents: 6000, duration: 60,
  date: 2.days.ago, min_people: 2, max_people: 8
)
attach_image(closeable_alice, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013646/Alice_crossfit_v3gneu.png", "alice_crossfit.png")

[
  [laia, 0], [carlos, 1], [sofia, 2], [david, 3]
].each_with_index do |(client, paid_before), i|
  Booking.create!(
    training: closeable_alice, user: client, status: "paid",
    amount_cents: price_at(6000, paid_before, 2),
    payment_intent_id: "pi_seed_closeable_alice_#{i + 1}",
    checkout_session_id: "cs_seed_closeable_alice_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 6. READY TO CLOSE — mario's session ────────────────────────────────────────
# Same scenario for mario's account.
# coach_price=9000, min=3, max=8
# laia=3000, carlos=3000, sofia=3000, david=2250
# final_price = 9000/max(4,3) = 2250
# expected refunds: laia=750, carlos=750, sofia=750, david=0 (skipped)
closeable_mario = Training.create!(
  user: mario, workout_type: "Strength",
  place: "WIT Fitness Barcelona, Carrer de Sancho de Ávila 2, Barcelona",
  description: "Progressive overload strength session focused on squat, deadlift and bench press. Equipment and spotters provided.",
  status: "open", coach_price_cents: 9000, duration: 45,
  date: 1.day.ago, min_people: 3, max_people: 8
)
attach_image(closeable_mario, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013650/Mario_strength_fntz9w.png", "mario_strength_2.png")

[
  [laia, 0], [carlos, 1], [sofia, 2], [david, 3]
].each_with_index do |(client, paid_before), i|
  Booking.create!(
    training: closeable_mario, user: client, status: "paid",
    amount_cents: price_at(9000, paid_before, 3),
    payment_intent_id: "pi_seed_closeable_mario_#{i + 1}",
    checkout_session_id: "cs_seed_closeable_mario_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 7. ALREADY CLOSED — Felipe weightlifting ───────────────────────────────────
# Test: verify post-refund state. Bookings show refunded_cents. Has reviews.
# coach_price=8000, min=2, max=6
# laia=4000, carlos=4000, sofia=2666, david=2000
# final_price = 8000/max(4,2) = 2000
# refunds issued: laia=2000, carlos=2000, sofia=666, david=0 (skipped — amount==final)
closed_training = Training.create!(
  user: felipe, workout_type: "Weightlifting",
  place: "Barna Gym, Carrer de Pallars 99, Poblenou, Barcelona",
  description: "Olympic weightlifting technique session covering the snatch and clean & jerk. Barbells and bumper plates provided. Previous lifting experience recommended.",
  status: "closed", coach_price_cents: 8000, duration: 45,
  date: 10.days.ago, min_people: 2, max_people: 6
)
attach_image(closed_training, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Felipe_weigthlifting_jl5exn.png", "felipe_weightlifting.png")

final_price_closed = 8000 / [4, 2].max  # 2000

[
  [laia, 0], [carlos, 1], [sofia, 2], [david, 3]
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
# Test: reopen flow (maria logs in, clicks Reopen).
cancelled_training = Training.create!(
  user: maria, workout_type: "Pilates",
  place: "Studio Pilates Barcelona, Carrer de Provença 248, Barcelona",
  description: "Classic Pilates mat class focusing on breath, alignment and core control. Props and mats provided. Maximum 8 participants for personalised attention.",
  status: "cancelled", coach_price_cents: 6500, duration: 50,
  date: 4.days.from_now, min_people: 2, max_people: 8
)
attach_image(cancelled_training, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Maria_pilates_io5et1.png", "maria_pilates.png")

# ── 9. Additional open — Felipe HIIT ──────────────────────────────────────────
open_felipe_hiit = Training.create!(
  user: felipe, workout_type: "HIIT",
  place: "Barceloneta Beach, Barcelona",
  description: "Explosive beach HIIT — kettlebell swings, battle ropes and sprint intervals. All equipment provided. Wear sports shoes.",
  status: "open", coach_price_cents: 5500, duration: 45,
  date: 8.days.from_now, min_people: 2, max_people: 12
)
attach_image(open_felipe_hiit, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013649/Felipe_HIIT_crpwgv.png", "felipe_hiit.png")

# ── 10. Additional open — Maria Pilates ───────────────────────────────────────
open_maria_pilates = Training.create!(
  user: maria, workout_type: "Pilates",
  place: "Studio Pilates Barcelona, Carrer de Provença 248, Barcelona",
  description: "Reformer-inspired mat Pilates focusing on spinal articulation and hip stability. Suitable for all levels. Mats and props provided.",
  status: "open", coach_price_cents: 7000, duration: 55,
  date: 6.days.from_now, min_people: 2, max_people: 8
)
attach_image(open_maria_pilates, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Maria_pilates_io5et1.png", "maria_pilates_2.png")

Booking.create!(
  training: open_maria_pilates, user: sofia, status: "paid",
  amount_cents: price_at(7000, 0, 2),
  payment_intent_id: "pi_seed_maria_p_1",
  checkout_session_id: "cs_seed_maria_p_1",
  estimated_people_count_at_payment: 1
)
Booking.create!(
  training: open_maria_pilates, user: nuria, status: "paid",
  amount_cents: price_at(7000, 1, 2),
  payment_intent_id: "pi_seed_maria_p_2",
  checkout_session_id: "cs_seed_maria_p_2",
  estimated_people_count_at_payment: 2
)

# ── 11. Additional open — Maria Yoga flow ─────────────────────────────────────
open_maria_yoga = Training.create!(
  user: maria, workout_type: "Yoga",
  place: "Parc de la Ciutadella, Barcelona",
  description: "Therapeutic yoga flow combining Pilates precision with yoga breath. Ideal for stress relief and postural correction. Bring a mat.",
  status: "open", coach_price_cents: 6500, duration: 60,
  date: 13.days.from_now, min_people: 2, max_people: 10
)
attach_image(open_maria_yoga, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Alice_yoga_fzoriy.png", "maria_yoga.png")

# ── 12. Additional open — Felipe Strength ─────────────────────────────────────
open_felipe_strength = Training.create!(
  user: felipe, workout_type: "Strength",
  place: "Barna Gym, Carrer de Pallars 99, Poblenou, Barcelona",
  description: "Hypertrophy-focused strength session. We'll cover squat variations, Romanian deadlifts and upper-body pressing. All levels welcome.",
  status: "open", coach_price_cents: 8500, duration: 60,
  date: 9.days.from_now, min_people: 2, max_people: 10
)
attach_image(open_felipe_strength, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Felipe_weigthlifting_jl5exn.png", "felipe_strength.png")

Booking.create!(
  training: open_felipe_strength, user: jordi, status: "paid",
  amount_cents: price_at(8500, 0, 2),
  payment_intent_id: "pi_seed_felipe_s_1",
  checkout_session_id: "cs_seed_felipe_s_1",
  estimated_people_count_at_payment: 1
)
Booking.create!(
  training: open_felipe_strength, user: pablo, status: "paid",
  amount_cents: price_at(8500, 1, 2),
  payment_intent_id: "pi_seed_felipe_s_2",
  checkout_session_id: "cs_seed_felipe_s_2",
  estimated_people_count_at_payment: 2
)
Booking.create!(
  training: open_felipe_strength, user: emma, status: "paid",
  amount_cents: price_at(8500, 2, 2),
  payment_intent_id: "pi_seed_felipe_s_3",
  checkout_session_id: "cs_seed_felipe_s_3",
  estimated_people_count_at_payment: 3
)

# ── 13. Additional open — Mario Functional ────────────────────────────────────
open_mario_functional = Training.create!(
  user: mario, workout_type: "CrossFit",
  place: "SportLife Diagonal, Avinguda Diagonal 534, Barcelona",
  description: "Functional fitness circuit — kettlebells, box jumps, pull-ups and core work. Scaled variations available. Great for all fitness levels.",
  status: "open", coach_price_cents: 8000, duration: 60,
  date: 14.days.from_now, min_people: 2, max_people: 8
)
attach_image(open_mario_functional, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013646/Alice_crossfit_v3gneu.png", "mario_crossfit.png")

Booking.create!(
  training: open_mario_functional, user: pablo, status: "paid",
  amount_cents: price_at(8000, 0, 2),
  payment_intent_id: "pi_seed_mario_f_1",
  checkout_session_id: "cs_seed_mario_f_1",
  estimated_people_count_at_payment: 1
)
Booking.create!(
  training: open_mario_functional, user: jordi, status: "paid",
  amount_cents: price_at(8000, 1, 2),
  payment_intent_id: "pi_seed_mario_f_2",
  checkout_session_id: "cs_seed_mario_f_2",
  estimated_people_count_at_payment: 2
)

# ── 14. Additional open — Alice Mobility ──────────────────────────────────────
open_alice_mobility = Training.create!(
  user: alice, workout_type: "Yoga",
  place: "Parc de Montjuïc, Barcelona",
  description: "Mobility and flexibility session combining yoga flows with deep stretching. Perfect for athletes and office workers. Bring a mat and water.",
  status: "open", coach_price_cents: 5500, duration: 60,
  date: 11.days.from_now, min_people: 2, max_people: 12
)
attach_image(open_alice_mobility, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Alice_yoga_fzoriy.png", "alice_mobility.png")

Booking.create!(
  training: open_alice_mobility, user: nuria, status: "paid",
  amount_cents: price_at(5500, 0, 2),
  payment_intent_id: "pi_seed_alice_m_1",
  checkout_session_id: "cs_seed_alice_m_1",
  estimated_people_count_at_payment: 1
)
Booking.create!(
  training: open_alice_mobility, user: emma, status: "paid",
  amount_cents: price_at(5500, 1, 2),
  payment_intent_id: "pi_seed_alice_m_2",
  checkout_session_id: "cs_seed_alice_m_2",
  estimated_people_count_at_payment: 2
)

# ── 15. ALREADY CLOSED — Alice Yoga ───────────────────────────────────────────
# coach_price=7000, min=2, max=8
# laia=3500, carlos=3500, emma=2333, jordi=1750
# final_price = 7000/max(4,2) = 1750
# refunds: laia=1750, carlos=1750, emma=583, jordi=0
closed_alice = Training.create!(
  user: alice, workout_type: "Yoga",
  place: "Parc de Montjuïc, Barcelona",
  description: "Sunrise yoga session on the hill with panoramic views of Barcelona. Flowing sequences and pranayama breathing. Mats provided.",
  status: "closed", coach_price_cents: 7000, duration: 60,
  date: 18.days.ago, min_people: 2, max_people: 8
)
attach_image(closed_alice, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Alice_yoga_fzoriy.png", "alice_yoga_closed.png")

final_price_closed_alice = 7000 / [4, 2].max  # 1750

[
  [laia, 0], [carlos, 1], [emma, 2], [jordi, 3]
].each_with_index do |(client, paid_before), i|
  amount = price_at(7000, paid_before, 2)
  refund = [amount - final_price_closed_alice, 0].max
  Booking.create!(
    training: closed_alice, user: client,
    status: refund.positive? ? "refunded" : "paid",
    amount_cents: amount,
    final_amount_cents: refund.positive? ? final_price_closed_alice : nil,
    refunded_cents: refund,
    payment_intent_id: "pi_seed_closed_alice_#{i + 1}",
    checkout_session_id: "cs_seed_closed_alice_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 16. ALREADY CLOSED — Maria Pilates ────────────────────────────────────────
# coach_price=7500, min=2, max=8
# sofia=3750, david=3750, nuria=2500, pablo=1875
# final_price = 7500/max(4,2) = 1875
# refunds: sofia=1875, david=1875, nuria=625, pablo=0
closed_maria = Training.create!(
  user: maria, workout_type: "Pilates",
  place: "Studio Pilates Barcelona, Carrer de Provença 248, Barcelona",
  description: "Advanced Pilates mat class covering the full classical repertoire. Focused on breath, precision and flow. Intermediate level recommended.",
  status: "closed", coach_price_cents: 7500, duration: 55,
  date: 14.days.ago, min_people: 2, max_people: 8
)
attach_image(closed_maria, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013221/Maria_pilates_io5et1.png", "maria_pilates_closed.png")

final_price_closed_maria = 7500 / [4, 2].max  # 1875

[
  [sofia, 0], [david, 1], [nuria, 2], [pablo, 3]
].each_with_index do |(client, paid_before), i|
  amount = price_at(7500, paid_before, 2)
  refund = [amount - final_price_closed_maria, 0].max
  Booking.create!(
    training: closed_maria, user: client,
    status: refund.positive? ? "refunded" : "paid",
    amount_cents: amount,
    final_amount_cents: refund.positive? ? final_price_closed_maria : nil,
    refunded_cents: refund,
    payment_intent_id: "pi_seed_closed_maria_#{i + 1}",
    checkout_session_id: "cs_seed_closed_maria_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ── 17. ALREADY CLOSED — Mario Functional Strength ────────────────────────────
# coach_price=9000, min=3, max=8
# laia=3000, emma=3000, jordi=3000, pablo=2250
# final_price = 9000/max(4,3) = 2250
# refunds: laia=750, emma=750, jordi=750, pablo=0
closed_mario = Training.create!(
  user: mario, workout_type: "Strength",
  place: "WIT Fitness Barcelona, Carrer de Sancho de Ávila 2, Barcelona",
  description: "Functional strength circuit combining barbell work with bodyweight movements. Focus on movement quality and progressive overload.",
  status: "closed", coach_price_cents: 9000, duration: 60,
  date: 8.days.ago, min_people: 3, max_people: 8
)
attach_image(closed_mario, :photo, "https://res.cloudinary.com/ds643xagk/image/upload/v1781013650/Mario_strength_fntz9w.png", "mario_strength_closed.png")

final_price_closed_mario = 9000 / [4, 3].max  # 2250

[
  [laia, 0], [emma, 1], [jordi, 2], [pablo, 3]
].each_with_index do |(client, paid_before), i|
  amount = price_at(9000, paid_before, 3)
  refund = [amount - final_price_closed_mario, 0].max
  Booking.create!(
    training: closed_mario, user: client,
    status: refund.positive? ? "refunded" : "paid",
    amount_cents: amount,
    final_amount_cents: refund.positive? ? final_price_closed_mario : nil,
    refunded_cents: refund,
    payment_intent_id: "pi_seed_closed_mario_#{i + 1}",
    checkout_session_id: "cs_seed_closed_mario_#{i + 1}",
    estimated_people_count_at_payment: paid_before + 1
  )
end

# ─── Reviews ──────────────────────────────────────────────────────────────────

puts "Creating reviews..."

# Felipe — weightlifting session (closed_training)
felipe_review_texts = [
  "Felipe's technique coaching is exceptional. I finally nailed my snatch form after just one session.",
  "Very knowledgeable about Olympic lifting — Felipe breaks every movement down perfectly. Highly recommend.",
  "Intense but incredibly rewarding. Felipe is encouraging without being overbearing. Left feeling accomplished.",
  "Great training environment at Barna Gym. Felipe knows exactly how to push each participant to their best.",
]

closed_training.bookings.each_with_index do |booking, i|
  Review.create!(
    user: booking.user, training: closed_training, coach: closed_training.user,
    score: rand(4..5), description: felipe_review_texts[i % felipe_review_texts.length]
  )
end

# Alice — yoga session (closed_alice)
alice_review_texts = [
  "Alice's yoga sessions are truly transformative. Her cues are clear and her energy is contagious.",
  "Wonderful morning session with stunning views. Alice creates such a calm and focused atmosphere.",
  "Best yoga class I've attended in Barcelona. She adapts beautifully to all levels in the group.",
  "Alice is patient, knowledgeable and makes every session feel very personal despite the group size.",
  "Great combination of breathing techniques and deep stretching. My posture has improved so much.",
  "Such a gifted instructor — I felt the difference in my flexibility after just one session.",
]

closed_alice.bookings.each_with_index do |booking, i|
  Review.create!(
    user: booking.user, training: closed_alice, coach: closed_alice.user,
    score: rand(4..5), description: alice_review_texts[i % alice_review_texts.length]
  )
end

# Maria — pilates session (closed_maria)
maria_review_texts = [
  "Maria's physiotherapy background really shows — every exercise has a clear purpose and a precise explanation.",
  "My lower back pain improved dramatically after this session. Maria really knows what she's doing.",
  "Maria creates a very welcoming environment. Perfect for beginners and experienced practitioners alike.",
  "Excellent class — precise corrections, great music and a wonderfully professional instructor.",
  "Maria pays attention to every participant. I learned more in one session with her than in months elsewhere.",
  "Very structured and effective. Maria is clearly an expert and a genuinely passionate teacher.",
]

closed_maria.bookings.each_with_index do |booking, i|
  Review.create!(
    user: booking.user, training: closed_maria, coach: closed_maria.user,
    score: rand(4..5), description: maria_review_texts[i % maria_review_texts.length]
  )
end

# Mario — functional strength session (closed_mario)
mario_review_texts = [
  "Mario's strength program is perfectly structured. He explains progressive overload in a way anyone can understand.",
  "Excellent session — Mario knows exactly how to challenge each participant without pushing too far.",
  "Very motivating coach. Mario completely corrected my deadlift form and made the fix feel intuitive.",
  "One of the best group strength sessions I've attended in Barcelona. Will definitely rebook.",
  "Mario keeps the energy high while maintaining great attention to safety. 5 stars.",
  "Incredible session — I left exhausted but feeling stronger than I have in months.",
]

closed_mario.bookings.each_with_index do |booking, i|
  Review.create!(
    user: booking.user, training: closed_mario, coach: closed_mario.user,
    score: rand(4..5), description: mario_review_texts[i % mario_review_texts.length]
  )
end

# ─── Messages ─────────────────────────────────────────────────────────────────

puts "Creating messages..."

Message.create!(training: open_mid, user: mario,  content: "Bring a towel and comfortable workout clothes. I'll provide all the equipment.")
Message.create!(training: open_mid, user: laia,   content: "Do we need to bring specific training shoes?")
Message.create!(training: open_mid, user: mario,  content: "Yes, I recommend wearing sports shoes with good ankle support.")

Message.create!(training: open_maria_pilates, user: maria, content: "Please arrive 5 minutes early so we can set up mats and props together.")
Message.create!(training: open_maria_pilates, user: sofia, content: "Is this suitable for someone with a history of lower back issues?")
Message.create!(training: open_maria_pilates, user: maria, content: "Absolutely — I have a physiotherapy background and will offer modifications throughout.")

Message.create!(training: open_felipe_hiit, user: felipe, content: "All kettlebells and battle ropes will be set up on the beach. Just bring water and trainers.")
Message.create!(training: open_felipe_hiit, user: jordi,  content: "What's the warm-up like? I have a slightly tight hamstring.")
Message.create!(training: open_felipe_hiit, user: felipe, content: "We always start with a full dynamic warm-up. Let me know on the day and I'll adapt your movements.")

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
puts "  Coaches : alice@splitfit.com  |  maria@splitfit.com  |  felipe@splitfit.com  |  mario@splitfit.com"
puts "  Clients : laia@splitfit.com  |  carlos@splitfit.com  |  sofia@splitfit.com  |  david@splitfit.com"
puts "            emma@splitfit.com  |  jordi@splitfit.com   |  nuria@splitfit.com   |  pablo@splitfit.com"
puts ""
puts "Scenario map"
puts "  ##{draft.id}               Draft           alice  — publish it"
puts "  ##{open_few.id}            Open (few)      alice  — 1 paid + 1 pending; book as sofia/david to see price drop"
puts "  ##{open_mid.id}            Open (mid)      mario  — 3 paid; david books → price stays (min_people floor)"
puts "  ##{full_training.id}       Full            alice  — booking blocked"
puts "  ##{closeable_alice.id}     Ready to close  alice  — close to trigger refunds (Stripe will error in dev; check logs)"
puts "  ##{closeable_mario.id}     Ready to close  mario  — same for mario"
puts "  ##{closed_training.id}     Closed          felipe — refunds processed, reviews present"
puts "  ##{closed_alice.id}        Closed          alice  — refunds processed, reviews present"
puts "  ##{closed_maria.id}        Closed          maria  — refunds processed, reviews present"
puts "  ##{closed_mario.id}        Closed          mario  — refunds processed, reviews present"
puts "  ##{cancelled_training.id}  Cancelled       maria  — reopen it"
puts "  ##{open_felipe_hiit.id}    Open            felipe — beach HIIT"
puts "  ##{open_maria_pilates.id}  Open            maria  — Pilates, 2 paid"
puts "  ##{open_maria_yoga.id}     Open            maria  — yoga flow, no bookings yet"
puts "  ##{open_felipe_strength.id} Open           felipe — strength, 3 paid"
puts "  ##{open_mario_functional.id} Open          mario  — functional CrossFit, 2 paid"
puts "  ##{open_alice_mobility.id} Open            alice  — mobility/yoga, 2 paid"
puts ""
puts "Expected refunds when closing ##{closeable_alice.id} (alice, coach_price=6000, min=2, 4 paid, final=1500)"
closeable_alice.bookings.paid.each do |b|
  expected = [b.amount_cents - 1500, 0].max
  puts "  Booking ##{b.id} (#{b.user.name}): paid=#{b.amount_cents}, refund=#{expected}"
end
puts ""
puts "Expected refunds when closing ##{closeable_mario.id} (mario, coach_price=9000, min=3, 4 paid, final=2250)"
closeable_mario.bookings.paid.each do |b|
  expected = [b.amount_cents - 2250, 0].max
  puts "  Booking ##{b.id} (#{b.user.name}): paid=#{b.amount_cents}, refund=#{expected}"
end
