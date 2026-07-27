<?php
// config.php

session_start();

// ============================================================
// Konfigurasi Supabase
// ============================================================
$base_url = "https://34.50.106.220:8443/rest/v1";
$api_key  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc5Mjg5MTExLCJleHAiOjE5MzY5NjkxMTF9.AGU9FqRFP-uPjPqvMSeHTmD22GWLecz_qAa5B6fL1Hg";

$headers = [
    "apikey: "               . $api_key,
    "Authorization: Bearer " . $api_key,
    "Content-Type: application/json",
    "Prefer: return=representation"
];

// ============================================================
// Fungsi callAPI — Mendukung GET, POST, PATCH, DELETE
// ============================================================
function callAPI($method, $url, $data = false) {
    global $headers;

    $curl = curl_init();

    switch ($method) {

        case "GET":
            curl_setopt($curl, CURLOPT_HTTPGET, true);
            break;

        case "POST":
            curl_setopt($curl, CURLOPT_POST, 1);
            if ($data) {
                curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
            }
            break;

        case "PATCH":
            curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "PATCH");
            if ($data) {
                curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
            }
            break;

        case "DELETE":
            curl_setopt($curl, CURLOPT_CUSTOMREQUEST, "DELETE");
            if ($data) {
                curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));
            }
            break;

        default:
            // Log jika method tidak dikenali
            error_log("callAPI: Method tidak dikenali -> " . $method);
            return null;
    }

    curl_setopt($curl, CURLOPT_URL,            $url);
    curl_setopt($curl, CURLOPT_HTTPHEADER,     $headers);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($curl, CURLOPT_TIMEOUT,        10);

    // Hanya untuk development/debugging
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($curl, CURLOPT_SSL_VERIFYHOST, 0);

    $result    = curl_exec($curl);
    $err       = curl_error($curl);
    $http_code = curl_getinfo($curl, CURLINFO_HTTP_CODE);

    curl_close($curl);

    $log = date('c') . " | METHOD: $method | URL: $url | HTTP: $http_code | ERR: $err | RESP: "
         . substr($result, 0, 1000)
         . PHP_EOL;

    file_put_contents(__DIR__ . '/api_debug.log', $log, FILE_APPEND);

    // Handle response kosong (DELETE sukses = HTTP 204, body kosong)
    if (empty($result)) {
        // Kembalikan true jika HTTP sukses (200-299)
        return ($http_code >= 200 && $http_code < 300) ? true : null;
    }

    // Handle HTTP error
    if ($http_code >= 400) {
        error_log("callAPI HTTP Error {$http_code} [{$method}] {$url} : " . $result);
        return null;
    }

    return json_decode($result, true);
}
?>
