<?php
 
//importing required script
require_once 'Database_Operation.php';

$resultArray = array();

if($_SERVER['REQUEST_METHOD']=='POST'){
    if(isset($_POST['UserID']) && isset($_POST['Year'])){
        //getting values for the query
        $userid = (int) $_POST['UserID'];
        $year = (int) $_POST['Year'];

        $db = new DbOperation();
        $resultArray = $db->getCalendarCountsYear($userid, $year);

    }
}

echo json_encode($resultArray);

?>
