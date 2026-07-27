<?php
// index.php
require 'config.php';
if (!isset($_SESSION['admin'])) header("Location: login.php");

$today = date('Y-m-d');

// Logika Panggil Nomor Berikutnya
if (isset($_GET['call_next'])) {
    $doctor = $_GET['doctor'];

    // 1. Cari antrian 'mendatang' paling awal untuk dokter ini hari ini
    $q_url = $base_url . "/upcoming_queues?doctor_name=eq." . urlencode($doctor) . "&schedule_date=eq." . $today . "&status=eq.mendatang&order=ticket_number.asc&limit=1";
    $next_ticket = callAPI("GET", $q_url);

    if (!empty($next_ticket)) {
        $ticket_no = $next_ticket[0]['ticket_number'];

        // 2. Update status antrian tersebut jadi 'aktif'
        callAPI("PATCH", $base_url . "/upcoming_queues?ticket_number=eq." . $ticket_no, json_encode(["status" => "aktif"]));

        // 3. Update called_number_label di active_queues
        callAPI("PATCH", $base_url . "/active_queues?doctor_name=eq." . urlencode($doctor) . "&date=eq." . $today, json_encode(["called_number_label" => $ticket_no]));

        header("Location: index.php?success=Called " . $ticket_no);
    } else {
        header("Location: index.php?error=Tidak ada antrian berikutnya");
    }
}

// Ambil semua data antrian aktif hari ini
$queues = callAPI("GET", $base_url . "/active_queues?date=eq." . $today);
?>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard - HealLine</title>
    <style>
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; padding: 20px; }
        .card { border: 2px solid #1D70B8; border-radius: 10px; padding: 20px; text-align: center; cursor: pointer; background: #f9f9f9; transition: 0.3s; }
        .card:hover { background: #DCEAFB; transform: scale(1.02); }
        .card h3 { margin: 0; color: #1D70B8; font-size: 14px; }
        .card h4 { margin: 5px 0; color: #666; font-size: 12px; }
        .card .number { font-size: 40px; font-weight: bold; margin: 10px 0; color: #333; }
        .card .btn-call { background: #1D70B8; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <div style="padding: 20px;">
        <h2>Dashboard Antrian Real-time (<?php echo $today; ?>)</h2>
        <a href="login.php">Logout</a>
    </div>

    <div class="grid">
        <?php foreach ($queues as $q): ?>
            <div class="card" onclick="location.href='?call_next=1&doctor=<?php echo urlencode($q['doctor_name']); ?>'">
                <h3><?php echo $q['poli_name']; ?></h3>
                <h4>dr. <?php echo $q['doctor_name']; ?></h4>
                <div class="number"><?php echo $q['called_number_label'] ?: '-'; ?></div>
                <button class="btn-call">PANGGIL BERIKUTNYA</button>
            </div>
        <?php endforeach; ?>
    </div>

    <script>
        // Auto refresh halaman setiap 30 detik untuk melihat update
        setTimeout(function(){ location.reload(); }, 30000);
    </script>
</body>
</html>
