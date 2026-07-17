Technical Massage Center Management System (MVP + Scalable)

You are a senior full-stack software architect.

Build a real, production-ready but lightweight Technical Massage Center Management System for a small clinic. The system must be clean, scalable, and easy to maintain.

Focus on core daily operations only. Remove unnecessary complex enterprise features.

⸻

🧠 Technology Stack

Frontend

* Flutter (Web + Mobile Responsive)
* Material Design 3
* Riverpod or Provider (state management)
* GoRouter (navigation)

Backend

* Python FastAPI
* SQLAlchemy ORM
* JWT Authentication
* Pydantic validation
* REST API (modular structure)

Database

* PostgreSQL

⸻

🔐 Authentication (Simplified)

Users log in using:

* Username
* Password

Requirements:

* BCrypt password hashing
* JWT authentication
* Login / Logout
* Role-based access

⸻

👥 User Roles

1. Admin

* Manage users
* Manage patients
* Manage appointments
* View dashboard

2. Doctor

* View patients
* Create diagnosis
* Create treatment plans
* Add session notes
* View appointments

3. Staff (Read Only)

* View patients
* View appointments
* View treatment plans

⸻

🧍 Patient Management (SIMPLIFIED + IMPROVED SEARCH)

Store patient information:

Fields:

* Patient ID
* Full Name
* Phone Number ⭐
* Gender
* Age
* Address
* Medical Notes (optional)
* Registration Date

🔍 IMPORTANT FEATURE (Optimized Search)

* Search patient by:
    * Phone Number ⭐ (PRIMARY SEARCH METHOD)
    * Patient ID
    * Name (optional fallback)

Features:

* Add patient
* Edit patient
* View patient profile
* Delete patient (Admin only)

⸻

📅 Appointment Management (Simplified)

Features:

* Create appointment
* Update appointment
* Cancel appointment

Fields:

* Patient
* Doctor
* Date
* Time
* Status:
    * Scheduled
    * Completed
    * Cancelled

⸻

🩺 Diagnosis Module

Doctor can:

* Create diagnosis
* Add symptoms
* Add recommendations

Each diagnosis is linked to a patient.

⸻

💆 Treatment Plan (Simplified)

Fields:

* Treatment Name
* Number of Sessions
* Start Date
* End Date
* Status:
    * Active
    * Completed

⸻

📝 Session Notes

After each session doctor records:

* Date
* Patient response
* Pain level (1–10)
* Notes
* Next recommendation

⸻

💳 Payment Module (Simplified)

Fields:

* Patient
* Amount
* Payment Method:
    * Cash
    * Mobile Money
* Status:
    * Paid
    * Unpaid

⸻

📊 Dashboard (Core Only)

Show:

* Total Patients
* Today’s Appointments
* Monthly Appointments
* Total Income
* Unpaid Patients
* Active Treatments

Use:

* Cards
* Simple tables

⸻

🔎 Global Search (Important)

Search across:

* Patients (phone number priority ⭐)
* Appointments
* Treatment Plans

Must be fast and optimized.

⸻

📱 UI Requirements

* Clean Material Design 3
* Responsive (mobile + desktop)
* Light & Dark mode
* Sidebar (desktop)
* Drawer (mobile)

⸻

🔐 Security (Core Only)

* JWT Authentication
* Role-based access control
* Password hashing (bcrypt)
* Input validation
* Basic rate limiting

⸻

🗄️ Database Design (Simplified)

Tables:

* users
* patients
* appointments
* diagnoses
* treatment_plans
* session_notes
* payments

Relationships must be normalized but not over-engineered.

⸻

📦 Remove These (IMPORTANT)

Do NOT include:

* Reports export (PDF/Excel)
* Audit logs system
* Notifications system
* Advanced analytics dashboards
* Complex income charts
* Doctor activity tracking
* Full enterprise logging system
* Email/SMS systems
* Over-complicated permissions system

⸻

🚀 Output Requirements

Generate:

1. FastAPI backend (modular)
2. Flutter frontend (clean UI)
3. PostgreSQL schema
4. JWT authentication system
5. Basic CRUD APIs
6. Clean project structure
7. Simple seed data
8. Docker setup (optional but recommended)

⸻

🎯 Goal

Build a real working system for daily use in a massage center that is:

* Simple
* Fast
* Easy to maintain
* Production-ready
* Not over-engineered