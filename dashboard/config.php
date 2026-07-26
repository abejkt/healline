<?php
// config.php
session_start();

$base_url = "https://34.50.106.220:8443/rest/v1";
$api_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc5Mjg5MTExLCJleHAiOjE5MzY5NjkxMTF9.AGU9FqRFP-uPjPqvMSeHTmD22GWLecz_qAa5B6fL1Hg";

$headers = [
    "apikey: " . $api_key,
    "Authorization: Bearer " . $api_key,
    "Content-Type: application/json",
    "Prefer: return=representation"
];

function callAPI($method, $url, $data = false) {
    global $headers;
    $curl = curl_init();

    switch ($method) {
        case "POST":
            curl_setopt($curl, CURLOPT_POST, 1);
            if ($data) curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
            break;
        case "PATCH":
            curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PATCH");
            if ($data) curl_setopt($curl, CURLOPT_POSTFIELDS, $data);
            break;
        default:
            if ($data) $url = sprintf("%s?%s", $url, http_build_query($data));
    }

    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);

    // Untuk development/debugging: nonaktifkan verifikasi SSL peer dan hostname
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 0);

    $result = curl_exec($curl);
    $err = curl_error($curl);
    $http_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    curl_close($curl);

    // (Opsional) log untuk debugging
    $log = date('c') . " | URL: $url | HTTP: $http_code | ERR: $err | RESP: " . substr($result, 0, 1000) . PHP_EOL;
    file_put_contents(__DIR__ . '/api_debug.log', $log, FILE_APPEND);

    return json_decode($result, true);
}
?>
