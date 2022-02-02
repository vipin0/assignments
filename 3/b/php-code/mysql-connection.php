<?php
$servername = getenv('DB_SERVER');
$database = getenv('DB_NAME');
$username = getenv('DB_USER');
$password = file_get_contents(getenv('DB_PASSWORD_FILE'));
// Create connection
$conn = @mysqli_connect($servername, $username, $password, $database);
// Check connection
if (!$conn) {
  die("Connection failed: " . mysqli_connect_error());
}else{
  echo "Connected successfully";
}
?>