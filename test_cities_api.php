<?php

$ch = curl_init('http://localhost:8000/api/cities');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

$data = json_decode($response, true);
print_r(array_slice($data['data'] ?? $data, 0, 3));
