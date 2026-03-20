#!/bin/bash
set -euo pipefail

# ── System setup ─────────────────────────────────────────
yum update -y
yum install -y httpd php php-mysqlnd mysql

# Write DB credentials as environment variables for Apache/PHP
cat >> /etc/environment <<ENV
DB_HOST="${rds_host}"
DB_USER="${db_user}"
DB_PASS="${db_pass}"
DB_NAME="${db_name}"
ENV

# Make env vars available inside Apache child processes
cat > /etc/httpd/conf.d/env.conf <<APACHECONF
SetEnv DB_HOST "${rds_host}"
SetEnv DB_USER "${db_user}"
SetEnv DB_PASS "${db_pass}"
SetEnv DB_NAME "${db_name}"
APACHECONF

# ── Web files ─────────────────────────────────────────────
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Hospital Patient Appointment System</title>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
    .container { max-width: 820px; margin: 0 auto; background: #fff; border-radius: 24px; box-shadow: 0 25px 60px rgba(0,0,0,0.18); padding: 50px; position: relative; overflow: hidden; }
    .badge { position: absolute; top: 20px; right: 20px; background: linear-gradient(135deg, #48bb78, #38a169); color: #fff; padding: 10px 22px; border-radius: 20px; font-size: 0.85em; font-weight: 600; box-shadow: 0 6px 20px rgba(72,187,120,0.35); }
    h1 { text-align: center; font-size: 2.6em; background: linear-gradient(135deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 8px; }
    .subtitle { text-align: center; color: #718096; font-size: 1.1em; margin-bottom: 40px; }
    .form-section { background: #f7fafc; padding: 36px; border-radius: 18px; border-left: 5px solid #667eea; margin-bottom: 30px; }
    .form-section h3 { text-align: center; color: #2d3748; margin-bottom: 28px; font-size: 1.2em; }
    .form-group { margin-bottom: 22px; }
    label { display: block; margin-bottom: 7px; color: #2d3748; font-weight: 600; }
    input, select { width: 100%; padding: 16px 18px; border: 2px solid #e2e8f0; border-radius: 12px; font-size: 15px; background: #fff; transition: border-color 0.25s, box-shadow 0.25s, transform 0.2s; }
    input:focus, select:focus { outline: none; border-color: #667eea; box-shadow: 0 0 0 4px rgba(102,126,234,0.12); transform: translateY(-1px); }
    .input-row { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
    button[type="submit"] { width: 100%; padding: 20px; background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; border: none; border-radius: 12px; font-size: 17px; font-weight: 700; cursor: pointer; transition: transform 0.25s, box-shadow 0.25s; text-transform: uppercase; margin-top: 8px; }
    button[type="submit"]:hover { transform: translateY(-3px); box-shadow: 0 18px 40px rgba(102,126,234,0.4); }
    .alert { display: none; padding: 24px; border-radius: 12px; text-align: center; font-size: 1.1em; margin-top: 22px; animation: slideIn 0.4s ease; }
    .alert-success { background: linear-gradient(135deg, #c6f6d5, #9ae6b4); color: #22543d; border: 2px solid #38a169; }
    @keyframes slideIn { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }
    .status-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; margin-top: 32px; }
    .status-card { background: linear-gradient(135deg, #667eea, #764ba2); color: #fff; padding: 24px; border-radius: 14px; text-align: center; }
    .status-icon { font-size: 2em; margin-bottom: 8px; }
    @media (max-width: 640px) { .container { padding: 28px 18px; } h1 { font-size: 2em; } .input-row { grid-template-columns: 1fr; } }
  </style>
</head>
<body>
  <div class="container">
    <div class="badge">&#10003; Terraform + Apache</div>
    <h1>&#127973; Patient Appointment System</h1>
    <p class="subtitle">Book your appointment online in just a few minutes</p>
    <div class="form-section">
      <h3>&#128203; Book an Appointment</h3>
      <form id="appointmentForm" method="POST" action="submit.php">
        <div class="input-row">
          <div class="form-group">
            <label for="name">&#128100; Full Name</label>
            <input type="text" id="name" name="name" required placeholder="Your full name" />
          </div>
          <div class="form-group">
            <label for="phone">&#128222; Phone Number</label>
            <input type="tel" id="phone" name="phone" required placeholder="10-digit number" pattern="[0-9]{10}" title="Enter a 10-digit phone number" />
          </div>
        </div>
        <div class="input-row">
          <div class="form-group">
            <label for="date">&#128197; Appointment Date</label>
            <input type="date" id="date" name="date" required />
          </div>
          <div class="form-group">
            <label for="time">&#128336; Preferred Time</label>
            <select id="time" name="time" required>
              <option value="">Select time slot</option>
              <option value="09:00-10:00">09:00 AM - 10:00 AM</option>
              <option value="10:00-11:00">10:00 AM - 11:00 AM</option>
              <option value="11:00-12:00">11:00 AM - 12:00 PM</option>
              <option value="14:00-15:00">02:00 PM - 03:00 PM</option>
              <option value="15:00-16:00">03:00 PM - 04:00 PM</option>
              <option value="16:00-17:00">04:00 PM - 05:00 PM</option>
            </select>
          </div>
        </div>
        <div class="form-group">
          <label for="department">&#127973; Department</label>
          <select id="department" name="department" required>
            <option value="">Choose department</option>
            <option value="Cardiology">Cardiology (Heart)</option>
            <option value="Neurology">Neurology (Brain)</option>
            <option value="Orthopedics">Orthopedics (Bones)</option>
            <option value="Dentistry">Dentistry</option>
            <option value="General Medicine">General Medicine</option>
            <option value="Pediatrics">Pediatrics (Children)</option>
            <option value="Gynecology">Gynecology</option>
          </select>
        </div>
        <button type="submit">&#10003; Book Appointment</button>
      </form>
      <div id="alertBox" class="alert alert-success">
        &#10003; <strong>Appointment booked successfully!</strong><br /><br />
        We will call you to confirm within 24 hours.
      </div>
    </div>
    <div class="status-grid">
      <div class="status-card"><div class="status-icon">&#128994;</div><strong>EC2 Web Server</strong><br />Public Subnet</div>
      <div class="status-card"><div class="status-icon">&#128274;</div><strong>RDS MySQL</strong><br />Private Subnets</div>
      <div class="status-card"><div class="status-icon">&#127760;</div><strong>VPC Network</strong><br />t3.micro Free Tier</div>
    </div>
  </div>
  <script>
    document.getElementById('date').min = new Date().toISOString().split('T')[0];
    const params = new URLSearchParams(window.location.search);
    if (params.get('status') === 'success') {
      const box = document.getElementById('alertBox');
      box.style.display = 'block';
      box.scrollIntoView({ behavior: 'smooth' });
      setTimeout(() => { box.style.display = 'none'; }, 8000);
      history.replaceState(null, '', window.location.pathname);
    }
  </script>
</body>
</html>
HTML

cat > /var/www/html/submit.php <<'PHP'
<?php
declare(strict_types=1);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { header('Location: index.html'); exit; }

$db_host = getenv('DB_HOST') ?: 'localhost';
$db_user = getenv('DB_USER') ?: 'admin';
$db_pass = getenv('DB_PASS') ?: '';
$db_name = getenv('DB_NAME') ?: 'hospitaldb';

$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
if ($conn->connect_error) { http_response_code(500); error_log('DB: ' . $conn->connect_error); die('Service unavailable.'); }
$conn->set_charset('utf8mb4');

$name       = trim($_POST['name']       ?? '');
$phone      = trim($_POST['phone']      ?? '');
$date       = trim($_POST['date']       ?? '');
$time       = trim($_POST['time']       ?? '');
$department = trim($_POST['department'] ?? '');

if (!$name || !$phone || !$date || !$time || !$department) { http_response_code(400); die('All fields are required.'); }
if (!preg_match('/^\d{10}$/', $phone)) { http_response_code(400); die('Phone must be 10 digits.'); }

$stmt = $conn->prepare("INSERT INTO appointments (name, phone, date, time, department, status, created_at) VALUES (?, ?, ?, ?, ?, 'booked', NOW())");
if (!$stmt) { http_response_code(500); die('Server error.'); }
$stmt->bind_param('sssss', $name, $phone, $date, $time, $department);

if ($stmt->execute()) { $stmt->close(); $conn->close(); header('Location: index.html?status=success'); exit; }
$stmt->close(); $conn->close();
http_response_code(500); die('Could not save appointment. Please try again.');
PHP

cat > /var/www/html/view.php <<'PHP'
<?php
declare(strict_types=1);
$db_host = getenv('DB_HOST') ?: 'localhost';
$db_user = getenv('DB_USER') ?: 'admin';
$db_pass = getenv('DB_PASS') ?: '';
$db_name = getenv('DB_NAME') ?: 'hospitaldb';

$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
if ($conn->connect_error) { die('DB error: ' . htmlspecialchars($conn->connect_error)); }
$conn->set_charset('utf8mb4');
$result = $conn->query("SELECT id, name, phone, date, time, department, status, created_at FROM appointments ORDER BY date ASC, time ASC");
?><!DOCTYPE html>
<html lang="en"><head>
  <meta charset="UTF-8"/><meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Appointment Records</title>
  <style>
    *{margin:0;padding:0;box-sizing:border-box}body{font-family:'Segoe UI',sans-serif;background:linear-gradient(135deg,#667eea,#764ba2);min-height:100vh;padding:30px 20px}
    .container{max-width:1100px;margin:0 auto;background:#fff;border-radius:20px;box-shadow:0 20px 60px rgba(0,0,0,.15);padding:40px}
    h1{text-align:center;font-size:2em;background:linear-gradient(135deg,#667eea,#764ba2);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;margin-bottom:30px}
    a{display:inline-block;margin-bottom:20px;color:#667eea;text-decoration:none;font-weight:600}a:hover{text-decoration:underline}
    table{width:100%;border-collapse:collapse;font-size:.95em}thead{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff}
    th,td{padding:14px 16px;text-align:left;border-bottom:1px solid #e2e8f0}tbody tr:hover{background:#f7fafc}
    .badge{display:inline-block;padding:4px 12px;border-radius:20px;font-size:.82em;font-weight:600;text-transform:capitalize}
    .badge-booked{background:#c6f6d5;color:#22543d}.badge-cancelled{background:#fed7d7;color:#742a2a}
    .empty{text-align:center;padding:40px;color:#718096;font-size:1.1em}
  </style>
</head><body><div class="container">
  <a href="index.html">&#8592; Back to Booking</a>
  <h1>&#128203; Appointment Records</h1>
  <?php if ($result && $result->num_rows > 0): ?>
  <table><thead><tr><th>#</th><th>Name</th><th>Phone</th><th>Date</th><th>Time</th><th>Department</th><th>Status</th><th>Booked At</th></tr></thead>
  <tbody><?php while ($r = $result->fetch_assoc()): ?>
  <tr>
    <td><?=(int)$r['id']?></td>
    <td><?=htmlspecialchars($r['name'])?></td>
    <td><?=htmlspecialchars($r['phone'])?></td>
    <td><?=htmlspecialchars($r['date'])?></td>
    <td><?=htmlspecialchars($r['time'])?></td>
    <td><?=htmlspecialchars($r['department'])?></td>
    <td><span class="badge badge-<?=htmlspecialchars($r['status'])?>"><?=htmlspecialchars($r['status'])?></span></td>
    <td><?=htmlspecialchars($r['created_at'])?></td>
  </tr><?php endwhile;?></tbody></table>
  <?php else: ?><p class="empty">No appointments found.</p><?php endif;?>
</div></body></html>
<?php $conn->close();?>
PHP

# ── Create database table ─────────────────────────────────
# Wait for RDS to be reachable (up to 3 minutes)
for i in $(seq 1 18); do
  mysql -h "${rds_host}" -u "${db_user}" -p"${db_pass}" -e "SELECT 1;" "${db_name}" 2>/dev/null && break
  echo "Waiting for RDS... attempt $i"
  sleep 10
done

mysql -h "${rds_host}" -u "${db_user}" -p"${db_pass}" "${db_name}" <<'SQL'
CREATE TABLE IF NOT EXISTS appointments (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(255)  NOT NULL,
  phone       VARCHAR(20)   NOT NULL,
  date        DATE          NOT NULL,
  time        VARCHAR(50)   NOT NULL,
  department  VARCHAR(100)  NOT NULL,
  status      VARCHAR(50)   NOT NULL DEFAULT 'booked',
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
SQL

# ── Permissions & start Apache ────────────────────────────
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

systemctl enable httpd
systemctl start httpd
