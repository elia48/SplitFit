# SplitFit

> **Train like a pro, pay like a group.**

SplitFit is a full-stack Ruby on Rails web application that makes personal training more accessible by allowing users to join small group sessions and split the cost of a professional trainer.

Developed as the final project of the Le Wagon Web Development Bootcamp.

---

## 🚀 Overview

Hiring a personal trainer can be expensive, preventing many people from accessing professional coaching.

SplitFit connects trainers and members through shared training sessions:

- 🏋️ Trainers create training sessions
- 👥 Members join existing sessions
- 💸 The session cost is shared among participants
- 📍 Users discover nearby sessions on an interactive map
- ⭐ Trainers receive ratings after completed sessions

The goal is to make professional coaching affordable while allowing trainers to earn the full value of their sessions.

---

## ✨ Features

- User authentication
- Trainer & Member roles
- Training session creation
- Booking management
- Interactive Mapbox map
- Geolocation with Geocoder
- Stripe payment integration
- AI-powered assistant
- Responsive design

---

## 🛠 Tech Stack

### Backend
- Ruby
- Ruby on Rails
- PostgreSQL
- Active Record

### Frontend
- HTML
- SCSS
- JavaScript
- Stimulus
- Bootstrap

### APIs & Services
- Stripe
- Mapbox
- Geocoder

### Tools
- Git
- GitHub
- Heroku

---

## 📸 Screenshots

### Joining a session

<table>
  <tr>
    <td align="center" width="33%"><img src="screenshots/login%20screen.jpg" alt="Login screen" width="250"><br><sub>Log in, or browse trainings as a guest</sub></td>
    <td align="center" width="33%"><img src="screenshots/training%20screen.jpg" alt="Trainings list" width="250"><br><sub>Browse sessions and filter by workout type</sub></td>
    <td align="center" width="33%"><img src="screenshots/map%20screen.jpg" alt="Map view" width="250"><br><sub>Find nearby sessions on the map</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/map%20screen%202.jpg" alt="Map session preview" width="250"><br><sub>Preview a session straight from the map</sub></td>
    <td align="center"><img src="screenshots/training%20booking.jpg" alt="Checkout" width="250"><br><sub>Pay your share securely with Stripe</sub></td>
    <td align="center"><img src="screenshots/booked%20traing%20screen.jpg" alt="Booking details" width="250"><br><sub>Booking confirmed and paid</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/chat%20screen.jpg" alt="Group chat" width="250"><br><sub>Chat with the coach and the group</sub></td>
    <td></td>
    <td></td>
  </tr>
</table>

### Creating a session (coach)

<table>
  <tr>
    <td align="center" width="33%"><img src="screenshots/new%20session%20screen.jpg" alt="New session form" width="250"><br><sub>Set up a new training session</sub></td>
    <td align="center" width="33%"><img src="screenshots/AI%20assistant%20screen.jpg" alt="AI voice assistant" width="250"><br><sub>Describe the session out loud and the AI fills the form for you</sub></td>
    <td align="center" width="33%"><img src="screenshots/training%20details.jpg" alt="Session details" width="250"><br><sub>Review the draft, then publish it</sub></td>
  </tr>
</table>

---

## ⚙️ Installation

Clone the repository

```bash
git clone https://github.com/elia48/SplitFit.git
cd SplitFit
```

Install dependencies

```bash
bundle install
```

Create the database

```bash
rails db:create
rails db:migrate
rails db:seed
```

Run the server

```bash
bin/dev
```

---

## 👥 Team

Built by:

- Elia Mangano
- Juan Xavier Espinar

---

## 🎓 About

SplitFit was developed during the **Le Wagon Web Development Bootcamp** as a collaborative full-stack project, covering the complete product development lifecycle—from ideation and design to deployment.

---

## 📄 License

This project is intended for educational and portfolio purposes.
