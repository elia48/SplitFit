# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Start dev server
bin/rails server

# Database setup
rails db:create db:migrate
rails db:seed

# Run all tests
rails test

# Run a single test file
rails test test/models/training_test.rb

# Run a single test by line number
rails test test/models/training_test.rb:15

# Linting
bundle exec rubocop
bundle exec rubocop -a  # auto-correct

# Security scans
bundle exec brakeman
bundle exec bundler-audit
```

## Architecture

**SplitFit** is a Rails 8.1.3 fitness training marketplace. Coaches post training sessions, clients book them.

**Stack:** Rails 8 · PostgreSQL · Devise (auth) · Pundit (authorization) · Bootstrap 5 · Hotwire (Turbo + Stimulus) · Solid Queue/Cache/Cable

### Domain Model

```
User (Devise)
  has_many :trainings         # user is coach for these
  has_many :bookings
  has_many :reviews
  has_many :messages

Training (belongs_to :user as coach)
  has_many :bookings, :messages, :reviews
  fields: coach_price, duration, date, place, workout_type, min_people, max_people, status

Booking  (belongs_to :training, :user)   status field
Review   (belongs_to :training, :user)   score (integer), description (text)
Message  (belongs_to :training, :user)   content (text)
```

### Routes

Bookings, reviews, and messages are nested under trainings for create/index; standalone for destroy and top-level index:

```
resources :training, except: :destroy
post   /training/:training_id/booking   → bookings#create
get    /booking                         → bookings#index
delete /booking/:id                     → bookings#destroy
# same pattern for reviews and messages
```

Root is `pages#home`. All routes except `pages#home` require authentication (`authenticate_user!` in ApplicationController).

### Authorization

Pundit is set up with `app/policies/application_policy.rb` (default deny-all). Per-model policies in `app/policies/` should be added as controllers are implemented. Call `authorize @record` in controller actions and `policy_scope(Training)` for collections.

### Frontend

- Bootstrap 5.3 + FontAwesome via Sass
- Stimulus controllers in `app/javascript/controllers/`
- Turbo drives navigation — avoid full-page redirects where Turbo frames fit
- `simple_form` is configured for Bootstrap; use `f.input` not `f.text_field`
- Shared partials: `app/views/shared/_navbar.html.erb`, `_flashes.html.erb`

### Testing

Rails default (Minitest). Controllers and models have stub test files in `test/`. Use fixtures in `test/fixtures/`.

### Code Style

RuboCop with `rubocop-rails-omakase`. Max line length 120. Most style cops are disabled — the enforced rules are minimal.

### Known Schema Issue

`User` model validates presence of `name` and `is_coach` but those columns are not in the schema yet — a migration is needed before those validations will work.
