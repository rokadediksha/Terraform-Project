<?php
declare(strict_types=1);

// Only handle POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: index.html');
    exit;
}

// ── Database credentials (injected by Terraform user_data) ──
$db_host = getenv('DB_HOST') ?: 'localhost';
$db_user = getenv('DB_USER') ?: 'admin';
$db_pass = getenv('DB_PASS') ?: '';
$db_name = getenv('DB_NAME') ?: 'hospitaldb';

// ── Connect ──────────────────────────────────────────────
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

if ($conn->connect_error) {
    http_response_code(500);
    error_log('DB connection failed: ' . $conn->connect_error);
    die('Service temporarily unavailable. Please try again later.');
}

$conn->set_charset('utf8mb4');

// ── Sanitize & validate inputs ───────────────────────────
$name       = trim($_POST['name']       ?? '');
$phone      = trim($_POST['phone']      ?? '');
$date       = trim($_POST['date']       ?? '');
$time       = trim($_POST['time']       ?? '');
$department = trim($_POST['department'] ?? '');

if (!$name || !$phone || !$date || !$time || !$department) {
    http_response_code(400);
    die('All fields are required.');
}

if (!preg_match('/^\d{10}$/', $phone)) {
    http_response_code(400);
    die('Phone number must be exactly 10 digits.');
}

if (!DateTime::createFromFormat('Y-m-d', $date)) {
    http_response_code(400);
    die('Invalid date format.');
}

// ── Insert with prepared statement ───────────────────────
$sql  = "INSERT INTO appointments (name, phone, date, time, department, status, created_at)
         VALUES (?, ?, ?, ?, ?, 'booked', NOW())";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    http_response_code(500);
    error_log('Prepare failed: ' . $conn->error);
    die('Service error. Please try again later.');
}

$stmt->bind_param('sssss', $name, $phone, $date, $time, $department);

if ($stmt->execute()) {
    $stmt->close();
    $conn->close();
    header('Location: index.html?status=success');
    exit;
}

error_log('Execute failed: ' . $stmt->error);
$stmt->close();
$conn->close();

http_response_code(500);
die('Could not save appointment. Please try again.');
