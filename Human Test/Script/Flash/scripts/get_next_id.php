<?php

$user="gamesql";
$password="gamesql4";
$database="games";
mysql_connect("localhost",$user,$password);
@mysql_select_db($database) or die( "Unable to select database");

$query1 = "INSERT INTO id_increment (id_val) VALUES ('')";
mysql_query($query1);

$query2= "SELECT MAX(id_val) AS id FROM id_increment";
$q2result = mysql_query($query2);
$q2row = mysql_fetch_row($q2result);
$id = $q2row[0];

mysql_close();

echo "&id=" . $id;

?>