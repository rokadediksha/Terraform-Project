<?php
declare(strict_types=1);

// ── Database credentials (injected by Terraform user_data) ──
$db_host = getenv('DB_HOST') ?: 'localhost';
$db_user = getenv('DB_USER') ?: 'admin';
$db_pass = getenv('DB_PASS') ?: '';
$db_name = getenv('DB_NAME') ?: 'hospitaldb';

$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

if ($conn->connect_error) {
    die('Database connection failed: ' . htmlspecialchars($conn->connect_error));
}

$conn->set_charset('utf8mb4');

$result = $conn->query(
    "SELECT id, name, phone, date, time, department, status, created_at
     FROM appointments
     ORDER BY date ASC, time ASC"
);
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Appointment Records</title>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #667eea, #764ba2);
      min-height: 100vh;
      padding: 30px 20px;
    }
    .container {
      max-width: 1100px;
      margin: 0 auto;
      background: #fff;
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.15);
      padding: 40px;
    }
    h1 {
      text-align: center;
      font-size: 2em;
      background: linear-gradient(135deg, #667eea, #764ba2);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      margin-bottom: 30px;
    }
    .back-link {
      display: inline-block;
      margin-bottom: 20px;
      color: #667eea;
      text-decoration: none;
      font-weight: 600;
    }
    .back-link:hover { text-decoration: underline; }
    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.95em;
    }
    thead {
      background: linear-gradient(135deg, #667eea, #764ba2);
      color: #fff;
    }
    th, td {
      padding: 14px 16px;
      text-align: left;
      border-bottom: 1px solid #e2e8f0;
    }
    tbody tr:hover { background: #f7fafc; }
    .badge {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 0.82em;
      font-weight: 600;
      text-transform: capitalize;
    }
    .badge-booked    { background: #c6f6d5; color: #22543d; }
    .badge-cancelled { background: #fed7d7; color: #742a2a; }
    .no-records {
      text-align: center;
      padding: 40px;
      color: #718096;
      font-size: 1.1em;
    }
    @media (max-width: 700px) {
      table, thead, tbody, th, td, tr { display: block; }
      thead tr { display: none; }
      td { padding: 8px 12px; }
      td::before {
        content: attr(data-label) ': ';
        font-weight: 600;
        color: #4a5568;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <a class="back-link" href="index.html">&#8592; Back to Booking</a>
    <h1>&#128203; Appointment Records</h1>

    <?php if ($result && $result->num_rows > 0): ?>
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Name</th>
          <th>Phone</th>
          <th>Date</th>
          <th>Time</th>
          <th>Department</th>
          <th>Status</th>
          <th>Booked At</th>
        </tr>
      </thead>
      <tbody>
        <?php while ($row = $result->fetch_assoc()): ?>
        <tr>
          <td data-label="ID"><?= (int)$row['id'] ?></td>
          <td data-label="Name"><?= htmlspecialchars($row['name']) ?></td>
          <td data-label="Phone"><?= htmlspecialchars($row['phone']) ?></td>
          <td data-label="Date"><?= htmlspecialchars($row['date']) ?></td>
          <td data-label="Time"><?= htmlspecialchars($row['time']) ?></td>
          <td data-label="Department"><?= htmlspecialchars($row['department']) ?></td>
          <td data-label="Status">
            <span class="badge badge-<?= htmlspecialchars($row['status']) ?>">
              <?= htmlspecialchars($row['status']) ?>
            </span>
          </td>
          <td data-label="Booked At"><?= htmlspecialchars($row['created_at']) ?></td>
        </tr>
        <?php endwhile; ?>
      </tbody>
    </table>
    <?php else: ?>
    <p class="no-records">No appointments found.</p>
    <?php endif; ?>
  </div>
</body>
</html>
<?php $conn->close(); ?>
