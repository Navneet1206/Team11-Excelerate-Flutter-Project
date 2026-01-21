# API Testing Visual Guide

**Interactive workflows and visual examples for testing SkillTrack Pro API**

---

## Table of Contents

1. [Authentication Flow Diagram](#authentication-flow-diagram)
2. [Learner Journey](#learner-journey)
3. [Mentor Workflow](#mentor-workflow)
4. [Task Submission Lifecycle](#task-submission-lifecycle)
5. [Error Scenarios & Responses](#error-scenarios--responses)
6. [Response Code Matrix](#response-code-matrix)

---

## Authentication Flow Diagram

### Login Process

```
User Interface
    │
    │ Enter Email & Password
    ▼
┌─────────────────────────┐
│ POST /auth/login        │
│                         │
│ {                       │
│   "email": "...",       │
│   "password": "..."     │
│ }                       │
└────────────┬────────────┘
             │
             │ Request
             ▼
        ┌──────────────────────────┐
        │ Server Validates         │
        │ 1. Find user by email    │
        │ 2. Compare password hash │
        └────────┬─────────────────┘
                 │
         ┌───────┴───────┐
         │               │
      Valid           Invalid
         │               │
         ▼               ▼
    ┌─────────┐    ┌───────────────┐
    │ Generate│    │ 401 Error     │
    │ JWT     │    │ Unauthorized  │
    │ Token   │    └───────────────┘
    └────┬────┘
         │
         ▼
    ┌──────────────────────────┐
    │ Return Response          │
    │ {                        │
    │   "token": "eyJ...",     │
    │   "user": {              │
    │     "id": "...",         │
    │     "role": "learner"    │
    │   }                      │
    │ }                        │
    └────────┬─────────────────┘
             │
             │ Response
             ▼
    User Stores Token
    (Secure Storage)
```

### Token Usage

```
All Subsequent Requests
    │
    │ Add Header
    │ Authorization: Bearer <token>
    ▼
┌────────────────────────────┐
│ GET /learner/dashboard     │
│ Headers: {                 │
│   "Authorization":         │
│   "Bearer eyJ..."          │
│ }                          │
└────────┬───────────────────┘
         │
         ▼
    ┌───────────────────────────┐
    │ Server Middleware         │
    │ 1. Extract Token          │
    │ 2. Verify Signature       │
    │ 3. Check Expiration       │
    │ 4. Extract User ID & Role │
    └─────────┬─────────────────┘
              │
         ┌────┴────┐
         │          │
      Valid     Invalid
         │          │
         ▼          ▼
    Process    401/403 Error
    Request    
```

---

## Learner Journey

### Complete Learning Path with Examples

```
STEP 1: Sign Up
├─ POST /auth/signup
├─ Body: {
│   "fullName": "Jane Doe",
│   "email": "jane@example.com",
│   "password": "SecurePass123"
│ }
└─ Response: {
   "token": "eyJhbGciOiJIUzI1NiIs...",
   "user": {
     "id": "user-123",
     "email": "jane@example.com",
     "role": "learner"
   }
 }

STEP 2: View Dashboard
├─ GET /learner/dashboard
├─ Header: Authorization: Bearer <token>
└─ Response: {
   "activePrograms": [...],
   "pendingTasks": 5,
   "approvedTasks": 12,
   "completionPercentage": 71
 }

STEP 3: Browse Available Programs
├─ GET /learner/programs/available
├─ Query: ?limit=20&offset=0
└─ Response: {
   "items": [
     {
       "id": "prog-001",
       "title": "Web Development",
       "description": "...",
       "mentor_name": "Alice"
     }
   ]
 }

STEP 4: Enroll in Program
├─ POST /learner/programs/prog-001/enroll
└─ Response: {
   "ok": true,
   "program": { "id": "prog-001", ... }
 }

STEP 5: View Program Structure
├─ GET /learner/programs/prog-001/milestones
├─ GET /learner/programs/prog-001/modules/mile-001/chapters
└─ Response: {
   "items": [
     { "id": "chap-001", "title": "...", "body_md": "..." }
   ]
 }

STEP 6: Get Tasks to Complete
├─ GET /learner/programs/prog-001/tasks
└─ Response: {
   "items": [
     {
       "id": "task-001",
       "title": "Setup Environment",
       "deadline_at": "2024-02-15T23:59:59Z",
       "submission_status": "not_submitted"
     }
   ]
 }

STEP 7: Submit Task
├─ POST /learner/tasks/task-001/submit
├─ Body: {
│   "link": "https://github.com/user/project",
│   "notes": "Completed all steps"
│ }
└─ Response: {
   "submission": {
     "id": "sub-001",
     "status": "submitted"
   }
 }

STEP 8: Wait for Review
├─ GET /notifications
└─ Receive: {
   "type": "submission_reviewed",
   "title": "Your submission was reviewed",
   "meta": { "status": "approved", "score": 95 }
 }

STEP 9: Check Progress
├─ GET /learner/programs/prog-001/progress
└─ Response: {
   "total_tasks": 15,
   "approved": 15,
   "pending": 0,
   "completionPercentage": 100
 }

STEP 10: Leave Review
├─ POST /learner/programs/prog-001/review
├─ Body: {
│   "rating": 5,
│   "feedback": "Excellent program!"
│ }
└─ Response: { "ok": true }
```

---

## Mentor Workflow

### Mentor Dashboard to Review Process

```
STEP 1: Login as Mentor
├─ POST /auth/login
├─ Email: mentor@example.com
└─ Get: Authorization Token

STEP 2: View Dashboard
├─ GET /mentor/dashboard
└─ Response: {
   "assignedLearners": [
     { "id": "learner-001", "full_name": "John Doe" }
   ],
   "pendingReviews": 7,
   "programs": [...]
 }

STEP 3: Get All Pending Submissions
├─ GET /mentor/submissions?status=submitted
├─ Query: ?limit=20&offset=0&status=submitted
└─ Response: {
   "items": [
     {
       "id": "sub-001",
       "status": "submitted",
       "learner_name": "John Doe",
       "task_title": "Setup Environment",
       "created_at": "2024-02-15T15:30:00Z"
     }
   ]
 }

STEP 4: View Submission Details
├─ GET /mentor/submissions/sub-001
└─ Response: {
   "submission": {
     "id": "sub-001",
     "link": "https://github.com/john/project",
     "notes": "Completed all requirements",
     "learner_email": "john@example.com",
     "deadline_at": "2024-02-18T23:59:59Z"
   }
 }

STEP 5a: Approve Submission
├─ POST /mentor/submissions/sub-001/review
├─ Body: {
│   "decision": "approved",
│   "feedbackText": "Great work! Setup is correct.",
│   "score": 95
│ }
└─ Response: {
   "submission": {
     "id": "sub-001",
     "status": "approved"
   }
 }

   OR

STEP 5b: Request Changes
├─ POST /mentor/submissions/sub-001/review
├─ Body: {
│   "decision": "rejected",
│   "feedbackText": "Please review section 3, config needs updates",
│   "score": 0
│ }
└─ Response: {
   "submission": {
     "id": "sub-001",
     "status": "rejected"
   }
 }

STEP 6: View Learner Timeline
├─ GET /mentor/learners/learner-001/timeline
└─ Response: {
   "items": [
     {
       "id": "sub-001",
       "task_title": "Setup Environment",
       "status": "approved",
       "score": 95,
       "reviewed_at": "2024-02-16T10:00:00Z"
     }
   ]
 }

STEP 7: Check Program Reviews
├─ GET /mentor/programs/prog-001/reviews
└─ Response: {
   "summary": {
     "totalReviews": 15,
     "averageRating": 4.67
   },
   "items": [...]
 }
```

---

## Task Submission Lifecycle

### State Transitions

```
┌──────────────────┐
│   UNSTARTED      │
│ (No Submission)  │
└────────┬─────────┘
         │
         │ POST /learner/tasks/{id}/submit
         │
         ▼
┌──────────────────────┐
│    SUBMITTED         │
│ (Awaiting Review)    │
│                      │
│ Notification Sent    │
│ to Mentor            │
└────────┬─────────────┘
         │
    ┌────┴─────────┐
    │              │
    │ Mentor       │ Mentor
    │ Approves     │ Rejects
    │              │
    ▼              ▼
┌──────────┐  ┌─────────────┐
│ APPROVED │  │  REJECTED   │
│ (Score)  │  │ (Feedback)  │
└──────────┘  └─────────────┘
              │
              │ Can Re-submit
              │
              ▼
         Returns to
         SUBMITTED State
```

### Request/Response Examples

**Submit Task Request:**
```bash
POST /learner/tasks/task-001/submit
Content-Type: application/json

{
  "link": "https://github.com/student/assignment",
  "notes": "Implemented all requirements, tested on Windows and Mac"
}
```

**Success Response (200 OK):**
```json
{
  "submission": {
    "id": "sub-001",
    "task_id": "task-001",
    "learner_id": "learner-001",
    "status": "submitted",
    "link": "https://github.com/student/assignment",
    "notes": "Implemented all requirements, tested on Windows and Mac",
    "score": null,
    "feedback_text": null,
    "created_at": "2024-02-15T15:30:00Z",
    "reviewed_at": null
  }
}
```

**Already Submitted Response (409 Conflict):**
```json
{
  "error": {
    "message": "Submission already exists for this task"
  }
}
```

---

## Error Scenarios & Responses

### Scenario 1: Invalid Token

```
Request:
GET /learner/dashboard
Header: Authorization: Bearer invalid_token_xyz

Response (401 Unauthorized):
{
  "error": {
    "message": "Invalid token"
  }
}
```

### Scenario 2: Insufficient Permissions

```
Request:
POST /admin/audit-logs (as a learner)
Header: Authorization: Bearer learner_token

Response (403 Forbidden):
{
  "error": {
    "message": "Insufficient permissions"
  }
}
```

### Scenario 3: Resource Not Found

```
Request:
GET /learner/programs/prog-999/tasks

Response (404 Not Found):
{
  "error": {
    "message": "Program not found"
  }
}
```

### Scenario 4: Duplicate Enrollment

```
Request:
POST /learner/programs/prog-001/enroll (twice)

Response (409 Conflict):
{
  "error": {
    "message": "Already enrolled in this program"
  }
}
```

### Scenario 5: Invalid Input

```
Request:
POST /auth/signup
{
  "fullName": "",  ❌ Empty
  "email": "invalid",  ❌ Invalid format
  "password": "123"  ❌ Too short
}

Response (400 Bad Request):
{
  "error": {
    "message": "Validation failed: email must be valid, password must be at least 8 characters"
  }
}
```

### Scenario 6: Task Deadline Passed

```
Request:
POST /learner/tasks/task-001/submit
(deadline_at was 2024-02-10)

Response (403 Forbidden):
{
  "error": {
    "message": "Task deadline has passed"
  }
}
```

---

## Response Code Matrix

### HTTP Status Codes Reference

| Code | Status | Scenario | Example |
|------|--------|----------|---------|
| 200 | OK | Request successful | `GET /learner/dashboard` returns data |
| 201 | Created | Resource created | `POST /auth/signup` creates account |
| 400 | Bad Request | Invalid input | Missing required fields in body |
| 401 | Unauthorized | Invalid/expired token | Expired JWT or missing auth header |
| 403 | Forbidden | Insufficient permissions | Learner accessing `/admin/` routes |
| 404 | Not Found | Resource doesn't exist | Program ID doesn't exist |
| 409 | Conflict | Resource conflict | Already enrolled in program |
| 429 | Too Many Requests | Rate limit exceeded | 100+ requests in 60 seconds |
| 500 | Internal Server Error | Server error | Database connection failure |
| 503 | Service Unavailable | Database down | PostgreSQL server offline |

### Decision Tree for Common Issues

```
API Request Returns Error
        │
        ├─ 400 Bad Request?
        │  └─ Check JSON format, required fields, data types
        │
        ├─ 401 Unauthorized?
        │  └─ Token missing, invalid, or expired
        │     └─ Login again: POST /auth/login
        │
        ├─ 403 Forbidden?
        │  └─ User role lacks permission
        │     └─ Check endpoint role requirements
        │
        ├─ 404 Not Found?
        │  └─ URL path or resource ID incorrect
        │     └─ Verify IDs and endpoint paths
        │
        ├─ 409 Conflict?
        │  └─ Resource already exists
        │     └─ Check unique constraints
        │
        └─ 5xx Server Error?
           └─ Server or database issue
              └─ Check server status or contact admin
```

---

## Testing Checklist

### Authentication Tests
- [ ] Sign up creates learner account
- [ ] Login with valid credentials returns token
- [ ] Login with invalid password returns 401
- [ ] GET /auth/me returns current user
- [ ] Request password reset sends token
- [ ] Reset password updates credentials
- [ ] Expired token returns 401

### Learner Tests
- [ ] Can view available programs
- [ ] Can enroll in program
- [ ] Cannot enroll twice (409)
- [ ] Can view enrolled programs
- [ ] Can view program tasks
- [ ] Can submit task
- [ ] Cannot submit same task twice (409)
- [ ] Can view program progress
- [ ] Can leave program review (when eligible)

### Mentor Tests
- [ ] Can view own programs
- [ ] Can view pending submissions
- [ ] Can approve submission
- [ ] Can reject submission
- [ ] Can view learner timeline
- [ ] Can view program reviews
- [ ] Notifications sent when reviewing

### Admin Tests
- [ ] Can view all programs
- [ ] Can view audit logs
- [ ] Cannot be accessed by learner (403)

### Error Cases
- [ ] Invalid token returns 401
- [ ] Missing auth header returns 401
- [ ] Non-existent resource returns 404
- [ ] Invalid JSON returns 400
- [ ] Rate limiting works (429)
- [ ] CORS works for cross-origin

---

**See Also:** [API Documentation](./API_DOCUMENTATION.md) | [cURL Guide](./CURL_GUIDE.md)
