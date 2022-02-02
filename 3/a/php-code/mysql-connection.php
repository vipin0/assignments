<?php
$servername = getenv('DB_SERVER');
$database = getenv('DB_NAME');
// $username = getenv('DB_USER');
$username = file_get_contents(getenv('DB_USER_FILE'));
$password = file_get_contents(getenv('DB_PASSWORD_FILE'));
// Create connection
// echo $servername;
// echo $database;
// echo $username;
// echo $password;
$conn = @mysqli_connect($servername, $username, $password,$database);
// Check connection
if (!$conn) {
  die("Connection failed: " . mysqli_connect_error());
}else{
  echo "Connected successfully";
}
?>