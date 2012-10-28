<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"> 
<html>
<head>
<title>HW5</title>
<link rel= "stylesheet" type = "text/css" href="stylesheet.css"/>

<?php
$firstName =  $_POST["fname"]; 
if (!preg_match("/^[a-zA-Z]$/", $firstName)) {
    echo "enter a valid name";
}

$lastName =  $_POST["lname"]; 
if (!preg_match("/^[a-zA-Z]$/", $lastName)) {
   echo "enter a valid name";
}

$blazerId =   $_POST["bname"]; 


$telephoneNum =  $_POST["telNum"]; 
if (!preg_match("/^[0-9]$/", $param)) {
   echo "enter valid Phone Number";
}

$teamNum =   $_POST["teamNum"]; 
if (!preg_match("/^[1-6]$/", $param)) {
   echo "enter a valid team Number";
}

$Analysis = $_POST["Analysis"]; 
$Design =$_POST["Design"]; 
$Coding=$_POST["Coding"]; 
$Others=$_POST["Others"]; 
?>
</head>
<body>
<?php
echo "<p> First Name </p>";
echo "<p>" .$firstName. "</p>";

echo "<p> Last Name </p>";
echo "<p>" .$lastName. "</p>";

echo "<p> Blazer Id </p>";
echo "<p>" .$blazerId. "</p>";

echo "<p> Telephone </p>";
echo "<p>" .$telephoneNum. "</p>";

echo "<p> Team Number </p>";
echo "<p>" .$teamNum. "</p>";
?>
</body>
</html>