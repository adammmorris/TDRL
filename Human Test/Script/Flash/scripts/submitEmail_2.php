<?
$id = $_POST[id];
$address = $_POST[address];

//send to database
$user="gamesql";
$password="gamesql4";
$database="games";
mysql_connect("localhost",$user,$password);
@mysql_select_db($database) or die( "Unable to select database");

$query= "UPDATE subjects1 SET email='$address' WHERE id='$id'";
mysql_query($query);
mysql_close();

$return="Successful submission";
echo "&$return";
?> 