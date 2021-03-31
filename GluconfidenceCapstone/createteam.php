<?php
    
$response = array();

if($_SERVER['REQUEST_METHOD']=='POST'){
    $teamName = $_POST['name'];
    $memberCount = $_POST['member'];
    
    require_once '../includes/DbOpoeration.php';
    
    
    $db = new DbOperation();
    
    if($db->createTeam($teamName, $memberCount)){
        $response['error']=false;
        $response['message']='Team added successfully!';
        
    }else{
        $response['error']=true;
        $response['message']='Could not add team';
        
    }else{
        $response['error']=true;
        $response['message']='You are not authorized';
            
        }
    echo json_encode($response);
}
