<?php
 
// Create connection
$con=mysqli_connect("dev-database.c5tmc9rlx4ju.us-east-1.rds.amazonaws.com","admin","GLUconfidence421#!","Dexcom API Info");
 
// Check connection
if (mysqli_connect_errno())
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
 
    //getting values
$u_id = (int) $_POST['UserID'];
$begin_time = $_POST['beginTime'];
$end_time = $_POST['endTime'];

// This SQL statement
$sql = "SELECT systemTime, value FROM egvs WHERE UID = $u_id AND systemTime BETWEEN '$begin_time' AND '$end_time' order by systemTime;";
// $sql = "SELECT systemTime, value FROM egvs WHERE UID = 1 AND systemTime BETWEEN '$begin_time' AND '2021-04-07 23:59:00' order by systemTime;";
    
// Check if there are results
if ($result = mysqli_query($con, $sql))
{
    // If so, then create a results array and a temporary one
    // to hold the data
    $resultArray = array();
    $tempArray = array();
 
    // Loop through each row in the result set
    while($row = $result->fetch_object())
    {
        // Add each row into our results array
        $tempArray = $row;
        array_push($resultArray, $tempArray);
    }
 
    // Finally, encode the array to JSON and output the results
    echo json_encode($resultArray);
}
 
// Close connections
mysqli_close($con);
?>
