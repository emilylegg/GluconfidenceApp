<?php
 
//importing required script
require_once 'Database_Operation.php';

$resultArray = array();

if($_SERVER['REQUEST_METHOD']=='POST'){
    if(isset($_POST['UserID']) && isset($_POST['Month']) && isset($_POST['Year'])){
        //getting values for the query
        $userid = (int) $_POST['UserID'];
        $month = (int) $_POST['Month'];
        $year = (int) $_POST['Year'];

        $db = new DbOperation();
        $resultArray = $db->getCalendarCounts($userid, $month, $year);

    }
}

echo json_encode($resultArray);

?>
