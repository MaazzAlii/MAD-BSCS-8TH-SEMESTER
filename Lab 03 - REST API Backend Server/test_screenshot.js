const puppeteer = require('puppeteer-core');
const path = require('path');
const fs = require('fs');

async function runScreenshotTests() {
  console.log('🚀 Starting Automated Screenshot & CRUD Test Suite...');

  // Ensure assets and assest directories exist
  const assetsDir = path.join(__dirname, 'assets');
  if (!fs.existsSync(assetsDir)) {
    fs.mkdirSync(assetsDir, { recursive: true });
  }

  const assestDir = path.join(__dirname, 'assest');
  if (!fs.existsSync(assestDir)) {
    fs.mkdirSync(assestDir, { recursive: true });
  }

  const chromePath = '/usr/bin/google-chrome';
  console.log(`Using Chrome binary at: ${chromePath}`);

  const browser = await puppeteer.launch({
    executablePath: chromePath,
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage', '--window-size=1600,1050']
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1600, height: 1050 });

    console.log('🌐 1. Navigating to http://localhost:3000...');
    await page.goto('http://localhost:3000', { waitUntil: 'networkidle0', timeout: 15000 });

    // Wait for table to load
    await page.waitForSelector('.students-table tbody tr', { timeout: 10000 });
    console.log('✅ Student table loaded successfully.');

    // Screenshot 1: Full Main Dashboard Overview (READ)
    const shot1 = path.join(assetsDir, '01_dashboard_overview.png');
    await page.screenshot({ path: shot1 });
    fs.copyFileSync(shot1, path.join(assestDir, '01_dashboard_overview.png'));
    console.log(`📸 Saved Screenshot 1: ${shot1}`);

    // Screenshot 2: Fill Form & Create New Student (CREATE / POST)
    console.log('📝 2. Filling student registration form for CREATE (POST)...');
    await page.type('#student-name', 'Oliver Queen');
    await page.click('#btn-gen-id');
    await page.type('#student-email', 'oliver.queen@apexuni.edu');
    await page.select('#student-dept', 'Computer Science & AI');
    await page.type('#student-degree', 'B.S. Artificial Intelligence & Robotics');
    await page.select('#student-year', 'Junior');
    await page.select('#student-status', 'Enrolled');

    // Set GPA
    await page.$eval('#student-gpa', el => el.value = '3.96');
    await page.$eval('#student-gpa', el => el.dispatchEvent(new Event('input')));

    await page.type('#student-phone', '+1 (555) 987-6543');
    await page.type('#student-address', '100 Starling Hall, Tech District');

    // Submit form (POST)
    console.log('💾 Submitting form to trigger POST /students...');
    await page.click('#btn-submit-form');

    // Wait for toast notification
    await page.waitForSelector('.toast-success', { timeout: 5000 });
    await new Promise(r => setTimeout(r, 700));

    const shot2 = path.join(assetsDir, '02_student_created_post.png');
    await page.screenshot({ path: shot2 });
    fs.copyFileSync(shot2, path.join(assestDir, '02_student_created_post.png'));
    console.log(`📸 Saved Screenshot 2: ${shot2}`);

    // Screenshot 3: View Student Profile Modal (READ Profile Details)
    console.log('🔍 3. Opening student profile details modal...');
    await page.click('.btn-tbl-view');
    await page.waitForSelector('#profile-modal.active', { timeout: 5000 });
    await new Promise(r => setTimeout(r, 600));

    const shot3 = path.join(assetsDir, '03_student_profile_modal.png');
    await page.screenshot({ path: shot3 });
    fs.copyFileSync(shot3, path.join(assestDir, '03_student_profile_modal.png'));
    console.log(`📸 Saved Screenshot 3: ${shot3}`);

    // Close modal
    await page.click('#btn-close-profile-modal');
    await new Promise(r => setTimeout(r, 500));

    // Screenshot 4: Edit Student Form (UPDATE / PUT)
    console.log('✏️ 4. Triggering Edit mode for UPDATE (PUT)...');
    await page.click('.btn-tbl-edit');
    await new Promise(r => setTimeout(r, 600));

    const shot4 = path.join(assetsDir, '04_student_edit_mode_put.png');
    await page.screenshot({ path: shot4 });
    fs.copyFileSync(shot4, path.join(assestDir, '04_student_edit_mode_put.png'));
    console.log(`📸 Saved Screenshot 4: ${shot4}`);

    // Cancel edit to restore form
    await page.click('#btn-cancel-edit');
    await new Promise(r => setTimeout(r, 400));

    // Screenshot 5: Switch to Card Grid View
    console.log('🎴 5. Switching to Cards Grid View...');
    await page.click('#view-cards-btn');
    await new Promise(r => setTimeout(r, 600));

    const shot5 = path.join(assetsDir, '05_cards_grid_view.png');
    await page.screenshot({ path: shot5 });
    fs.copyFileSync(shot5, path.join(assestDir, '05_cards_grid_view.png'));
    console.log(`📸 Saved Screenshot 5: ${shot5}`);

    // Screenshot 6: Open API Live Inspector Drawer
    console.log('📡 6. Opening Live REST API Inspector Drawer...');
    await page.click('#btn-api-inspector');
    await new Promise(r => setTimeout(r, 600));

    const shot6 = path.join(assetsDir, '06_api_inspector_live_logs.png');
    await page.screenshot({ path: shot6 });
    fs.copyFileSync(shot6, path.join(assestDir, '06_api_inspector_live_logs.png'));
    console.log(`📸 Saved Screenshot 6: ${shot6}`);

    console.log('\n🎉 ALL TESTS PASSED! High-resolution screenshots saved to:');
    console.log(`📁 ${assetsDir}`);
  } catch (error) {
    console.error('❌ Test failed with error:', error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

runScreenshotTests();
