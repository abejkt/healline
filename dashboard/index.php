<?php
// index.php
require 'config.php'; // Pastikan path ke config.php benar
if (!isset($_SESSION['admin'])) {
    header("Location: login.php");
    exit(); // Penting: Hentikan eksekusi setelah redirect
}

$today = date('Y-m-d');

// Logika Panggil Nomor Berikutnya
if (isset($_GET['call_next'])) {
    $doctor = $_GET['doctor'];

    // 1. Cari antrian 'mendatang' paling awal untuk dokter ini hari ini
    // Menggunakan 'eq.' untuk PostgREST filter
    $q_url = $base_url . "/upcoming_queues?doctor_name=eq." . urlencode($doctor) . "&schedule_date=eq." . $today . "&status=eq.mendatang&order=ticket_number.asc&limit=1";
    $next_ticket = callAPI("GET", $q_url);

    if (!empty($next_ticket) && is_array($next_ticket)) {
        $ticket_no = $next_ticket[0]['ticket_number'];

        // 2. Update status antrian tersebut jadi 'aktif'
        // Pastikan PostgREST PATCH menerima JSON body, bukan query string untuk data
        callAPI("PATCH", $base_url . "/upcoming_queues?ticket_number=eq." . $ticket_no, ["status" => "aktif"]);

        // 3. Update called_number_label di active_queues
        // Pastikan PostgREST PATCH menerima JSON body, bukan query string untuk data
        callAPI("PATCH", $base_url . "/active_queues?doctor_name=eq." . urlencode($doctor) . "&date=eq." . $today, ["called_number_label" => $ticket_no]);

        header("Location: index.php?success=Called " . $ticket_no);
        exit();
    } else {
        header("Location: index.php?error=Tidak ada antrian berikutnya");
        exit();
    }
}

// Ambil semua data antrian aktif hari ini
$queues = callAPI("GET", $base_url . "/active_queues?date=eq." . $today);
// Pastikan $queues adalah array, jika tidak, inisialisasi sebagai array kosong
if (!is_array($queues)) {
    $queues = [];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - HealLine</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f2f5;
            margin: 0;
            padding: 20px; /* Padding di body agar konten tidak terlalu mepet ke tepi */
        }

        .main-content-wrapper {
            max-width: 1200px; /* Lebar maksimum konten */
            margin: 0 auto; /* Ini yang membuat konten rata tengah */
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .header-section h2 {
            margin: 0;
            color: #333;
        }

        .header-section a {
            text-decoration: none;
            color: #007bff;
            font-weight: bold;
        }

        .header-section a:hover {
            text-decoration: underline;
        }

        .message {
            padding: 10px;
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
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); /* Sedikit lebih lebar untuk card */
            gap: 20px;
        }
        .card {
            border: 2px solid #1D70B8;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            background: #f9f9f9;
            transition: 0.3s;
            display: flex; /* Menggunakan flexbox untuk konten card */
            flex-direction: column; /* Konten disusun vertikal */
            justify-content: space-between; /* Untuk mendorong tombol ke bawah jika perlu */
            min-height: 180px; /* Tinggi minimum card */
        }
        .card:hover {
            background: #DCEAFB;
            transform: translateY(-5px); /* Efek sedikit terangkat */
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
        }
        .card h3 {
            margin: 0 0 5px 0;
            color: #1D70B8;
            font-size: 18px; /* Ukuran font lebih besar */
        }
        .card h4 {
            margin: 0 0 15px 0;
            color: #666;
            font-size: 14px; /* Ukuran font lebih besar */
        }
        .card .number {
            font-size: 48px; /* Ukuran angka lebih besar */
            font-weight: bold;
            margin: 10px 0 20px 0;
            color: #333;
            flex-grow: 1; /* Memastikan nomor mengambil ruang sebanyak mungkin */
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card .btn-call {
            background: #1D70B8;
            color: white;
            border: none;
            padding: 12px 25px; /* Padding lebih besar untuk tombol */
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }
        .card .btn-call:hover {
            background: #155a9b;
        }
    </style>
</head>
<body>
    <div class="main-content-wrapper">
        <div class="header-section">
            <h2>Dashboard Antrian Real-time (<?php echo $today; ?>)</h2>
            <a href="login.php">Logout</a>
        </div>

        <?php
        // Tampilkan pesan sukses atau error
        if (isset($_GET['success'])) {
            echo '<p class="message success">' . htmlspecialchars($_GET['success']) . '</p>';
        } elseif (isset($_GET['error'])) {
            echo '<p class="message error">' . htmlspecialchars($_GET['error']) . '</p>';
        }
        ?>

        <div class="grid">
            <?php if (!empty($queues)): ?>
                <?php foreach ($queues as $q): ?>
                    <div class="card" onclick="location.href='?call_next=1&doctor=<?php echo urlencode($q['doctor_name']); ?>'">
                        <h3><?php echo htmlspecialchars($q['poli_name']); ?></h3>
                        <h4>dr. <?php echo htmlspecialchars($q['doctor_name']); ?></h4>
                        <div class="number"><?php echo htmlspecialchars($q['called_number_label'] ?: '-'); ?></div>
                        <button class="btn-call">PANGGIL BERIKUTNYA</button>
                    </div>
                <?php endforeach; ?>
            <?php else: ?>
                <p>Tidak ada antrian aktif saat ini.</p>
            <?php endif; ?>
        </div>
    </div>

    <script>
        // Auto refresh halaman setiap 30 detik untuk melihat update
        setTimeout(function(){ location.reload(); }, 30000);
    </script>
</body>
</html>
