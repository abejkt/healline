<?php
// config.php
session_start();

$base_url = "https://34.50.106.220:8443/rest/v1";
$api_key = "PASTE_YOUR_JWT_TOKEN_HERE"; // Ambil dari api_config.dart

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
    curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false); // Bypass cert dev

    $result = curl_exec($curl);
    curl_close($curl);
    return json_decode($result, true);
}
?>