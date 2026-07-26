<?php
// login.php
require 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user = $_POST['username'];
    $pass = $_POST['password']);

    $url = $base_url . "/user_login?user_name=eq." . $user . "&password_hash=eq." . $pass;
    $res = callAPI("GET", $url);

    if (!empty($res)) {
        $_SESSION['admin'] = $res[0];
        header("Location: dashboard.php");
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
