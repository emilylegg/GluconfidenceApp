<?php
 
//importing required script
require_once 'Database_Operation.php';

$response = array();

if($_SERVER['REQUEST_METHOD']=='POST'){
    if(isset($_POST['UserID']) && isset($_POST['IsGC']) && isset($_POST['LowTime'])){
        //getting values for the query
        $isGC = (int) $_POST['IsGC'];
        $userid = (int) $_POST['UserID'];
        $lowTime = $_POST['LowTime'];

        $db = new DbOperation();
        $result = $db->updateLowGC($isGC, $userid, $lowTime);
        
        if ($result == UPDATE_SUCCESS){
            $response['error'] = false;
            $response['message'] = 'Update Successfully';
        }else{
            $response['error'] = true;
            $response['message'] = 'Update Errored';
        }

    }else{
        $response['error'] = true;
        $response['message'] =  'Missing Parameters';
    }
}

echo json_encode($response);

?>
