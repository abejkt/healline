<?php
// login.php
require 'config.php';

// Pastikan session aktif
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user = $_POST['username'];
    // Hash SHA-256 (lowercase)
    $pass = hash('sha256', $_POST['password']);

    // Kirim sebagai POST JSON, bukan query string
    $payload = json_encode([
        'user_name' => $user,
        'password_hash' => $pass
    ]);
/*
    // Panggil API dengan POST dan body JSON
    $res = callAPI("POST", $base_url . "/user_login", $payload);
*/
    $res = callAPI("POST", $base_url . "/user_login", $payload);

    // contoh debug cepat
    echo "<pre>";
    var_dump($res);
    echo "</pre>";
    exit;

    // Decode jika respon berupa string JSON
    if (is_string($res)) {
        $res = json_decode($res, true);
    }

    // Validasi hasil array
    if (!empty($res) && is_array($res) && count($res) > 0) {
        $_SESSION['admin'] = $res[0];
        header("Location: index.php");
        exit(); // Hentikan eksekusi script setelah redirect
    } else {
        $error = "Username atau Password salah!";
    }
}
?>
<!-- HTML Login Form -->
<form method="POST">
    <h2>Login Admin HealLine</h2>
    <?php if(isset($error)) echo "<p style='color:red'>$error</p>"; ?>
    <input type="text" name="username" placeholder="Username" required><br><br>
    <input type="password" name="password" placeholder="Password" required><br><br>
    <button type="submit">Masuk</button>
</form>
