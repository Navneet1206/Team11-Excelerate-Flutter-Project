# Quick Start Guide - SkillTrack Pro API

**Get up and running with SkillTrack Pro in 5 minutes!**

---

## 1. Local Setup (Development)

### Prerequisites
- Node.js v18+
- PostgreSQL v12+
- npm

### Installation

```bash
cd backend
npm install
```

### Configure Environment

Create `.env` file:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://username:password@localhost:5432/skilltrack_pro
JWT_SECRET=your_secret_key_at_least_32_characters_long
JWT_EXPIRES_IN=7d
DEADLINE_ALERTS_ENABLED=true
```

### Setup Database

```bash
npm run migrate
npm run seed
```

### Start Development Server

```bash
npm run dev
```

✅ Server running at `http://localhost:3000`

---

## 2. Common Testing Workflows

### Workflow 1: Register & Login

**Step 1: Sign up as a learner**
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Test Learner",
    "email": "test@example.com",
    "password": "TestPass123"
  }'
```

**Response:**
```json
{
  "token": "eyJhbGci...",
  "user": {
    "id": "user-123",
    "email": "test@example.com",
    "role": "learner",
    "fullName": "Test Learner"
  }
}
```

**Step 2: Save your token**
```
YOUR_TOKEN = eyJhbGci...
```

---

### Workflow 2: Explore Available Programs

```bash
curl -X GET http://localhost:3000/learner/programs/available \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
{
  "items": [
    {
      "id": "prog-001",
      "title": "Web Development Bootcamp",
      "description": "Learn modern web development"
    }
  ]
}
```

---

### Workflow 3: Enroll in a Program

```bash
curl -X POST http://localhost:3000/learner/programs/prog-001/enroll \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### Workflow 4: View Program Tasks

```bash
curl -X GET http://localhost:3000/learner/programs/prog-001/tasks \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### Workflow 5: Submit a Task

```bash
curl -X POST http://localhost:3000/learner/tasks/task-001/submit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "link": "https://github.com/yourname/repo",
    "notes": "Completed all requirements"
  }'
```

---

## 3. Mentor Testing

### Sign Up as Mentor

```bash
# Note: Standard signup creates learners. 
# For testing, use your admin token to upgrade user role.
```

### Get Mentor's Programs

```bash
curl -X GET http://localhost:3000/mentor/programs \
  -H "Authorization: Bearer MENTOR_TOKEN"
```

### View Pending Submissions

```bash
curl -X GET http://localhost:3000/mentor/submissions?status=submitted \
  -H "Authorization: Bearer MENTOR_TOKEN"
```

### Review a Submission

```bash
curl -X POST http://localhost:3000/mentor/submissions/sub-001/review \
  -H "Authorization: Bearer MENTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "decision": "approved",
    "feedbackText": "Great work!",
    "score": 90
  }'
```

---

## 4. Quick Reference - Common Endpoints

| Action | Method | Endpoint |
|--------|--------|----------|
| Login | POST | `/auth/login` |
| Get Dashboard | GET | `/learner/dashboard` |
| Enroll Program | POST | `/learner/programs/:id/enroll` |
| Get Tasks | GET | `/learner/programs/:id/tasks` |
| Submit Task | POST | `/learner/tasks/:id/submit` |
| Get Progress | GET | `/learner/programs/:id/progress` |
| View Submissions | GET | `/mentor/submissions` |
| Review Submission | POST | `/mentor/submissions/:id/review` |
| Get Notifications | GET | `/notifications` |

---

## 5. Troubleshooting

### Issue: Token Expired
**Solution:** Log in again to get a new token

### Issue: Endpoint Not Found (404)
**Check:** Correct URL path and HTTP method

### Issue: Permission Denied (403)
**Check:** User role has required permissions

### Issue: Database Connection Error
**Solution:**
```bash
# Restart PostgreSQL service
# Windows: services.msc → PostgreSQL → Start
# Mac: brew services restart postgresql
```

### Issue: Port Already in Use
```bash
# Change PORT in .env or kill process on port 3000
# Windows: netstat -ano | findstr :3000
# Mac/Linux: lsof -i :3000
```

---

## 6. Production URLs

**API Base URL:**
```
https://team11-excelerate-flutter-project.vercel.app
```

Use this instead of `localhost:3000` for production testing.

---

## 7. Documentation Links

- [📖 Full API Documentation](./API_DOCUMENTATION.md)
- [💻 cURL Guide](./CURL_GUIDE.md)
- [🏗️ System Architecture](./SYSTEM_OVERVIEW.md)
- [📊 Visual Testing Guide](./API_TESTING_VISUAL_GUIDE.md)

---

**Happy Testing! 🚀**
