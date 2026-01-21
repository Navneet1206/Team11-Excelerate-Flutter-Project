# cURL Command Guide - Complete Tutorial

A comprehensive guide to using cURL for testing the SkillTrack Pro API.

---

## Table of Contents

1. [What is cURL?](#what-is-curl)
2. [Installation](#installation)
3. [Basic Syntax](#basic-syntax)
4. [Common HTTP Methods](#common-http-methods)
5. [Headers & Authentication](#headers--authentication)
6. [Working with JSON](#working-with-json)
7. [Example Workflows](#example-workflows)
8. [Tips & Tricks](#tips--tricks)

---

## What is cURL?

**cURL** (Client URL) is a command-line tool for transferring data using URLs. It supports multiple protocols including HTTP/HTTPS.

### Why use cURL?

- ✅ No GUI required - test APIs from terminal
- ✅ Scriptable - automate API testing
- ✅ Lightweight - minimal resources
- ✅ Universal - works on Windows, Mac, Linux
- ✅ Secure - supports TLS/SSL

---

## Installation

### Windows 10/11

cURL is built-in! Open **Command Prompt** or **PowerShell** and type:

```cmd
curl --version
```

If not available, download from: https://curl.se/download.html

### Mac

Pre-installed. Open **Terminal** and verify:

```bash
curl --version
```

### Linux

Install via package manager:

```bash
# Ubuntu/Debian
sudo apt-get install curl

# Fedora
sudo dnf install curl

# CentOS
sudo yum install curl
```

---

## Basic Syntax

### General Format

```bash
curl [OPTIONS] <URL>
```

### Common Options Reference

| Option | Description | Example |
|--------|-------------|---------|
| `-X` | HTTP method | `-X POST` |
| `-H` | Add header | `-H "Content-Type: application/json"` |
| `-d` | Request body | `-d '{"key": "value"}'` |
| `-i` | Include headers in output | `-i` |
| `-v` | Verbose mode (detailed) | `-v` |
| `-L` | Follow redirects | `-L` |
| `-o` | Save output to file | `-o response.json` |
| `-u` | Basic auth | `-u username:password` |

---

## Common HTTP Methods

### 1. GET (Retrieve Data)

```bash
curl -X GET https://api.example.com/users
```

### 2. POST (Create Data)

```bash
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John", "email": "john@example.com"}'
```

### 3. PUT (Update Data)

```bash
curl -X PUT https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{"name": "Jane"}'
```

### 4. DELETE (Remove Data)

```bash
curl -X DELETE https://api.example.com/users/123
```

---

## Headers & Authentication

### Adding Headers

```bash
curl -X GET https://api.example.com/data \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

### JWT Bearer Token (Authentication)

```bash
curl -X GET https://api.example.com/protected \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Basic Authentication

```bash
curl -X GET https://api.example.com/data \
  -u username:password
```

---

## Working with JSON

### Sending JSON Data

```bash
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }'
```

### Pretty-Printing JSON Response (Linux/Mac)

```bash
curl -X GET https://api.example.com/users | jq
```

### Saving Response to File

```bash
curl -X GET https://api.example.com/users -o response.json
```

---

## Example Workflows

### SkillTrack Pro API Examples

#### 1. Login and Get Token

**Command:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "learner@example.com",
    "password": "password123"
  }'
```

**Save the token from response:**
```
token = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

#### 2. Get Current User

**Command:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Windows PowerShell (with variable):**
```powershell
$token = "YOUR_TOKEN"
curl -X GET https://team11-excelerate-flutter-project.vercel.app/auth/me `
  -H "Authorization: Bearer $token"
```

---

#### 3. Get Available Programs

**Command:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/programs/available \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

#### 4. Enroll in Program

**Command:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-001/enroll \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

---

#### 5. Get Program Tasks

**Command:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/programs/prog-001/tasks \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

#### 6. Submit a Task

**Command:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/learner/tasks/task-001/submit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "link": "https://github.com/yourname/project",
    "notes": "Completed all requirements and tested"
  }'
```

---

#### 7. Get Submissions (Mentor)

**Command:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/mentor/submissions?status=submitted \
  -H "Authorization: Bearer MENTOR_TOKEN"
```

---

#### 8. Review Submission (Mentor)

**Command:**
```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/mentor/submissions/sub-001/review \
  -H "Authorization: Bearer MENTOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "decision": "approved",
    "feedbackText": "Excellent implementation!",
    "score": 95
  }'
```

---

#### 9. Get Notifications

**Command:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/notifications \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

#### 10. Health Check

**Command:**
```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/health
```

---

## Platform-Specific Syntax

### Line Continuation

When commands are long, you may want to split them across multiple lines.

#### Windows Command Prompt

Use `^` for line continuation:

```cmd
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\": \"user@example.com\", \"password\": \"pass123\"}"
```

#### Windows PowerShell

Use `` ` `` (backtick) for line continuation:

```powershell
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/login `
  -H "Content-Type: application/json" `
  -d '{"email": "user@example.com", "password": "pass123"}'
```

#### Mac/Linux Terminal

Use `\` for line continuation:

```bash
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "pass123"}'
```

---

## Tips & Tricks

### 1. Verbose Output (Debug Mode)

See all request/response details:

```bash
curl -v https://team11-excelerate-flutter-project.vercel.app/health
```

### 2. Save Response to Variable

**Bash:**
```bash
response=$(curl -s https://team11-excelerate-flutter-project.vercel.app/health)
echo $response
```

**PowerShell:**
```powershell
$response = curl -s https://team11-excelerate-flutter-project.vercel.app/health
Write-Host $response
```

### 3. Include Response Headers

```bash
curl -i https://team11-excelerate-flutter-project.vercel.app/health
```

### 4. Measure Response Time

**Linux/Mac:**
```bash
curl -w "\nTime: %{time_total}s\n" https://team11-excelerate-flutter-project.vercel.app/health
```

### 5. Set Custom User-Agent

```bash
curl -X GET https://team11-excelerate-flutter-project.vercel.app/health \
  -H "User-Agent: MyApp/1.0"
```

### 6. Ignore SSL Certificate Errors (Development Only!)

```bash
curl -k https://self-signed.example.com/api
```

### 7. Pipe Output to jq (Format JSON)

**Mac/Linux:**
```bash
curl -s https://team11-excelerate-flutter-project.vercel.app/auth/me \
  -H "Authorization: Bearer TOKEN" | jq
```

### 8. Extract Specific Field from JSON Response

**Mac/Linux:**
```bash
curl -s https://team11-excelerate-flutter-project.vercel.app/auth/me \
  -H "Authorization: Bearer TOKEN" | jq '.user.id'
```

### 9. Create a Batch Script (Windows)

Create `test.bat`:

```batch
@echo off
set TOKEN=YOUR_TOKEN_HERE
set BASE_URL=https://team11-excelerate-flutter-project.vercel.app

echo Testing health endpoint...
curl -X GET %BASE_URL%/health

echo.
echo Testing auth endpoint...
curl -X GET %BASE_URL%/auth/me ^
  -H "Authorization: Bearer %TOKEN%"
```

Run with: `test.bat`

### 10. Create a Bash Script (Mac/Linux)

Create `test.sh`:

```bash
#!/bin/bash
TOKEN="YOUR_TOKEN_HERE"
BASE_URL="https://team11-excelerate-flutter-project.vercel.app"

echo "Testing health endpoint..."
curl -X GET $BASE_URL/health

echo -e "\nTesting auth endpoint..."
curl -X GET $BASE_URL/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

Run with: `bash test.sh`

---

## Common Errors & Solutions

### Error: "command not found: curl"

**Solution:** Install curl (see Installation section)

### Error: "SSL certificate problem"

**Solution:** Either:
- Use `http://` instead of `https://`
- Add `-k` flag to ignore SSL (development only)

### Error: "Invalid JSON"

**Check:**
- Proper JSON syntax (matching quotes, commas)
- String values in double quotes
- Escape special characters with `\`

### Error: "401 Unauthorized"

**Solution:**
- Verify token is correct
- Check token hasn't expired
- Ensure token is in Bearer format

### Error: "403 Forbidden"

**Solution:**
- Verify user has required role
- Check endpoint requirements

---

## Quick Command Reference

```bash
# Login
curl -X POST https://team11-excelerate-flutter-project.vercel.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "pass"}'

# Get user info
curl -X GET https://team11-excelerate-flutter-project.vercel.app/auth/me \
  -H "Authorization: Bearer TOKEN"

# Get programs
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/programs \
  -H "Authorization: Bearer TOKEN"

# Get tasks
curl -X GET https://team11-excelerate-flutter-project.vercel.app/learner/programs/ID/tasks \
  -H "Authorization: Bearer TOKEN"

# Submit task
curl -X POST https://team11-excelerate-flutter-project.vercel.app/learner/tasks/ID/submit \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"link": "url", "notes": "text"}'

# Health check
curl https://team11-excelerate-flutter-project.vercel.app/health
```

---

**Ready to test the API? Start with the [Quick Start Guide](./QUICK_START.md) 🚀**
