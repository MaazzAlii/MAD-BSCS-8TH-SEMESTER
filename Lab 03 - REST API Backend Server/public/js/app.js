/**
 * Apex University - Student Management & Registration Portal
 * RESTful CRUD Client communicating with JSON-Server
 */

// Configuration & Endpoints
const API_BASE = window.location.origin;
const STUDENTS_ENDPOINT = `${API_BASE}/students`;
const DEPARTMENTS_ENDPOINT = `${API_BASE}/departments`;

// Application State
const state = {
  students: [],
  departments: [],
  selectedDept: 'ALL',
  selectedStatus: 'ALL',
  searchQuery: '',
  sortBy: 'id-desc',
  viewMode: 'table', // 'table' or 'cards'
  currentPage: 1,
  pageSize: 8,
  editingStudentId: null,
  studentToDelete: null,
  apiLogCount: 0
};

// Default seed data fallback
const DEFAULT_SEED_STUDENTS = [
  {
    fullName: "Sophia Chen",
    email: "sophia.chen@apexuni.edu",
    studentId: "U2024-CS101",
    department: "Computer Science & AI",
    degree: "B.S. Artificial Intelligence",
    gpa: 3.92,
    semester: "Fall 2024",
    year: "Junior",
    status: "Enrolled",
    gender: "Female",
    phone: "+1 (555) 234-8901",
    avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
    address: "404 Silicon Ave, Tech District, CA",
    enrolledDate: "2024-08-15"
  },
  {
    fullName: "Marcus Alexander",
    email: "m.alexander@apexuni.edu",
    studentId: "U2024-EE204",
    department: "Electrical & Robotics Engineering",
    degree: "B.Eng. Robotics",
    gpa: 3.78,
    semester: "Fall 2024",
    year: "Senior",
    status: "Enrolled",
    gender: "Male",
    phone: "+1 (555) 876-5432",
    avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80",
    address: "12 Innovation Parkway, Boston, MA",
    enrolledDate: "2024-08-20"
  },
  {
    fullName: "Elena Rostova",
    email: "elena.r@apexuni.edu",
    studentId: "U2024-MED305",
    department: "Biomedical & Life Sciences",
    degree: "M.S. Bioinformatics",
    gpa: 3.95,
    semester: "Spring 2024",
    year: "Graduate",
    status: "Enrolled",
    gender: "Female",
    phone: "+1 (555) 432-1098",
    avatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80",
    address: "88 Health Bio Way, Seattle, WA",
    enrolledDate: "2024-01-10"
  },
  {
    fullName: "Aarav Patel",
    email: "a.patel@apexuni.edu",
    studentId: "U2024-DS108",
    department: "Data Science & Quantum Computing",
    degree: "B.S. Data Science",
    gpa: 3.65,
    semester: "Fall 2024",
    year: "Sophomore",
    status: "Pending",
    gender: "Male",
    phone: "+1 (555) 345-6789",
    avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80",
    address: "55 Matrix Blvd, Austin, TX",
    enrolledDate: "2024-09-01"
  },
  {
    fullName: "Chloe Dupont",
    email: "c.dupont@apexuni.edu",
    studentId: "U2024-DES402",
    department: "Digital Design & Human Computer Interaction",
    degree: "B.A. Interaction Design",
    gpa: 3.88,
    semester: "Fall 2024",
    year: "Freshman",
    status: "Enrolled",
    gender: "Female",
    phone: "+1 (555) 901-2345",
    avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80",
    address: "77 Studio Lane, New York, NY",
    enrolledDate: "2024-08-28"
  }
];

// DOM Elements
const elements = {
  form: document.getElementById('student-form'),
  formTitle: document.getElementById('form-title'),
  formSubtitle: document.getElementById('form-subtitle'),
  formModeBadge: document.getElementById('form-mode-badge'),
  submitBtnText: document.getElementById('submit-btn-text'),
  btnCancelEdit: document.getElementById('btn-cancel-edit'),
  studentIdField: document.getElementById('student-id-field'),
  nameInput: document.getElementById('student-name'),
  codeInput: document.getElementById('student-code'),
  emailInput: document.getElementById('student-email'),
  deptSelect: document.getElementById('student-dept'),
  degreeInput: document.getElementById('student-degree'),
  yearSelect: document.getElementById('student-year'),
  statusSelect: document.getElementById('student-status'),
  gpaRange: document.getElementById('student-gpa-range'),
  gpaNum: document.getElementById('student-gpa'),
  gpaBadge: document.getElementById('gpa-display-badge'),
  phoneInput: document.getElementById('student-phone'),
  semesterInput: document.getElementById('student-semester'),
  addressInput: document.getElementById('student-address'),
  avatarUrlInput: document.getElementById('student-avatar-url'),
  avatarPreviewImg: document.getElementById('avatar-preview-img'),
  btnGenId: document.getElementById('btn-gen-id'),
  presetAvatarBtns: document.querySelectorAll('.preset-btn'),

  // Records & Controls
  searchInput: document.getElementById('search-input'),
  searchClearBtn: document.getElementById('search-clear-btn'),
  filterDept: document.getElementById('filter-dept'),
  filterStatus: document.getElementById('filter-status'),
  sortBy: document.getElementById('sort-by'),
  viewTableBtn: document.getElementById('view-table-btn'),
  viewCardsBtn: document.getElementById('view-cards-btn'),
  deptPills: document.querySelectorAll('.dept-pill'),
  pillCountAll: document.getElementById('pill-count-all'),

  // Views & States
  tableViewContainer: document.getElementById('table-view-container'),
  cardsViewContainer: document.getElementById('cards-view-container'),
  tableBody: document.getElementById('students-table-body'),
  loadingState: document.getElementById('loading-state'),
  emptyState: document.getElementById('empty-state'),
  btnEmptyReset: document.getElementById('btn-empty-reset'),
  showingCount: document.getElementById('showing-count'),
  totalCount: document.getElementById('total-count'),
  paginationWrapper: document.getElementById('pagination-wrapper'),

  // Metrics
  metricTotal: document.getElementById('metric-total'),
  metricEnrolled: document.getElementById('metric-enrolled'),
  metricGpa: document.getElementById('metric-gpa'),
  metricTopDept: document.getElementById('metric-top-dept'),

  // Modals
  profileModal: document.getElementById('profile-modal'),
  btnCloseProfileModal: document.getElementById('btn-close-profile-modal'),
  modalProfileAvatar: document.getElementById('modal-profile-avatar'),
  modalProfileName: document.getElementById('modal-profile-name'),
  modalProfileId: document.getElementById('modal-profile-id'),
  modalProfileStatus: document.getElementById('modal-profile-status'),
  modalProfileDept: document.getElementById('modal-profile-dept'),
  modalProfileDegree: document.getElementById('modal-profile-degree'),
  modalProfileGpa: document.getElementById('modal-profile-gpa'),
  modalProfileYear: document.getElementById('modal-profile-year'),
  modalProfileEmail: document.getElementById('modal-profile-email'),
  modalProfilePhone: document.getElementById('modal-profile-phone'),
  modalProfileAddress: document.getElementById('modal-profile-address'),
  modalBtnEdit: document.getElementById('modal-btn-edit'),
  modalBtnDelete: document.getElementById('modal-btn-delete'),

  deleteModal: document.getElementById('delete-modal'),
  deleteStudentName: document.getElementById('delete-student-name'),
  btnCancelDelete: document.getElementById('btn-cancel-delete'),
  btnConfirmDelete: document.getElementById('btn-confirm-delete'),

  // API Inspector & Actions
  apiInspectorDrawer: document.getElementById('api-inspector-drawer'),
  apiInspectorToggle: document.getElementById('api-inspector-toggle'),
  btnApiInspector: document.getElementById('btn-api-inspector'),
  apiLogStream: document.getElementById('api-log-stream'),
  apiCounter: document.getElementById('api-counter'),
  btnClearLogs: document.getElementById('btn-clear-logs'),
  btnExportData: document.getElementById('btn-export-data'),
  btnSeedData: document.getElementById('btn-seed-data'),
  btnOpenCreateModal: document.getElementById('btn-open-create-modal'),

  // Theme
  themeToggleBtn: document.getElementById('theme-toggle-btn'),
  themeMenu: document.getElementById('theme-menu'),
  themeOptions: document.querySelectorAll('.theme-option'),

  // Toast
  toastContainer: document.getElementById('toast-container')
};

// ==========================================
// 1. API HELPER & INSPECTOR LOGGING
// ==========================================
async function apiRequest(url, method = 'GET', data = null) {
  const startTime = performance.now();
  const options = {
    method,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  };

  if (data && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
    options.body = JSON.stringify(data);
  }

  try {
    const response = await fetch(url, options);
    const duration = Math.round(performance.now() - startTime);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    let responseData = null;
    if (method !== 'DELETE') {
      responseData = await response.json();
    }

    logApiActivity(method, url, response.status, duration, data);
    return responseData;
  } catch (err) {
    const duration = Math.round(performance.now() - startTime);
    logApiActivity(method, url, 'ERROR', duration, null, err.message);
    throw err;
  }
}

function logApiActivity(method, url, status, duration, payload, errorMsg = null) {
  state.apiLogCount++;
  elements.apiCounter.textContent = state.apiLogCount;

  const entry = document.createElement('div');
  entry.className = `api-log-entry ${method.toLowerCase()}`;
  
  const now = new Date();
  const timeStr = now.toTimeString().split(' ')[0] + '.' + String(now.getMilliseconds()).padStart(3, '0');

  const relativeUrl = url.replace(API_BASE, '') || '/';

  entry.innerHTML = `
    <span class="log-time">[${timeStr}]</span>
    <span class="log-tag ${method.toLowerCase()}">${method}</span>
    <span class="log-url"><code>${relativeUrl}</code></span>
    <span class="log-status">${errorMsg ? `<span style="color:var(--accent-rose)">ERR</span>` : `${status} (${duration}ms)`}</span>
  `;

  elements.apiLogStream.prepend(entry);
}

// ==========================================
// 2. CRUD OPERATIONS (READ, CREATE, UPDATE, DELETE)
// ==========================================

/** READ: Fetch all students from JSON-Server */
async function fetchStudents() {
  showLoading(true);
  try {
    const data = await apiRequest(STUDENTS_ENDPOINT, 'GET');
    state.students = Array.isArray(data) ? data : [];
    updateMetrics();
    renderData();
  } catch (err) {
    console.error("Failed to load students:", err);
    showToast('error', 'Connection Error', 'Could not reach JSON-Server on port 3000.');
  } finally {
    showLoading(false);
  }
}

/** CREATE / UPDATE: Submit Handler for the form */
async function handleFormSubmit(e) {
  e.preventDefault();

  // Basic validation
  const name = elements.nameInput.value.trim();
  const studentId = elements.codeInput.value.trim();
  const email = elements.emailInput.value.trim();
  const dept = elements.deptSelect.value;
  const degree = elements.degreeInput.value.trim();
  const year = elements.yearSelect.value;
  const status = elements.statusSelect.value;
  const gpa = parseFloat(elements.gpaNum.value) || 3.5;
  const phone = elements.phoneInput.value.trim();
  const semester = elements.semesterInput.value.trim() || 'Fall 2024';
  const address = elements.addressInput.value.trim();
  const avatar = elements.avatarPreviewImg.src;

  if (!name || !studentId || !email || !dept || !degree) {
    showToast('error', 'Validation Error', 'Please fill in all required fields marked with *');
    return;
  }

  const payload = {
    fullName: name,
    studentId: studentId,
    email: email,
    department: dept,
    degree: degree,
    year: year,
    status: status,
    gpa: gpa,
    phone: phone,
    semester: semester,
    address: address,
    avatar: avatar,
    enrolledDate: new Date().toISOString().split('T')[0]
  };

  try {
    if (state.editingStudentId) {
      // UPDATE (PUT)
      const updateUrl = `${STUDENTS_ENDPOINT}/${state.editingStudentId}`;
      const updated = await apiRequest(updateUrl, 'PUT', payload);
      
      showToast('success', 'Student Updated (PUT)', `Updated records for ${payload.fullName}`);
      resetForm();
      await fetchStudents();
    } else {
      // CREATE (POST)
      const created = await apiRequest(STUDENTS_ENDPOINT, 'POST', payload);
      
      showToast('success', 'Student Registered (POST)', `Successfully created ID ${payload.studentId}`);
      resetForm();
      await fetchStudents();
    }
  } catch (err) {
    console.error("Form submit error:", err);
    showToast('error', 'Server Error', `Failed to save student record: ${err.message}`);
  }
}

/** Pre-populate form for editing (UPDATE) */
function startEditStudent(student) {
  state.editingStudentId = student.id;
  elements.studentIdField.value = student.id;

  elements.nameInput.value = student.fullName || '';
  elements.codeInput.value = student.studentId || '';
  elements.emailInput.value = student.email || '';
  elements.deptSelect.value = student.department || '';
  elements.degreeInput.value = student.degree || '';
  elements.yearSelect.value = student.year || 'Junior';
  elements.statusSelect.value = student.status || 'Enrolled';
  
  const gpaVal = student.gpa !== undefined ? student.gpa : 3.50;
  elements.gpaRange.value = gpaVal;
  elements.gpaNum.value = gpaVal;
  elements.gpaBadge.textContent = Number(gpaVal).toFixed(2);

  elements.phoneInput.value = student.phone || '';
  elements.semesterInput.value = student.semester || 'Fall 2024';
  elements.addressInput.value = student.address || '';

  if (student.avatar) {
    elements.avatarPreviewImg.src = student.avatar;
    elements.avatarUrlInput.value = student.avatar;
  }

  // UI Mode Switch
  elements.formTitle.textContent = "Edit Student Profile";
  elements.formSubtitle.textContent = `Modifying record ID #${student.id} via PUT /students/${student.id}`;
  elements.formModeBadge.textContent = `UPDATE (PUT #${student.id})`;
  elements.formModeBadge.className = 'mode-badge edit-mode';
  elements.submitBtnText.textContent = "Save Changes (PUT)";
  elements.btnCancelEdit.classList.remove('hidden');

  // Scroll smoothly to form
  elements.form.scrollIntoView({ behavior: 'smooth', block: 'center' });
  elements.nameInput.focus();
}

/** Reset form to default CREATE mode */
function resetForm() {
  state.editingStudentId = null;
  elements.studentIdField.value = '';
  elements.form.reset();

  // Defaults
  elements.gpaRange.value = 3.80;
  elements.gpaNum.value = 3.80;
  elements.gpaBadge.textContent = "3.80";
  elements.semesterInput.value = "Fall 2024";

  // Reset Avatar to first preset
  const defaultAvatar = elements.presetAvatarBtns[0]?.getAttribute('data-avatar') || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80';
  elements.avatarPreviewImg.src = defaultAvatar;
  elements.avatarUrlInput.value = '';
  elements.presetAvatarBtns.forEach((btn, idx) => btn.classList.toggle('active', idx === 0));

  // Reset UI mode
  elements.formTitle.textContent = "Student Registration";
  elements.formSubtitle.textContent = "Fill in the student details to create a new record in JSON-Server.";
  elements.formModeBadge.textContent = "CREATE (POST)";
  elements.formModeBadge.className = 'mode-badge create-mode';
  elements.submitBtnText.textContent = "Submit Registration (POST)";
  elements.btnCancelEdit.classList.add('hidden');
}

/** Prompt confirmation modal for DELETE */
function promptDeleteStudent(student) {
  state.studentToDelete = student;
  elements.deleteStudentName.textContent = `"${student.fullName}" (${student.studentId})`;
  elements.deleteModal.classList.add('active');
}

/** DELETE: Execute delete request to JSON-Server */
async function executeDeleteStudent() {
  if (!state.studentToDelete) return;
  const student = state.studentToDelete;
  
  try {
    const deleteUrl = `${STUDENTS_ENDPOINT}/${student.id}`;
    await apiRequest(deleteUrl, 'DELETE');

    showToast('info', 'Record Deleted (DELETE)', `Removed ${student.fullName} from database`);
    elements.deleteModal.classList.remove('active');
    elements.profileModal.classList.remove('active');
    state.studentToDelete = null;

    if (state.editingStudentId === student.id) {
      resetForm();
    }

    await fetchStudents();
  } catch (err) {
    console.error("Delete error:", err);
    showToast('error', 'Delete Failed', `Could not delete student: ${err.message}`);
  }
}

// ==========================================
// 3. UI RENDERING & FILTERING
// ==========================================

function getFilteredAndSortedStudents() {
  let result = [...state.students];

  // Department filter
  if (state.selectedDept !== 'ALL') {
    result = result.filter(s => s.department === state.selectedDept);
  }

  // Status filter
  if (state.selectedStatus !== 'ALL') {
    result = result.filter(s => s.status === state.selectedStatus);
  }

  // Search query
  if (state.searchQuery.trim()) {
    const q = state.searchQuery.toLowerCase();
    result = result.filter(s => 
      (s.fullName && s.fullName.toLowerCase().includes(q)) ||
      (s.studentId && s.studentId.toLowerCase().includes(q)) ||
      (s.email && s.email.toLowerCase().includes(q)) ||
      (s.department && s.department.toLowerCase().includes(q)) ||
      (s.degree && s.degree.toLowerCase().includes(q))
    );
  }

  // Sorting
  switch (state.sortBy) {
    case 'id-desc':
      result.sort((a, b) => b.id - a.id);
      break;
    case 'id-asc':
      result.sort((a, b) => a.id - b.id);
      break;
    case 'gpa-desc':
      result.sort((a, b) => (b.gpa || 0) - (a.gpa || 0));
      break;
    case 'gpa-asc':
      result.sort((a, b) => (a.gpa || 0) - (b.gpa || 0));
      break;
    case 'name-asc':
      result.sort((a, b) => (a.fullName || '').localeCompare(b.fullName || ''));
      break;
    case 'name-desc':
      result.sort((a, b) => (b.fullName || '').localeCompare(a.fullName || ''));
      break;
  }

  return result;
}

function renderData() {
  const filtered = getFilteredAndSortedStudents();
  const total = filtered.length;

  elements.showingCount.textContent = total > 0 ? total : 0;
  elements.totalCount.textContent = state.students.length;
  elements.pillCountAll.textContent = state.students.length;

  if (total === 0) {
    elements.tableBody.innerHTML = '';
    elements.cardsViewContainer.innerHTML = '';
    elements.emptyState.classList.remove('hidden');
    elements.tableViewContainer.classList.add('hidden');
    elements.cardsViewContainer.classList.add('hidden');
    return;
  }

  elements.emptyState.classList.add('hidden');

  if (state.viewMode === 'table') {
    elements.tableViewContainer.classList.remove('hidden');
    elements.cardsViewContainer.classList.add('hidden');
    renderTableView(filtered);
  } else {
    elements.tableViewContainer.classList.add('hidden');
    elements.cardsViewContainer.classList.remove('hidden');
    renderCardsView(filtered);
  }
}

function getGpaClass(gpa) {
  if (gpa >= 3.8) return 'gpa-high';
  if (gpa >= 3.3) return 'gpa-mid';
  return 'gpa-low';
}

function getStatusClass(status) {
  const s = (status || '').toLowerCase();
  if (s === 'enrolled') return 'status-enrolled';
  if (s === 'pending') return 'status-pending';
  if (s === 'suspended') return 'status-suspended';
  if (s === 'graduated') return 'status-graduated';
  return 'status-enrolled';
}

function renderTableView(list) {
  elements.tableBody.innerHTML = list.map(student => `
    <tr>
      <td>
        <div class="student-meta-cell">
          <img class="student-tbl-avatar" src="${escapeHtml(student.avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80')}" alt="${escapeHtml(student.fullName)}">
          <div class="student-tbl-info">
            <span class="student-tbl-name">${escapeHtml(student.fullName)}</span>
            <span class="student-tbl-email">${escapeHtml(student.email)}</span>
          </div>
        </div>
      </td>
      <td>
        <span class="program-tag">${escapeHtml(student.studentId)}</span>
        <div class="degree-sub">${escapeHtml(student.degree || 'Degree Program')}</div>
      </td>
      <td>
        <span style="font-weight: 500; font-size: 0.85rem;">${escapeHtml(student.department)}</span>
      </td>
      <td>
        <span style="color: var(--text-muted); font-size: 0.82rem;">${escapeHtml(student.year || 'Undergrad')}</span>
      </td>
      <td>
        <span class="gpa-cell-badge ${getGpaClass(student.gpa)}">${Number(student.gpa || 0).toFixed(2)}</span>
      </td>
      <td>
        <span class="status-badge ${getStatusClass(student.status)}">
          <i class="fa-solid fa-circle" style="font-size: 0.45rem;"></i>
          ${escapeHtml(student.status || 'Enrolled')}
        </span>
      </td>
      <td class="text-right">
        <div class="action-btns-group">
          <button class="btn-tbl-action btn-tbl-view" title="View Profile" onclick="viewStudentDetails(${student.id})">
            <i class="fa-solid fa-eye"></i>
          </button>
          <button class="btn-tbl-action btn-tbl-edit" title="Edit Student (PUT)" onclick="handleEditClick(${student.id})">
            <i class="fa-solid fa-pen"></i>
          </button>
          <button class="btn-tbl-action btn-tbl-del" title="Delete Student (DELETE)" onclick="handleDeleteClick(${student.id})">
            <i class="fa-solid fa-trash"></i>
          </button>
        </div>
      </td>
    </tr>
  `).join('');
}

function renderCardsView(list) {
  elements.cardsViewContainer.innerHTML = list.map(student => `
    <div class="student-card">
      <div class="card-top">
        <img class="card-avatar" src="${escapeHtml(student.avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80')}" alt="${escapeHtml(student.fullName)}">
        <div class="card-main-meta">
          <span class="card-student-name">${escapeHtml(student.fullName)}</span>
          <span class="card-student-id">${escapeHtml(student.studentId)}</span>
          <span class="status-badge ${getStatusClass(student.status)}" style="margin-top: 4px; width: fit-content;">
            ${escapeHtml(student.status)}
          </span>
        </div>
      </div>

      <div class="card-stats-row">
        <div class="card-stat-box">
          <span class="card-stat-label">Major / Dept</span>
          <span class="card-stat-val" style="font-size:0.75rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">${escapeHtml(student.department)}</span>
        </div>
        <div class="card-stat-box">
          <span class="card-stat-label">GPA</span>
          <span class="card-stat-val ${getGpaClass(student.gpa)}" style="font-family: var(--font-mono);">${Number(student.gpa || 0).toFixed(2)}</span>
        </div>
      </div>

      <div class="card-actions">
        <span style="font-size:0.75rem; color: var(--text-muted);">${escapeHtml(student.year || 'Junior')}</span>
        <div class="action-btns-group">
          <button class="btn-tbl-action btn-tbl-view" title="View Details" onclick="viewStudentDetails(${student.id})">
            <i class="fa-solid fa-eye"></i>
          </button>
          <button class="btn-tbl-action btn-tbl-edit" title="Edit Student (PUT)" onclick="handleEditClick(${student.id})">
            <i class="fa-solid fa-pen"></i>
          </button>
          <button class="btn-tbl-action btn-tbl-del" title="Delete Student (DELETE)" onclick="handleDeleteClick(${student.id})">
            <i class="fa-solid fa-trash"></i>
          </button>
        </div>
      </div>
    </div>
  `).join('');
}

// Global action bridges for inline onclicks
window.viewStudentDetails = function(id) {
  const student = state.students.find(s => s.id === id);
  if (!student) return;

  elements.modalProfileAvatar.src = student.avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80';
  elements.modalProfileName.textContent = student.fullName;
  elements.modalProfileId.textContent = student.studentId;
  elements.modalProfileStatus.textContent = student.status || 'Enrolled';
  elements.modalProfileStatus.className = `status-badge ${getStatusClass(student.status)}`;
  elements.modalProfileDept.textContent = student.department;
  elements.modalProfileDegree.textContent = student.degree || 'Degree Program';
  elements.modalProfileGpa.textContent = `${Number(student.gpa || 0).toFixed(2)} / 4.00`;
  elements.modalProfileYear.textContent = `${student.year || 'Undergraduate'} • ${student.semester || 'Fall 2024'}`;
  elements.modalProfileEmail.textContent = student.email;
  elements.modalProfilePhone.textContent = student.phone || 'N/A';
  elements.modalProfileAddress.textContent = student.address || 'Campus Housing, Apex University';

  elements.modalBtnEdit.onclick = () => {
    elements.profileModal.classList.remove('active');
    startEditStudent(student);
  };

  elements.modalBtnDelete.onclick = () => {
    elements.profileModal.classList.remove('active');
    promptDeleteStudent(student);
  };

  elements.profileModal.classList.add('active');
};

window.handleEditClick = function(id) {
  const student = state.students.find(s => s.id === id);
  if (student) startEditStudent(student);
};

window.handleDeleteClick = function(id) {
  const student = state.students.find(s => s.id === id);
  if (student) promptDeleteStudent(student);
};

// ==========================================
// 4. METRICS COMPUTATION
// ==========================================
function updateMetrics() {
  const total = state.students.length;
  elements.metricTotal.textContent = total;

  const enrolled = state.students.filter(s => (s.status || '').toLowerCase() === 'enrolled').length;
  elements.metricEnrolled.textContent = enrolled;

  if (total > 0) {
    const avgGpa = state.students.reduce((acc, s) => acc + (Number(s.gpa) || 0), 0) / total;
    elements.metricGpa.textContent = avgGpa.toFixed(2);
  } else {
    elements.metricGpa.textContent = "0.00";
  }

  // Top department
  const deptCounts = {};
  state.students.forEach(s => {
    if (s.department) {
      deptCounts[s.department] = (deptCounts[s.department] || 0) + 1;
    }
  });

  let topDept = "Computing & AI";
  let maxCount = 0;
  for (const [dept, count] of Object.entries(deptCounts)) {
    if (count > maxCount) {
      maxCount = count;
      topDept = dept;
    }
  }
  elements.metricTopDept.textContent = topDept;
}

// ==========================================
// 5. SEED / RESET / EXPORT
// ==========================================
async function resetOrSeedDatabase() {
  if (!confirm("Reset database with standard sample students? This will populate records in JSON-Server.")) return;

  try {
    showToast('info', 'Database Reset', 'Refreshing student database with standard sample data...');
    
    // Check if any existing exist, clean them up or post new ones
    for (const student of DEFAULT_SEED_STUDENTS) {
      // Check if studentId already exists
      const exists = state.students.find(s => s.studentId === student.studentId);
      if (!exists) {
        await apiRequest(STUDENTS_ENDPOINT, 'POST', student);
      }
    }

    showToast('success', 'Database Initialized', 'Sample students created in JSON-Server!');
    await fetchStudents();
  } catch (err) {
    console.error("Seed error:", err);
    showToast('error', 'Seed Error', `Could not seed: ${err.message}`);
  }
}

function exportData() {
  if (state.students.length === 0) {
    showToast('error', 'Export Failed', 'No students to export.');
    return;
  }

  // Export JSON
  const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(state.students, null, 2));
  const downloadAnchor = document.createElement('a');
  downloadAnchor.setAttribute("href", dataStr);
  downloadAnchor.setAttribute("download", `apex_university_students_${Date.now()}.json`);
  document.body.appendChild(downloadAnchor);
  downloadAnchor.click();
  downloadAnchor.remove();

  showToast('success', 'Export Complete', 'Downloaded students JSON file.');
}

// ==========================================
// 6. EVENT LISTENERS & INITIALIZATION
// ==========================================
function setupEventListeners() {
  // Form Submission (Create or Update)
  elements.form.addEventListener('submit', handleFormSubmit);

  // Cancel Edit
  elements.btnCancelEdit.addEventListener('click', resetForm);

  // GPA Slider & Input Sync
  elements.gpaRange.addEventListener('input', (e) => {
    const val = Number(e.target.value).toFixed(2);
    elements.gpaNum.value = val;
    elements.gpaBadge.textContent = val;
  });

  elements.gpaNum.addEventListener('input', (e) => {
    let val = parseFloat(e.target.value);
    if (isNaN(val)) val = 0;
    if (val > 4.0) val = 4.0;
    if (val < 0) val = 0;
    elements.gpaRange.value = val;
    elements.gpaBadge.textContent = Number(val).toFixed(2);
  });

  // Generate ID button
  elements.btnGenId.addEventListener('click', () => {
    const deptPrefixes = {
      "Computer Science & AI": "CS",
      "Electrical & Robotics Engineering": "EE",
      "Biomedical & Life Sciences": "MED",
      "Data Science & Quantum Computing": "DS",
      "Digital Design & Human Computer Interaction": "DES",
      "Business & Financial Analytics": "BUS"
    };
    const prefix = deptPrefixes[elements.deptSelect.value] || "UNI";
    const randNum = Math.floor(100 + Math.random() * 900);
    elements.codeInput.value = `U2024-${prefix}${randNum}`;
    showToast('info', 'ID Generated', `Assigned ${elements.codeInput.value}`);
  });

  // Preset Avatars
  elements.presetAvatarBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      elements.presetAvatarBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const avatarUrl = btn.getAttribute('data-avatar');
      elements.avatarPreviewImg.src = avatarUrl;
      elements.avatarUrlInput.value = avatarUrl;
    });
  });

  // Custom Avatar Input
  elements.avatarUrlInput.addEventListener('input', (e) => {
    const url = e.target.value.trim();
    if (url) {
      elements.avatarPreviewImg.src = url;
      elements.presetAvatarBtns.forEach(b => b.classList.remove('active'));
    }
  });

  // Search Input
  elements.searchInput.addEventListener('input', (e) => {
    state.searchQuery = e.target.value;
    elements.searchClearBtn.classList.toggle('hidden', !state.searchQuery);
    renderData();
  });

  elements.searchClearBtn.addEventListener('click', () => {
    elements.searchInput.value = '';
    state.searchQuery = '';
    elements.searchClearBtn.classList.add('hidden');
    renderData();
  });

  // Filter Selects
  elements.filterDept.addEventListener('change', (e) => {
    state.selectedDept = e.target.value;
    syncDeptPills(state.selectedDept);
    renderData();
  });

  elements.filterStatus.addEventListener('change', (e) => {
    state.selectedStatus = e.target.value;
    renderData();
  });

  elements.sortBy.addEventListener('change', (e) => {
    state.sortBy = e.target.value;
    renderData();
  });

  // Department quick filter pills
  elements.deptPills.forEach(pill => {
    pill.addEventListener('click', () => {
      elements.deptPills.forEach(p => p.classList.remove('active'));
      pill.classList.add('active');
      const dept = pill.getAttribute('data-dept');
      state.selectedDept = dept;
      elements.filterDept.value = dept;
      renderData();
    });
  });

  function syncDeptPills(deptVal) {
    elements.deptPills.forEach(pill => {
      pill.classList.toggle('active', pill.getAttribute('data-dept') === deptVal);
    });
  }

  // View Mode Switch
  elements.viewTableBtn.addEventListener('click', () => {
    state.viewMode = 'table';
    elements.viewTableBtn.classList.add('active');
    elements.viewCardsBtn.classList.remove('active');
    renderData();
  });

  elements.viewCardsBtn.addEventListener('click', () => {
    state.viewMode = 'cards';
    elements.viewCardsBtn.classList.add('active');
    elements.viewTableBtn.classList.remove('active');
    renderData();
  });

  // Modals & Delete confirmation
  elements.btnCloseProfileModal.addEventListener('click', () => {
    elements.profileModal.classList.remove('active');
  });

  elements.btnCancelDelete.addEventListener('click', () => {
    elements.deleteModal.classList.remove('active');
    state.studentToDelete = null;
  });

  elements.btnConfirmDelete.addEventListener('click', executeDeleteStudent);

  // Close modals on backdrop click
  window.addEventListener('click', (e) => {
    if (e.target === elements.profileModal) elements.profileModal.classList.remove('active');
    if (e.target === elements.deleteModal) elements.deleteModal.classList.remove('active');
    if (!elements.themePicker?.contains(e.target) && !e.target.closest('.theme-picker')) {
      elements.themeMenu.classList.remove('show');
    }
  });

  // API Inspector Drawer Toggle
  elements.apiInspectorToggle.addEventListener('click', () => {
    elements.apiInspectorDrawer.classList.toggle('collapsed');
  });

  elements.btnApiInspector.addEventListener('click', () => {
    elements.apiInspectorDrawer.classList.remove('collapsed');
    elements.apiInspectorDrawer.scrollIntoView({ behavior: 'smooth' });
  });

  elements.btnClearLogs.addEventListener('click', (e) => {
    e.stopPropagation();
    elements.apiLogStream.innerHTML = `
      <div class="api-log-entry init">
        <span class="log-time">[System]</span>
        <span class="log-tag info">CLEARED</span>
        <span class="log-url">Log buffer cleared. Listening for new JSON-Server requests...</span>
      </div>
    `;
    state.apiLogCount = 0;
    elements.apiCounter.textContent = "0";
  });

  // Action Buttons
  elements.btnExportData.addEventListener('click', exportData);
  elements.btnSeedData.addEventListener('click', resetOrSeedDatabase);
  elements.btnOpenCreateModal.addEventListener('click', () => {
    resetForm();
    elements.form.scrollIntoView({ behavior: 'smooth', block: 'start' });
    elements.nameInput.focus();
  });

  elements.btnEmptyReset.addEventListener('click', () => {
    elements.searchInput.value = '';
    state.searchQuery = '';
    state.selectedDept = 'ALL';
    state.selectedStatus = 'ALL';
    elements.filterDept.value = 'ALL';
    elements.filterStatus.value = 'ALL';
    syncDeptPills('ALL');
    renderData();
  });

  // Themes
  elements.themeToggleBtn.addEventListener('click', (e) => {
    e.stopPropagation();
    elements.themeMenu.classList.toggle('show');
  });

  elements.themeOptions.forEach(opt => {
    opt.addEventListener('click', () => {
      const theme = opt.getAttribute('data-set-theme');
      document.body.setAttribute('data-theme', theme);
      elements.themeOptions.forEach(o => o.classList.remove('active'));
      opt.classList.add('active');
      elements.themeMenu.classList.remove('show');
      localStorage.setItem('apex_theme', theme);
      showToast('info', 'Theme Changed', `Switched theme to ${opt.textContent.trim()}`);
    });
  });

  // Restore saved theme
  const savedTheme = localStorage.getItem('apex_theme');
  if (savedTheme) {
    document.body.setAttribute('data-theme', savedTheme);
    elements.themeOptions.forEach(o => o.classList.toggle('active', o.getAttribute('data-set-theme') === savedTheme));
  }
}

// ==========================================
// 7. TOAST NOTIFICATIONS & UTILITIES
// ==========================================
function showToast(type = 'info', title = '', message = '') {
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;

  const iconMap = {
    success: 'fa-circle-check',
    error: 'fa-triangle-exclamation',
    info: 'fa-circle-info'
  };

  toast.innerHTML = `
    <i class="fa-solid ${iconMap[type] || 'fa-bell'} toast-icon"></i>
    <div class="toast-body">
      <span class="toast-title">${escapeHtml(title)}</span>
      <span class="toast-msg">${escapeHtml(message)}</span>
    </div>
  `;

  elements.toastContainer.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(100%)';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

function showLoading(isLoading) {
  elements.loadingState.classList.toggle('hidden', !isLoading);
}

function escapeHtml(str) {
  if (typeof str !== 'string') return String(str || '');
  return str.replace(/[&<>'"]/g, 
    tag => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' }[tag] || tag)
  );
}

// Bootstrap Application
document.addEventListener('DOMContentLoaded', () => {
  setupEventListeners();
  fetchStudents();
});
