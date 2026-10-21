# Apex University • Student Management & Enrollment Portal (REST API Backend)
> Built with **JSON-Server** (REST API) & Modern Responsive Web UI supporting full **CRUD** (Create, Read, Update, Delete) operations for Flutter mobile clients.

---

## 🚀 Quick Start Guide

### 1. Start the Server & Application
Run the following command in your terminal:

```bash
npm start
```
*or*
```bash
npx json-server --watch db.json --static ./public --port 3000
```

### 2. Access the Application
Open your browser and navigate to:
👉 **[http://localhost:3000](http://localhost:3000)**

---

## 🛠️ CRUD Operations Breakdown

| Operation | HTTP Method | Endpoint | Description |
|---|---|---|---|
| **Create** | `POST` | `/students` | Register a new student record with form validation and avatar selection. |
| **Read** | `GET` | `/students` | Fetch and list all student records with instant search, department & status filters. |
| **Update** | `PUT` / `PATCH` | `/students/:id` | Edit an existing student profile by loading data into the form and saving changes. |
| **Delete** | `DELETE` | `/students/:id` | Remove a student record with confirmation dialog and live UI update. |

---

## 💻 REST API Endpoints & Curl Examples

### 1. Read All Students (`GET`)
```bash
curl -s http://localhost:3000/students
```

### 2. Create a New Student (`POST`)
```bash
curl -X POST http://localhost:3000/students \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Oliver Queen",
    "email": "oliver.queen@apexuni.edu",
    "studentId": "U2024-CS901",
    "department": "Computer Science & AI",
    "degree": "B.S. Cyber Security",
    "gpa": 3.85,
    "year": "Junior",
    "status": "Enrolled",
    "phone": "+1 (555) 789-0123"
  }'
```

### 3. Update an Existing Student (`PUT`)
```bash
curl -X PUT http://localhost:3000/students/1 \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "fullName": "Sophia Chen",
    "email": "sophia.chen@apexuni.edu",
    "studentId": "U2024-CS101",
    "department": "Computer Science & AI",
    "degree": "M.S. Artificial Intelligence & Robotics",
    "gpa": 3.98,
    "year": "Graduate",
    "status": "Enrolled"
  }'
```

### 4. Delete a Student (`DELETE`)
```bash
curl -X DELETE http://localhost:3000/students/1
```

---

## 📸 Automated Test Suite & Screenshots
Run `npm test` to launch the automated headless Chrome test suite that validates all CRUD actions and updates the high-res screenshots in `assets/`.
