# SkillTrack Pro - Backend API Documentation

**Version:** 1.0.0  
**Project Name:** SkillTrack Pro - An Excelerate Learning Management System

---

## Table of Contents

1. [Overview](#overview)
2. [Environment Setup](#environment-setup)
3. [Authentication](#authentication)
4. [Base URLs](#base-urls)
5. [API Endpoints](#api-endpoints)
   - [Authentication Routes](#authentication-routes)
   - [Learner Routes](#learner-routes)
   - [Mentor Routes](#mentor-routes)
   - [Admin Routes](#admin-routes)
   - [Notification Routes](#notification-routes)
   - [Health Check Routes](#health-check-routes)
6. [How to Run cURL Commands](#how-to-run-curl-commands)
7. [Error Handling](#error-handling)
8. [Rate Limiting](#rate-limiting)

---

## Overview

**SkillTrack Pro** is a comprehensive Learning Management System (LMS) designed to facilitate skill development through structured programs. The system supports three main user roles:

- **Learners:** Access programs, submit tasks, and receive feedback
- **Mentors:** Create programs, review submissions, and provide feedback
- **Admins:** Manage users, programs, and system analytics

The backend API is built with **Node.js**, **Express.js**, and **PostgreSQL**, providing robust authentication, role-based access control, and real-time notifications.

### Key Features

- ✅ JWT-based authentication with role-based access control
- ✅ Program management with hierarchical structure (Programs → Milestones → Chapters → Tasks)
- ✅ Task submission and review workflow
- ✅ Real-time notifications system
- ✅ Comprehensive audit logging
- ✅ Performance analytics and learner ranking
- ✅ Password reset functionality
- ✅ CORS-enabled for multi-client support

---

## Environment Setup

### Prerequisites

- Node.js (v18+)
- PostgreSQL (v12+)
- npm or yarn

### Installation & Local Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd Team11-Excelerate-Flutter-Project/backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Create `.env` file:**
   Create a file named `.env` in the `backend/` directory:

   ```env
   # Server Configuration
   NODE_ENV=development
   PORT=3000

   # Database
   DATABASE_URL=postgresql://username:password@localhost:5432/skilltrack_pro

   # JWT Configuration
   JWT_SECRET=your_jwt_secret_key_here_min_32_chars
   JWT_EXPIRES_IN=7d

   # Password Reset
   RESET_TOKEN_EXPIRES_MINUTES=30
   FRONTEND_RESET_URL=http://localhost:3001/reset/

   # Deadline Notifications
   DEADLINE_ALERTS_ENABLED=true
   DEADLINE_ALERT_HOURS=24
   DEADLINE_ALERT_INTERVAL_MINUTES=10
   ```

4. **Setup Database:**
   ```bash
   npm run migrate
   npm run seed
   ```

5. **Start development server:**
   ```bash
   npm run dev
   ```

   The API will be available at `http://localhost:3000`

---

## Base URLs

### Production (Deployed)
```
https://team11-excelerate-flutter-project.vercel.app
```

### Local Development
```
http://localhost:3000
```

---

## Authentication

### JWT Token Format

The API uses **JSON Web Tokens (JWT)** for authentication. Every request (except login/signup) must include the token in the `Authorization` header:

```
Authorization: Bearer <your_jwt_token>
```

### Token Structure

```json
{
  "sub": "user-id-uuid",
  "role": "learner|mentor|admin",
  "email": "user@example.com",
  "iat": 1704067200,
  "exp": 1704672000
}
```

### Token Expiration

Tokens expire after **7 days** by default. Users must log in again to obtain a new token.

---

## API Endpoints

---

## Authentication Routes

Base Path: `/auth`

### 1. User Login

**Endpoint:** `POST /auth/login`

**Description:** Authenticate a user and receive a JWT token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "role": "learner",
    "fullName": "John Doe"
  }
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid credentials

**cURL Example:**
```bash
# Production
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "learner@example.com",
    "password": "password123"
  }'

# Local
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "learner@example.com",
    "password": "password123"
  }'
```

---

### 2. User Signup

**Endpoint:** `POST /auth/signup`

**Description:** Register a new learner account.

**Request Body:**
```json
{
  "fullName": "Jane Smith",
  "email": "jane@example.com",
  "password": "securePassword123"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "email": "jane@example.com",
    "role": "learner",
    "fullName": "Jane Smith"
  }
}
```

**Error Responses:**
- `409 Conflict` - Email already registered

**cURL Example:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Jane Smith",
    "email": "jane@example.com",
    "password": "securePassword123"
  }'
```

---

### 3. Get Current User

**Endpoint:** `GET /auth/me`

**Description:** Retrieve the authenticated user's profile.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "role": "learner",
    "fullName": "John Doe"
  }
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - User not found

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 4. Request Password Reset

**Endpoint:** `POST /auth/request-password-reset`

**Description:** Request a password reset token (sent via email in production).

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "ok": true
}
```

**Development Response (includes reset token):**
```json
{
  "ok": true,
  "dev": {
    "resetToken": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
    "resetEndpoint": "/auth/reset-password"
  }
}
```

**cURL Example:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/request-password-reset \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com"
  }'
```

---

### 5. Reset Password

**Endpoint:** `POST /auth/reset-password`

**Description:** Reset user password using the reset token.

**Request Body:**
```json
{
  "token": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
  "newPassword": "newSecurePassword456"
}
```

**Response (200 OK):**
```json
{
  "ok": true
}
```

**Error Responses:**
- `400 Bad Request` - Invalid or expired token

**cURL Example:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "reset_token_here",
    "newPassword": "newPassword123"
  }'
```

---

## Learner Routes

Base Path: `/learner`

**Required Role:** `learner`

### 1. Get Learner Dashboard

**Endpoint:** `GET /learner/dashboard`

**Description:** Get overview of learner's active programs and task statistics.

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "activePrograms": [
    {
      "id": "prog-001",
      "title": "Web Development Bootcamp",
      "description": "Learn modern web development"
    }
  ],
  "pendingTasks": 5,
  "approvedTasks": 12,
  "completionPercentage": 71
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 2. Get Enrolled Programs

**Endpoint:** `GET /learner/programs`

**Description:** List all programs the learner is enrolled in (paginated).

**Query Parameters:**
- `limit` (optional, max 50, default 20): Number of results
- `offset` (optional, default 0): Pagination offset

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "prog-001",
      "title": "Web Development Bootcamp",
      "description": "Learn modern web development",
      "mentor_id": "mentor-001"
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET "https://team11-excelerate-flutter-project.vercel.app/learner/programs?limit=10&offset=0" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 3. Get Available Programs

**Endpoint:** `GET /learner/programs/available`

**Description:** List all programs available for enrollment.

**Query Parameters:**
- `limit` (optional, max 50, default 20)
- `offset` (optional, default 0)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "prog-002",
      "title": "Python Fundamentals",
      "description": "Master Python basics",
      "mentor_id": "mentor-002",
      "mentor_name": "Alice Johnson"
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET "https://team11-excelerate-flutter-project.vercel.app/learner/programs/available" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 4. Enroll in Program

**Endpoint:** `POST /learner/programs/:programId/enroll`

**Description:** Enroll the learner in a program.

**Path Parameters:**
- `programId` (required): UUID of the program

**Response (201 Created):**
```json
{
  "ok": true,
  "program": {
    "id": "prog-002",
    "title": "Python Fundamentals"
  }
}
```

**Error Responses:**
- `404 Not Found` - Program not found
- `409 Conflict` - Already enrolled

**cURL Example:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-002/enroll \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

---

### 5. Get Program Milestones

**Endpoint:** `GET /learner/programs/:programId/milestones`

**Description:** Retrieve all milestones for a program.

**Path Parameters:**
- `programId` (required)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "mile-001",
      "title": "Foundations",
      "sort_order": 0
    },
    {
      "id": "mile-002",
      "title": "Intermediate Concepts",
      "sort_order": 1
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-001/milestones \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 6. Get Module Chapters

**Endpoint:** `GET /learner/programs/:programId/modules/:moduleId/chapters`

**Description:** Retrieve chapters for a specific module/milestone.

**Path Parameters:**
- `programId` (required)
- `moduleId` (required): Same as milestone ID

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "chap-001",
      "title": "Introduction to Web Development",
      "sort_order": 0,
      "body_md": "# Chapter Content\nMarkdown formatted content here..."
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-001/modules/mile-001/chapters \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 7. Get Program Tasks

**Endpoint:** `GET /learner/programs/:programId/tasks`

**Description:** Get all tasks for a program (optionally filtered by milestone).

**Query Parameters:**
- `milestoneId` (optional): Filter by specific milestone
- `limit` (optional, default 20, max 50)
- `offset` (optional, default 0)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "task-001",
      "milestone_id": "mile-001",
      "title": "Setup Development Environment",
      "deadline_at": "2024-02-15T23:59:59Z",
      "submission_status": "approved",
      "score": 95
    },
    {
      "id": "task-002",
      "milestone_id": "mile-001",
      "title": "Build First Web Page",
      "deadline_at": "2024-02-22T23:59:59Z",
      "submission_status": "not_submitted",
      "score": null
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET "https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-001/tasks?milestoneId=mile-001" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 8. Get Program Progress

**Endpoint:** `GET /learner/programs/:programId/progress`

**Description:** Get learner's progress statistics for a program.

**Path Parameters:**
- `programId` (required)

**Response (200 OK):**
```json
{
  "programId": "prog-001",
  "total_tasks": 15,
  "pending": 3,
  "approved": 10,
  "rejected": 2,
  "completionPercentage": 67
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-001/progress \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 9. Get Task Details

**Endpoint:** `GET /learner/tasks/:taskId`

**Description:** Get detailed information about a specific task.

**Path Parameters:**
- `taskId` (required)

**Response (200 OK):**
```json
{
  "task": {
    "id": "task-001",
    "program_id": "prog-001",
    "milestone_id": "mile-001",
    "title": "Setup Development Environment",
    "description": "Install required tools and configure your dev environment",
    "deadline_at": "2024-02-15T23:59:59Z",
    "resource_links": ["https://example.com/guide", "https://example.com/tutorial"],
    "submission_id": "sub-001",
    "submission_link": "https://github.com/user/project",
    "submission_notes": "Completed all steps",
    "submission_status": "approved",
    "feedback_text": "Great job!",
    "score": 95
  }
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/tasks/task-001 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 10. Submit Task

**Endpoint:** `POST /learner/tasks/:taskId/submit`

**Description:** Submit a task solution.

**Path Parameters:**
- `taskId` (required)

**Request Body:**
```json
{
  "link": "https://github.com/user/project-repo",
  "notes": "I completed all requirements and tested thoroughly"
}
```

**Response (200 OK):**
```json
{
  "submission": {
    "id": "sub-001",
    "status": "submitted"
  }
}
```

**Error Responses:**
- `403 Forbidden` - Not enrolled in program
- `404 Not Found` - Task not found
- `409 Conflict` - Already submitted

**cURL Example:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/learner/tasks/task-001/submit \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "link": "https://github.com/user/project",
    "notes": "Completed all requirements"
  }'
```

---

### 11. Get Program Review Eligibility

**Endpoint:** `GET /learner/programs/:programId/review`

**Description:** Check if learner is eligible to review program (all tasks approved).

**Path Parameters:**
- `programId` (required)

**Response (200 OK):**
```json
{
  "programId": "prog-001",
  "totalTasks": 15,
  "approvedTasks": 15,
  "eligible": true,
  "review": {
    "id": "rev-001",
    "rating": 5,
    "feedback": "Excellent program!",
    "created_at": "2024-02-20T10:30:00Z"
  }
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-001/review \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 12. Submit Program Review

**Endpoint:** `POST /learner/programs/:programId/review`

**Description:** Submit a rating and feedback for a completed program.

**Path Parameters:**
- `programId` (required)

**Request Body:**
```json
{
  "rating": 5,
  "feedback": "Excellent program with clear instructions and supportive mentors!"
}
```

**Response (201 Created):**
```json
{
  "review": {
    "id": "rev-001",
    "rating": 5,
    "feedback": "Excellent program with clear instructions and supportive mentors!",
    "created_at": "2024-02-20T10:30:00Z"
  }
}
```

**Error Responses:**
- `403 Forbidden` - Not enrolled
- `404 Not Found` - Program not found
- `409 Conflict` - Not all tasks approved or already reviewed

**cURL Example:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-001/review \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "feedback": "Excellent program!"
  }'
```

---

### 13. Get Learner Performance Report

**Endpoint:** `GET /learner/performance-report`

**Description:** Get learner's overall performance statistics.

**Response (200 OK):**
```json
{
  "report": {
    "approved": 18,
    "rejected": 2,
    "pending": 5,
    "average_score": "87.50"
  }
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/performance-report \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Mentor Routes

Base Path: `/mentor`

**Required Role:** `mentor`

### 1. Get Mentor's Programs

**Endpoint:** `GET /mentor/programs`

**Description:** List all programs created by the mentor.

**Query Parameters:**
- `limit` (optional, default 20, max 50)
- `offset` (optional, default 0)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "prog-001",
      "title": "Web Development Bootcamp",
      "description": "Learn modern web development",
      "created_at": "2024-01-01T10:00:00Z",
      "learner_count": 25,
      "task_count": 12
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/mentor/programs \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 2. Get Program Overview

**Endpoint:** `GET /mentor/programs/:programId/overview`

**Description:** Get detailed overview of a program with learners and tasks.

**Path Parameters:**
- `programId` (required)

**Response (200 OK):**
```json
{
  "programId": "prog-001",
  "learners": [
    {
      "id": "learner-001",
      "full_name": "John Doe",
      "email": "john@example.com"
    }
  ],
  "tasks": [
    {
      "id": "task-001",
      "title": "Setup Environment",
      "deadline_at": "2024-02-15T23:59:59Z",
      "submissions": 25,
      "pending": 2,
      "approved": 20,
      "rejected": 3
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/mentor/programs/prog-001/overview \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 3. Get Program Reviews

**Endpoint:** `GET /mentor/programs/:programId/reviews`

**Description:** Get all reviews for a program.

**Query Parameters:**
- `limit` (optional, default 20, max 50)
- `offset` (optional, default 0)

**Response (200 OK):**
```json
{
  "summary": {
    "totalReviews": 15,
    "averageRating": "4.67"
  },
  "items": [
    {
      "id": "rev-001",
      "rating": 5,
      "feedback": "Excellent program!",
      "created_at": "2024-02-20T10:30:00Z",
      "learner_id": "learner-001",
      "learner_name": "John Doe",
      "learner_email": "john@example.com"
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/mentor/programs/prog-001/reviews \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 4. Get Mentor Dashboard

**Endpoint:** `GET /mentor/dashboard`

**Description:** Get mentor's overview with assigned learners, pending reviews, and programs.

**Response (200 OK):**
```json
{
  "assignedLearners": [
    {
      "id": "learner-001",
      "full_name": "John Doe",
      "email": "john@example.com"
    }
  ],
  "pendingReviews": 7,
  "programs": [
    {
      "id": "prog-001",
      "title": "Web Development Bootcamp",
      "learner_count": 25,
      "task_count": 12
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/mentor/dashboard \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 5. Get Submissions

**Endpoint:** `GET /mentor/submissions`

**Description:** Get all submissions for the mentor's programs (optionally filtered by status).

**Query Parameters:**
- `status` (optional): Filter by status (`submitted`, `approved`, `rejected`)
- `limit` (optional, default 20, max 50)
- `offset` (optional, default 0)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "sub-001",
      "status": "submitted",
      "link": "https://github.com/user/project",
      "notes": "Completed all requirements",
      "score": null,
      "feedback_text": null,
      "created_at": "2024-02-15T15:30:00Z",
      "learner_id": "learner-001",
      "learner_name": "John Doe",
      "task_id": "task-001",
      "task_title": "Setup Environment"
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET "https://team11-excelerate-flutter-project.vercel.app/mentor/submissions?status=submitted" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 6. Get Submission Details

**Endpoint:** `GET /mentor/submissions/:submissionId`

**Description:** Get detailed information about a specific submission.

**Path Parameters:**
- `submissionId` (required)

**Response (200 OK):**
```json
{
  "submission": {
    "id": "sub-001",
    "status": "submitted",
    "link": "https://github.com/user/project",
    "notes": "Completed all requirements",
    "score": null,
    "feedback_text": null,
    "created_at": "2024-02-15T15:30:00Z",
    "reviewed_at": null,
    "learner_id": "learner-001",
    "learner_name": "John Doe",
    "learner_email": "john@example.com",
    "task_id": "task-001",
    "task_title": "Setup Environment",
    "deadline_at": "2024-02-18T23:59:59Z",
    "program_id": "prog-001",
    "program_title": "Web Development Bootcamp"
  }
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/mentor/submissions/sub-001 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 7. Review Submission

**Endpoint:** `POST /mentor/submissions/:submissionId/review`

**Description:** Approve or reject a submission with feedback and score.

**Path Parameters:**
- `submissionId` (required)

**Request Body:**
```json
{
  "decision": "approved",
  "feedbackText": "Great work! Your setup is correct and follows best practices.",
  "score": 95
}
```

**Response (200 OK):**
```json
{
  "submission": {
    "id": "sub-001",
    "status": "approved",
    "learner_id": "learner-001",
    "task_id": "task-001"
  }
}
```

**Error Responses:**
- `404 Not Found` - Submission not found

**cURL Example:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/mentor/submissions/sub-001/review \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "decision": "approved",
    "feedbackText": "Excellent work!",
    "score": 90
  }'
```

---

### 8. Get Learner Timeline

**Endpoint:** `GET /mentor/learners/:learnerId/timeline`

**Description:** Get submission history for a specific learner.

**Path Parameters:**
- `learnerId` (required)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "sub-001",
      "status": "approved",
      "score": 95,
      "feedback_text": "Great work!",
      "created_at": "2024-02-15T15:30:00Z",
      "reviewed_at": "2024-02-16T10:00:00Z",
      "task_id": "task-001",
      "task_title": "Setup Environment",
      "deadline_at": "2024-02-18T23:59:59Z"
    }
  ]
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/mentor/learners/learner-001/timeline \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Admin Routes

Base Path: `/admin`

**Required Role:** `admin`

### 1. Get Audit Logs

**Endpoint:** `GET /admin/audit-logs`

**Description:** Retrieve audit logs for all system activities.

**Query Parameters:**
- `actorUserId` (optional): Filter by specific user
- `limit` (optional, default 20, max 50)
- `offset` (optional, default 0)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "log-001",
      "actor_user_id": "user-001",
      "actor_name": "John Doe",
      "action": "learner.submit_task",
      "entity_type": "submission",
      "entity_id": "sub-001",
      "meta": {"taskId": "task-001"},
      "created_at": "2024-02-15T15:30:00Z"
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/admin/audit-logs \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### 2. Get All Programs

**Endpoint:** `GET /admin/programs`

**Description:** List all programs in the system.

**Query Parameters:**
- `limit` (optional, default 20, max 50)
- `offset` (optional, default 0)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "prog-001",
      "title": "Web Development Bootcamp",
      "description": "Learn modern web development",
      "mentor_id": "mentor-001",
      "mentor_name": "Jane Smith",
      "created_at": "2024-01-01T10:00:00Z"
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/admin/programs \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Notification Routes

Base Path: `/notifications`

**Required Role:** All authenticated users

### 1. Get Notifications

**Endpoint:** `GET /notifications`

**Description:** Get user's notifications with pagination.

**Query Parameters:**
- `limit` (optional, default 20, max 50)
- `offset` (optional, default 0)

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": "notif-001",
      "type": "submission_reviewed",
      "title": "Submission Reviewed",
      "body": "Your submission was reviewed.",
      "meta": {
        "submissionId": "sub-001",
        "taskId": "task-001",
        "status": "approved"
      },
      "read_at": null,
      "created_at": "2024-02-16T10:00:00Z"
    }
  ],
  "limit": 20,
  "offset": 0
}
```

**cURL Example:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/notifications \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Health Check Routes

### 1. Basic Health Check

**Endpoint:** `GET /health`

**Description:** Check if API is running.

**Response (200 OK):**
```json
{
  "ok": true
}
```

**cURL Example:**
```bash
curl https://team11-excelerate-flutter-project.vercel.app/health
```

---

### 2. Database Health Check

**Endpoint:** `GET /health/db`

**Description:** Check if API can connect to database.

**Response (200 OK):**
```json
{
  "ok": true,
  "db": true
}
```

**Error Response (503):**
```json
{
  "ok": false,
  "db": false
}
```

**cURL Example:**
```bash
curl https://team11-excelerate-flutter-project.vercel.app/health/db
```

---

## How to Run cURL Commands

### Prerequisites

- **Windows:** cURL is built-in with Windows 10+. Open Command Prompt or PowerShell.
- **Mac/Linux:** cURL is usually pre-installed. Open Terminal.

### Basic cURL Syntax

```bash
curl [OPTIONS] <URL>
```

### Common Options

| Option | Description |
|--------|-------------|
| `-X` | HTTP method (GET, POST, PUT, DELETE, etc.) |
| `-H` | Add custom header |
| `-d` | Request body (for POST/PUT requests) |
| `-i` | Include response headers in output |
| `-v` | Verbose (show request and response details) |

### Step-by-Step Guide

#### **Step 1: Get a JWT Token (Login)**

Open Command Prompt/Terminal and run:

```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\": \"learner@example.com\", \"password\": \"password123\"}"
```

**Note:** On Linux/Mac, use `\` for line continuation. On Windows, use `^`.

**Output:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {...}
}
```

#### **Step 2: Copy the Token**

Take the token value from the response (without quotes).

#### **Step 3: Use Token in Subsequent Requests**

```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Error Handling

All errors are returned in the following format:

```json
{
  "error": {
    "message": "Error description"
  }
}
```

### Common HTTP Status Codes

| Code | Meaning |
|------|---------|
| `200` | OK - Request successful |
| `201` | Created - Resource successfully created |
| `400` | Bad Request - Invalid input |
| `401` | Unauthorized - Invalid or missing token |
| `403` | Forbidden - Insufficient permissions |
| `404` | Not Found - Resource doesn't exist |
| `409` | Conflict - Resource already exists |
| `500` | Internal Server Error |
| `503` | Service Unavailable - Database error |

---

## Rate Limiting

The API implements standard rate limiting:
- **Default limit:** 100 requests per minute per IP
- **Admin limit:** 500 requests per minute

Requests exceeding the limit will receive a `429 Too Many Requests` response.

---

**Last Updated:** January 2026  
**API Version:** 1.0.0  
**Status:** Production Ready
