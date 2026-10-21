# Mobile Application Development (MAD) • Lab Report 03 (Backend)
## REST API Backend Server & Web Management Portal

---

### 📋 Student Information
- **Student Name:** Maaz Ali
- **Roll Number:** 3143
- **Degree Program:** Bachelor of Science in Computer Science (BSCS)
- **Semester:** 8th Semester
- **Course:** Mobile Application Development (MAD)
- **Lab Date:** September 30, 2026

---

## 1. 🎯 Lab Objectives
1. Implement a complete RESTful API backend service providing endpoints for Mobile Application data consumption.
2. Provide a modern, responsive Web Management Portal for testing and administering student records.
3. Validate HTTP methods: `GET`, `POST`, `PUT`, `DELETE` with real JSON persistence (`db.json`).
4. Support interactive diagnostics, live API logging, card & table views, and automated screenshot validation.

---

## 2. 🧠 REST API Endpoints Specification

| Endpoint | HTTP Verb | Request Body Format | Success Status | Description |
|---|---|---|---|---|
| `/students` | `GET` | *None* | `200 OK` | Retrieves all student records |
| `/students/:id` | `GET` | *None* | `200 OK` | Retrieves a specific student profile |
| `/students` | `POST` | JSON Object (name, email, dept, etc.) | `201 Created` | Enrolls a new student |
| `/students/:id` | `PUT` | Complete JSON Student Object | `200 OK` | Updates all student attributes |
| `/students/:id` | `PATCH` | Partial JSON Student Object | `200 OK` | Updates specific student fields |
| `/students/:id` | `DELETE` | *None* | `200 OK` | Deletes a student record |

---

## 3. 📸 Visual Verification & Test Suite

The backend includes a Puppeteer automated verification suite (`test_screenshot.js`) with 6 high-resolution output screenshots stored in `assets/`:

| Screenshot | File Name | Description |
|---|---|---|
| **01** | `assets/01_dashboard_overview.png` | Main Dashboard Overview with Student Table and Statistics |
| **02** | `assets/02_student_created_post.png` | Form Submission & Student Registration via `POST` |
| **03** | `assets/03_student_profile_modal.png` | Detailed Profile Modal via `GET /students/:id` |
| **04** | `assets/04_student_edit_mode_put.png` | Form Edit Mode updating student attributes via `PUT` |
| **05** | `assets/05_cards_grid_view.png` | Responsive Cards Grid View presentation |
| **06** | `assets/06_api_inspector_live_logs.png` | Live REST API Inspector Drawer showing network telemetry |

---

## 4. 🚀 Quick Start & Execution Guide

### 1. Install Dependencies & Start the Server
```bash
cd "MAD BSCS 8TH SEMESTER/Lab 03 - REST API Backend Server"
npm install
npm start
```
The server will start at **`http://localhost:3000`**.

### 2. Run the Automated Screenshot Test Suite
```bash
npm test
```

---

## 5. 🏁 Lab Conclusion
This backend project serves as the foundational data provider for the Mobile Application Development lab ecosystem, establishing strict REST conventions, data persistence, and administrative interfaces.
