<?php
 
//importing required script
require_once 'Database_Operation.php';

$resultArray = array();

if($_SERVER['REQUEST_METHOD']=='POST'){
    if(isset($_POST['UserID']) && isset($_POST['LowTime'])){
        //getting values for the query
        $userid = (int) $_POST['UserID'];
        $lowTime = $_POST['LowTime'];

        $db = new DbOperation();
        $resultArray = $db->getPointsForLow($userid, $lowTime);

    }
}

echo json_encode($resultArray);

?>
