# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Cleaning database..."
Review.destroy_all
Booking.destroy_all
Training.destroy_all
User.destroy_all

puts "Creating coaches..."
coaches = [
  { email: "alice@splitfit.com",  name: "Alice Carter" },
  { email: "marco@splitfit.com",  name: "Marco Rossi" },
].map do |attrs|
  User.create!(email: attrs[:email], name: attrs[:name], is_coach: true,
               password: "password123", password_confirmation: "password123")
end

puts "Creating clients..."
clients = [
  { email: "client1@splitfit.com", name: "Jordan Lee" },
  { email: "client2@splitfit.com", name: "Sam Taylor" },
  { email: "client3@splitfit.com", name: "Riley Morgan" },
  { email: "client4@splitfit.com", name: "Casey Brooks" },
].map do |attrs|
  User.create!(email: attrs[:email], name: attrs[:name], is_coach: false,
               password: "password123", password_confirmation: "password123")
end

puts "Creating trainings..."
trainings_data = [
  { workout_type: "HIIT",      place: "Brooklyn Gym",     coach_price: 85,  duration: 45, min_people: 2, max_people: 8  },
  { workout_type: "HIIT",      place: "Online",           coach_price: 60,  duration: 30, min_people: 4, max_people: 20 },
  { workout_type: "Yoga",      place: "Chelsea Studio",   coach_price: 70,  duration: 60, min_people: 3, max_people: 12 },
  { workout_type: "Yoga",      place: "Riverside Track",  coach_price: 55,  duration: 75, min_people: 2, max_people: 10 },
  { workout_type: "CrossFit",  place: "Brooklyn Gym",     coach_price: 95,  duration: 60, min_people: 4, max_people: 10 },
  { workout_type: "CrossFit",  place: "Central Park",     coach_price: 80,  duration: 45, min_people: 3, max_people: 8  },
  { workout_type: "Boxing",    place: "Chelsea Studio",   coach_price: 100, duration: 60, min_people: 2, max_people: 6  },
  { workout_type: "Boxing",    place: "Brooklyn Gym",     coach_price: 90,  duration: 45, min_people: 2, max_people: 8  },
  { workout_type: "Pilates",   place: "Online",           coach_price: 65,  duration: 50, min_people: 2, max_people: 15 },
  { workout_type: "Strength",  place: "Central Park",     coach_price: 110, duration: 60, min_people: 2, max_people: 5  },
]

statuses = %w[open open open full closed]
base_time = Time.now

trainings = trainings_data.each_with_index.map do |data, i|
  Training.create!(
    user:         coaches[i % coaches.size],
    workout_type: data[:workout_type],
    place:        data[:place],
    status:       statuses.sample,
    coach_price:  data[:coach_price],
    duration:     data[:duration],
    date:         base_time + (i * 2 + rand(1..5)).days + rand(8..18).hours,
    min_people:   data[:min_people],
    max_people:   data[:max_people]
  )
end

puts "Creating bookings..."
booking_statuses = %w[confirmed confirmed pending cancelled]

clients.each do |client|
  trainings.sample(4).each do |training|
    Booking.create!(
      user:     client,
      training: training,
      status:   booking_statuses.sample
    )
  end
end

puts "Creating reviews (clients reviewing trainer sessions)..."
review_texts = [
  "Great session, really pushed me to my limits!",
  "Excellent coach, very professional and motivating.",
  "Loved the workout, will definitely book again.",
  "Good intensity, learned a lot of new techniques.",
  "Amazing experience, highly recommend to everyone.",
  "Solid class, the coach kept great energy throughout.",
  "Challenging but worth it. Felt great afterwards.",
]

Booking.where(status: "confirmed").each do |booking|
  next if rand < 0.4 # not every confirmed booking gets a review

  Review.create!(
    user:        booking.user,
    training:    booking.training,
    score:       rand(3..5),
    description: review_texts.sample
  )
end

puts "Done!"
puts "  #{User.count} users (#{coaches.count} coaches, #{clients.count} clients)"
puts "  #{Training.count} trainings"
puts "  #{Booking.count} bookings"
puts "  #{Review.count} reviews"
