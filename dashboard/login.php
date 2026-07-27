<?php
// login.php
require 'config.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user = $_POST['username'];
    // Hash SHA-256 (lowercase)
    $pass = hash('sha256', $_POST['password']);

    $params = [
        'user_name' => 'eq.' . $user,
        'password_hash' => 'eq.' . $pass
    ];

    $res = callAPI("GET", $base_url . "/user_login", $params);

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

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HealLine - Smart Queue Management</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f2f5; /* Warna latar belakang abu-abu muda */
            margin: 0;
            display: flex; /* Menggunakan Flexbox untuk centering */
            justify-content: center; /* Centering horizontal */
            align-items: center; /* Centering vertikal */
            min-height: 100vh; /* Memastikan body mengambil tinggi penuh viewport */
        }

        .login-container {
            background-color: #fff;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px; /* Lebar maksimum form */
            text-align: center;
        }

        h2 {
            color: #333;
            margin-bottom: 25px;
            font-size: 24px;
        }

        p.error-message {
            color: red;
            margin-bottom: 20px;
            font-weight: bold;
        }

        input[type="text"],
        input[type="password"] {
            width: calc(100% - 20px); /* Kurangi padding dari lebar total */
            padding: 12px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box; /* Penting agar padding tidak menambah lebar */
            font-size: 16px;
        }

        button[type="submit"] {
            width: 100%;
            padding: 12px;
            background-color: #007bff; /* Warna biru */
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 18px;
            font-weight: bold;
            transition: background-color 0.3s ease;
        }

        button[type="submit"]:hover {
            background-color: #1D70B8; /* Warna biru lebih gelap saat hover */
        }
    </style>
</head>
<body>
    <div class="login-container">
        <form method="POST">
            <h2>HealLine - Smart Queue Management</h2>
            <?php if(isset($error)) echo "<p class='error-message'>$error</p>"; ?>
            <input type="text" name="username" placeholder="Username" required><br>
            <input type="password" name="password" placeholder="Password" required><br>
            <button type="submit">Masuk</button>
        </form>
    </div>
</body>
</html>
