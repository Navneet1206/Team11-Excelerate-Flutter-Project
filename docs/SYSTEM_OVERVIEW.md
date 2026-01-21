# SkillTrack Pro - System Overview & Architecture

**Complete system design, database schema, and workflow documentation**

---

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Technology Stack](#technology-stack)
3. [Database Schema](#database-schema)
4. [Authentication Flow](#authentication-flow)
5. [Core Workflows](#core-workflows)
6. [Role-Based Access Control](#role-based-access-control)
7. [Deployment Architecture](#deployment-architecture)

---

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND LAYER                           │
│                   (Flutter Mobile App)                          │
│                                                                 │
│  • UI Components  • State Management  • Secure Storage         │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP/REST
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                       API GATEWAY LAYER                         │
│              (Node.js Express Server - Vercel)                  │
│                                                                 │
│  • Authentication  • Validation  • Error Handling              │
│  • Authorization   • Logging     • Rate Limiting               │
└─────────────┬──────────────┬──────────────┬────────────────────┘
              │              │              │
              ↓              ↓              ↓
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ Auth Routes  │ │Business Logic│ │Notification │
    │  (JWT, 2FA)  │ │   (Services) │ │   (Realtime)│
    └──────────────┘ └──────────────┘ └──────────────┘
              │              │              │
              └──────────────┬──────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                   DATA PERSISTENCE LAYER                        │
│                 (PostgreSQL Database)                           │
│                                                                 │
│  • 11+ Tables  • Relationships  • Transactions                 │
│  • Migrations  • Seed Data      • Audit Logs                   │
└─────────────────────────────────────────────────────────────────┘
```

### Component Breakdown

#### Frontend (Flutter)
- Mobile-first responsive design
- Native platform features (camera, storage)
- Secure token storage
- Offline capabilities

#### Backend API (Node.js/Express)
- RESTful API design
- Request validation with Zod
- JWT authentication
- Error handling with custom middleware
- Comprehensive logging

#### Database (PostgreSQL)
- ACID-compliant transactions
- Complex relationships
- Migration versioning
- Audit trail logging

---

## Technology Stack

### Backend
- **Runtime:** Node.js v18+
- **Framework:** Express.js
- **Database:** PostgreSQL 12+
- **Authentication:** JWT (JSON Web Tokens)
- **Password Hashing:** bcryptjs
- **Input Validation:** Zod
- **Security:** Helmet.js, CORS
- **Deployment:** Vercel

### Frontend
- **Framework:** Flutter 3.x
- **Language:** Dart
- **State Management:** Provider/Riverpod
- **HTTP Client:** http package
- **Secure Storage:** flutter_secure_storage
- **Routing:** go_router

### Development Tools
- **Package Manager:** npm
- **Environment:** dotenv
- **Dev Server:** nodemon
- **Database Migrations:** Custom migration system
- **API Testing:** cURL, Postman

---

## Database Schema

### Tables Overview

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL, -- learner, mentor, admin
  created_at TIMESTAMP DEFAULT NOW()
);

-- Programs table
CREATE TABLE programs (
  id UUID PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  mentor_id UUID FOREIGN KEY REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Milestones (Program Modules)
CREATE TABLE milestones (
  id UUID PRIMARY KEY,
  program_id UUID FOREIGN KEY,
  title VARCHAR(255) NOT NULL,
  sort_order INTEGER,
  created_at TIMESTAMP
);

-- Module Chapters
CREATE TABLE module_chapters (
  id UUID PRIMARY KEY,
  milestone_id UUID FOREIGN KEY,
  title VARCHAR(255) NOT NULL,
  body_md TEXT, -- Markdown content
  sort_order INTEGER,
  created_at TIMESTAMP
);

-- Tasks
CREATE TABLE tasks (
  id UUID PRIMARY KEY,
  program_id UUID FOREIGN KEY,
  milestone_id UUID FOREIGN KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  deadline_at TIMESTAMP,
  resource_links TEXT[], -- Array of URLs
  created_at TIMESTAMP
);

-- Program Learners (Enrollment)
CREATE TABLE program_learners (
  id UUID PRIMARY KEY,
  program_id UUID FOREIGN KEY,
  learner_id UUID FOREIGN KEY,
  enrolled_at TIMESTAMP,
  UNIQUE(program_id, learner_id)
);

-- Task Submissions
CREATE TABLE submissions (
  id UUID PRIMARY KEY,
  task_id UUID FOREIGN KEY,
  learner_id UUID FOREIGN KEY,
  link VARCHAR(2048), -- Repository/submission URL
  notes TEXT,
  status VARCHAR(50), -- submitted, approved, rejected
  score INTEGER,
  feedback_text TEXT,
  created_at TIMESTAMP,
  reviewed_at TIMESTAMP,
  UNIQUE(task_id, learner_id)
);

-- Program Reviews
CREATE TABLE program_reviews (
  id UUID PRIMARY KEY,
  program_id UUID FOREIGN KEY,
  learner_id UUID FOREIGN KEY,
  rating INTEGER (1-5),
  feedback TEXT,
  created_at TIMESTAMP,
  UNIQUE(program_id, learner_id)
);

-- Notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  user_id UUID FOREIGN KEY,
  type VARCHAR(100),
  title VARCHAR(255),
  body TEXT,
  meta JSONB, -- Flexible metadata
  read_at TIMESTAMP,
  created_at TIMESTAMP
);

-- Audit Logs
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY,
  actor_user_id UUID FOREIGN KEY,
  action VARCHAR(100),
  entity_type VARCHAR(100),
  entity_id UUID,
  meta JSONB,
  created_at TIMESTAMP
);

-- Password Resets
CREATE TABLE password_resets (
  id UUID PRIMARY KEY,
  user_id UUID FOREIGN KEY,
  token VARCHAR(255) UNIQUE,
  expires_at TIMESTAMP,
  created_at TIMESTAMP
);
```

### Relationships Diagram

```
users (1) ──────────────── (many) programs
  │                            │
  │ (1 as mentor)              │
  │                            (1)
  │                            │
  │          milestones ◄──────┘
  │              │
  │              (1)
  │              │
  │          module_chapters
  │
  ├──────────────────────────┐
  │                          │
  │ (1 as learner)           │ (1 as reviewer)
  │ (many)                   │
  │  │                       │
  │  ▼                       │
program_learners         program_reviews
  │                       │
  │ (many)                │ (many)
  │  │                    │
  │  ├─────────────┬──────┘
  │              │
  │              ▼
  │          tasks
  │            │
  │            │ (1 to many)
  │            ▼
  │        submissions
  │
  ├────────────────────────────┐
  │                            │
  │ (1 to many)                │ (1 to many)
  │  │                         │
  │  ▼                         ▼
notifications              audit_logs


password_resets (many) ──── (1) users
```

---

## Authentication Flow

### JWT Authentication

```
┌─────────────────────────────────────────────────────────────┐
│ USER CREDENTIALS                                            │
│ Email: user@example.com                                     │
│ Password: SecurePass123                                     │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │ POST /auth/login     │
        └──────────────────────┘
                   │
                   ▼
        ┌──────────────────────────────────────────┐
        │ Verify Email & Password                  │
        │ - Query database for user               │
        │ - Compare bcrypt hashes                 │
        └──────────────────────────────────────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
    Valid              Invalid
     │                   │
     ▼                   ▼
┌─────────────┐    ┌──────────────┐
│ Generate    │    │ Return 401   │
│ JWT Token   │    │ Unauthorized │
└────┬────────┘    └──────────────┘
     │
     ▼
┌────────────────────────────────────────┐
│ JWT Token Structure                    │
│ ├─ Header: {alg: HS256, typ: JWT}     │
│ ├─ Payload: {sub, role, email, exp}   │
│ └─ Signature: HMAC-SHA256(secret)     │
└────────┬───────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────────┐
    │ Return to Client                        │
    │ {token: "eyJhbGci...", user: {...}}    │
    └─────────────────────────────────────────┘
         │
         ▼
    ┌──────────────────────────────────────┐
    │ Client Stores Token (Secure Storage) │
    └──────────────────────────────────────┘
         │
         ▼
    ┌────────────────────────────────────────────┐
    │ Future Protected Requests                  │
    │ Header: Authorization: Bearer <token>     │
    └────────────────────────────────────────────┘
         │
         ▼
    ┌────────────────────────────────────────────┐
    │ Server Validates Token                     │
    │ - Verify signature                         │
    │ - Check expiration (7 days)               │
    │ - Extract user role & ID                  │
    └────────────────────────────────────────────┘
```

---

## Core Workflows

### Workflow 1: Learner Enrollment & Learning

```
┌──────────────────┐
│ Learner Signs Up │
└────────┬─────────┘
         │
         ▼
┌────────────────────────────┐
│ Browse Available Programs  │
│ GET /learner/programs/available
└────────┬───────────────────┘
         │
         ▼
┌──────────────────┐
│ Enroll Program   │
│ POST /learner/programs/{id}/enroll
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────┐
│ View Program Structure           │
│ - Milestones                     │
│ - Chapters                       │
│ - Tasks                          │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ Complete Tasks & Submit        │
│ POST /learner/tasks/{id}/submit│
└────────┬──────────────────────┘
         │
         ▼
    ┌────────────┬────────────┐
    │            │            │
    ▼            ▼            ▼
Approved    Rejected    Pending
(Score)    (Feedback)  (Waiting)
    │            │            │
    └────────┬───┴────────┬───┘
             │            │
             ▼            ▼
        May Retry    Review Again
             │            │
             └────┬───────┘
                  ▼
         All Tasks Approved?
                  │
         ┌────────┴────────┐
         │                 │
        Yes               No
         │                 │
         ▼                 ▼
    ┌───────────┐    Continue
    │   Eligible│    Learning
    │   Review  │
    └─────┬─────┘
          │
          ▼
    ┌──────────────────┐
    │ Submit Program   │
    │ Review (Rating)  │
    └──────────────────┘
```

### Workflow 2: Mentor Review & Feedback

```
┌────────────────────────────┐
│ Learner Submits Task       │
│ POST /learner/tasks/submit │
└────────┬───────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Mentor Receives Notification     │
│ "New submission to review"       │
└────────┬───────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│ Mentor Reviews Submissions      │
│ GET /mentor/submissions?status=submitted
└────────┬──────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ View Submission Details      │
│ - Code/Link                  │
│ - Learner Notes              │
│ - Deadline Status            │
└────────┬─────────────────────┘
         │
         ▼
    ┌────────────┬──────────────┐
    │            │              │
    ▼            ▼              ▼
APPROVE      REJECT         COMMENT
(Score)   (With Reason)   (For Help)
    │            │              │
    │            │              │
    └────┬───────┴──────┬───────┘
         │              │
         ▼              ▼
    ┌─────────────────────────┐
    │ POST /mentor/submissions│
    │ /{id}/review            │
    └────────┬────────────────┘
             │
             ▼
    ┌──────────────────────┐
    │ Update Submission    │
    │ Status & Score       │
    └────────┬─────────────┘
             │
             ▼
    ┌──────────────────────┐
    │ Send Notification    │
    │ to Learner           │
    └──────────────────────┘
```

### Workflow 3: Notification System

```
┌────────────────────┐
│ Event Triggered    │
│ - Submission      │
│ - Deadline        │
│ - Review Complete │
└────────┬───────────┘
         │
         ▼
┌──────────────────────────────┐
│ Determine Notification Type  │
│ - submission_reviewed        │
│ - task_deadline_alert        │
│ - learner_enrolled          │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Create Notification Record   │
│ INSERT INTO notifications... │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Target User Receives Alert   │
│ (Real-time via WebSocket)    │
└──────────────────────────────┘
```

---

## Role-Based Access Control

### Permission Matrix

| Permission | Learner | Mentor | Admin |
|-----------|---------|--------|-------|
| View available programs | ✅ | ✅ | ✅ |
| Enroll in programs | ✅ | ❌ | ✅ |
| Submit tasks | ✅ | ❌ | ❌ |
| Create programs | ❌ | ✅ | ✅ |
| Review submissions | ❌ | ✅ | ✅ |
| View all programs | ❌ | Own only | ✅ |
| Access audit logs | ❌ | ❌ | ✅ |
| Manage users | ❌ | ❌ | ✅ |
| View performance reports | ✅ (own) | ✅ (learners) | ✅ (all) |

### Middleware Flow

```
Request
   │
   ▼
┌──────────────────────┐
│ Auth Middleware      │
│ Verify JWT Token     │
└────────┬─────────────┘
         │
    ┌────┴────┐
    │          │
  Valid     Invalid
    │          │
    ▼          ▼
Extract    Return 401
User Role  Unauthorized
    │
    ▼
┌─────────────────────────────┐
│ Authorization Middleware    │
│ Check User Role Permission  │
└────────┬────────────────────┘
         │
    ┌────┴────┐
    │          │
Allowed    Forbidden
    │          │
    ▼          ▼
Proceed    Return 403
Forward    Forbidden
```

---

## Deployment Architecture

### Production Environment (Vercel)

```
┌─────────────────────────────────────────────────────┐
│ Vercel Deployment Platform                          │
│                                                     │
│ ┌───────────────────────────────────────────────┐  │
│ │ Node.js Server (Auto-scaling)                 │  │
│ │ - Git Connected Deployment                    │  │
│ │ - Automatic Environment Variables             │  │
│ │ - Built-in SSL/TLS                            │  │
│ │ - CDN Edge Caching                            │  │
│ └───────────────────────────────────────────────┘  │
│              │                    │                │
│              │ Connects to        │ Serves to      │
│              │                    │                │
│              ▼                    ▼                │
│    ┌──────────────────┐  ┌──────────────────┐   │
│    │ PostgreSQL Cloud  │  │ CDN Edge Nodes   │   │
│    │ (Managed DB)      │  │ (Global)         │   │
│    └──────────────────┘  └──────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
         │                          │
         │ Syncs with              │ Accessed by
         │                         │
         ▼                         ▼
    GitHub Repo         Client Applications
    (Source Code)       (Flutter App, Web)
```

### Local Development Environment

```
┌──────────────────────────────┐
│ Developer Machine            │
│                              │
│ ┌────────────────────────┐   │
│ │ Node.js Express Server │   │
│ │ (localhost:3000)       │   │
│ └────────┬───────────────┘   │
│          │                   │
│ ┌────────▼───────────────┐   │
│ │ PostgreSQL Database    │   │
│ │ (localhost:5432)       │   │
│ └────────────────────────┘   │
│                              │
└──────────────────────────────┘
         │
         │ Test with
         ▼
    cURL / Postman / Thunder Client
```

---

## API Routes Structure

```
/auth
  POST /login              - User login
  POST /signup             - User registration
  GET  /me                 - Get current user
  POST /request-password-reset
  POST /reset-password

/learner
  GET  /dashboard          - Learner overview
  GET  /programs           - Enrolled programs
  GET  /programs/available - Available programs
  POST /programs/:id/enroll
  GET  /programs/:id/milestones
  GET  /programs/:id/tasks
  GET  /programs/:id/progress
  GET  /tasks/:id          - Task details
  POST /tasks/:id/submit
  GET  /programs/:id/review
  POST /programs/:id/review

/mentor
  GET  /dashboard          - Mentor overview
  GET  /programs           - My programs
  GET  /programs/:id/overview
  GET  /programs/:id/reviews
  GET  /submissions        - All submissions
  GET  /submissions/:id    - Submission details
  POST /submissions/:id/review

/admin
  GET  /programs           - All programs
  GET  /audit-logs         - Activity logs

/notifications
  GET  /                   - Get notifications

/health
  GET  /                   - API status
  GET  /db                 - DB connection
```

---

**Continue reading:** [API Documentation](./API_DOCUMENTATION.md) | [Quick Start](./QUICK_START.md) | [cURL Guide](./CURL_GUIDE.md)
