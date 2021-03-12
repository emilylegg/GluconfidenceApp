<?php
    
class DbOperation
{
    private $conn;
    
    function _connect()
    {
        require_once dirname(_FILE_) . '/Config.php';
        require_once dirname(_FILE_) . '/DbConnect.php';
        
        $db = new DbConnect();
        $this->conn = $db->connect();
    }
    
    public function createTeam($name, $memberCount)
    {
        $stmt = $this->conn->prepare("INSERT INTO team(name, member) values(?, ?)");
        $stmt->bind_param("si", $name, $memberCount);
        $result = $stmt->execute();
        $stmt->close();
        if ($result) {
           return true;
        } else {
            return false;
        }
    }
}
