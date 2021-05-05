<?php
 
//importing required script
require_once 'Database_Operation.php';

$resultArray = array();

if($_SERVER['REQUEST_METHOD']=='POST'){
    if(isset($_POST['UserID'])){
        //getting values for the query
        $userid = (int) $_POST['UserID'];

        $db = new DbOperation();
        $resultArray = $db->getLowsNullGC($userid);
    }
}

echo json_encode($resultArray);

?>
