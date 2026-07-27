<?php
// index.php

ob_start();

require('config.php');

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION['admin'])) {
    ob_end_clean();
    header("Location: login.php");
    exit();
}

$today = date('Y-m-d');

// ============================================================
// Logika Panggil Nomor Berikutnya
// ============================================================
if (isset($_GET['call_next'])) {

    $doctor = trim($_GET['doctor'] ?? '');

    // Validasi input
    if (empty($doctor)) {
        ob_end_clean();
        header("Location: index.php?error=Nama+dokter+tidak+valid");
        exit();
    }

    // ============================================================
    // STEP 1: DELETE row antrian yang sebelumnya berstatus 'aktif'
    //         untuk dokter ini hari ini di upcoming_queues
    // ============================================================
    $delete_url = $base_url . "/upcoming_queues"
                . "?doctor_name=eq." . urlencode($doctor)
                . "&schedule_date=eq." . $today
                . "&status=eq.aktif";

    $delete_result = callAPI("DELETE", $delete_url);

    // ============================================================
    // STEP 2: Cari antrian 'mendatang' paling awal untuk dokter ini
    // ============================================================
    $q_url = $base_url . "/upcoming_queues"
           . "?doctor_name=eq." . urlencode($doctor)
           . "&schedule_date=eq." . $today
           . "&status=eq.mendatang"
           . "&order=ticket_number.asc"
           . "&limit=1";

    $next_ticket = callAPI("GET", $q_url);

    // ✅ DEBUG SEMENTARA — Uncomment jika masih bermasalah
    /*
    echo "<pre>";
    echo "DELETE URL : " . $delete_url . "\n";
    echo "DELETE Result : "; var_dump($delete_result);
    echo "GET URL    : " . $q_url . "\n";
    echo "Next Ticket: "; var_dump($next_ticket);
    echo "</pre>";
    exit();
    */

    if (!empty($next_ticket) && is_array($next_ticket)) {

        $ticket_no = $next_ticket[0]['ticket_number'];

        // ============================================================
        // STEP 3: Update status antrian berikutnya menjadi 'aktif'
        // ============================================================
        $patch_result_1 = callAPI(
            "PATCH",
            $base_url . "/upcoming_queues"
                . "?ticket_number=eq." . urlencode($ticket_no)
                . "&doctor_name=eq."   . urlencode($doctor)
                . "&schedule_date=eq." . $today,
            ["status" => "aktif"]
        );

        // ============================================================
        // STEP 4: Update called_number_label di tabel active_queues
        // ============================================================
        $patch_result_2 = callAPI(
            "PATCH",
            $base_url . "/active_queues"
                . "?doctor_name=eq." . urlencode($doctor)
                . "&date=eq."        . $today,
            ["called_number_label" => $ticket_no]
        );

        ob_end_clean();
        header("Location: index.php?success=Berhasil+memanggil+" . urlencode($ticket_no));
        exit();

    } else {

        // ============================================================
        // Tidak ada antrian berikutnya
        // ============================================================
        ob_end_clean();
        header("Location: index.php?error=Tidak+ada+antrian+berikutnya");
        exit();

    }
}

// ============================================================
// Ambil semua data antrian aktif hari ini
// ============================================================
$queues = callAPI("GET", $base_url . "/active_queues?date=eq." . $today);

if (!is_array($queues)) {
    $queues = [];
}

ob_end_flush();
?>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - HealLine</title>
    <style>
        * { box-sizing: border-box; }

        body {
            font-family: Arial, sans-serif;
            background-color: #f0f2f5;
            margin: 0;
            padding: 20px;
        }

        .main-content-wrapper {
            max-width: 1200px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .header-section h2 { margin: 0; color: #333; }

        .header-section a {
            text-decoration: none;
            color: #dc3545;
            font-weight: bold;
            padding: 8px 16px;
            border: 1px solid #dc3545;
            border-radius: 5px;
            transition: 0.3s;
        }

        .header-section a:hover {
            background-color: #dc3545;
            color: white;
        }

        .message {
            padding: 12px 16px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-weight: bold;
        }

        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }

        .empty-state {
            grid-column: 1 / -1;
            text-align: center;
            padding: 40px;
            color: #666;
        }

        .card {
            border: 2px solid #1D70B8;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            background: #f9f9f9;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 200px;
        }

        .card:hover {
            background: #DCEAFB;
            transform: translateY(-5px);
            box-shadow: 0 6px 12px rgba(0,0,0,0.15);
        }

        .card h3 { margin: 0 0 4px 0; color: #1D70B8; font-size: 16px; }
        .card h4 { margin: 0 0 10px 0; color: #555; font-size: 13px; font-weight: normal; }

        .card .number {
            font-size: 52px;
            font-weight: bold;
            margin: 10px 0;
            color: #1D70B8;
            flex-grow: 1;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .card .number.empty { color: #ccc; font-size: 36px; }

        .card .btn-call {
            background: #1D70B8;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            width: 100%;
            transition: background-color 0.3s;
        }

        .card .btn-call:hover { background: #155a9b; }

        .refresh-info {
            text-align: right;
            font-size: 12px;
            color: #999;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="main-content-wrapper">

    <div class="header-section">
        <h2>
            🏥 Dashboard Antrian Real-time
            <small style="font-size:14px; color:#666;">
                (<?php echo htmlspecialchars($today); ?>)
            </small>
        </h2>
        <a href="login.php">🚪 Logout</a>
    </div>

    <?php
    if (isset($_GET['success'])) {
        echo '<p class="message success">✅ ' . htmlspecialchars($_GET['success']) . '</p>';
    } elseif (isset($_GET['error'])) {
        echo '<p class="message error">❌ ' . htmlspecialchars($_GET['error']) . '</p>';
    }
    ?>

    <div class="grid">
        <?php if (!empty($queues)): ?>
            <?php foreach ($queues as $q): ?>
                <?php
                $doctor_name  = htmlspecialchars($q['doctor_name']);
                $poli_name    = htmlspecialchars($q['poli_name']);
                $called_label = htmlspecialchars($q['called_number_label'] ?: '-');
                $number_class = ($q['called_number_label']) ? 'number' : 'number empty';
                ?>
                <div class="card"
                     onclick="location.href='?call_next=1&doctor=<?php echo urlencode($q['doctor_name']); ?>'">
                    <h3>POLI <?php echo strtoupper($poli_name); ?></h3>
                    <h4><?php echo $doctor_name; ?></h4>
                    <div class="<?php echo $number_class; ?>">
                        <?php echo $called_label; ?>
                    </div>
                    <button class="btn-call"
                            onclick="event.stopPropagation();
                                     location.href='?call_next=1&doctor=<?php echo urlencode($q['doctor_name']); ?>'">
                        📢 PANGGIL BERIKUTNYA
                    </button>
                </div>
            <?php endforeach; ?>
        <?php else: ?>
            <div class="empty-state">
                <p>📭 Tidak ada antrian aktif untuk hari ini.</p>
            </div>
        <?php endif; ?>
    </div>

    <div class="refresh-info">
        🔄 Halaman diperbarui otomatis dalam <span id="countdown">30</span> detik
    </div>

</div>

<script>
    // ✅ Bersihkan query string dari URL segera setelah halaman dimuat
    if (window.location.search !== '') {
        window.history.replaceState({}, document.title, 'index.php');
    }

    // ✅ Auto refresh kembali ke index.php bersih
    let seconds = 30;
    const countdownEl = document.getElementById('countdown');

    const timer = setInterval(function () {
        seconds--;
        if (countdownEl) countdownEl.textContent = seconds;
        if (seconds <= 0) {
            clearInterval(timer);
            window.location.href = 'index.php';
        }
    }, 1000);
</script>
</body>
</html>
