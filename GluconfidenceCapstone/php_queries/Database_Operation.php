<?php

class DbOperation
{
	private $conn;

	//Constructor
    	function __construct()
    	{
        	require_once dirname(__FILE__) . '/Env_Vars.php';
        	require_once dirname(__FILE__) . '/Database_Connector.php';
        	// opening db connection
        	$db = new DbConnect();
        	$this->conn = $db->connect();
    	}

	//Function used for user login
	public function userLogin($username, $pass)
	{
		//Getting password from database
		$password_in_db = $this->conn->prepare("SELECT Password FROM UserAccount WHERE Username = ?");
		$password_in_db->bind_param("s", $username);
		$password_in_db->execute();
		$password_in_db->store_result();
		$password_in_db->bind_result($password_from_db);
		$password_in_db->fetch();

		//If the entered password matches with password in database
		if(password_verify($pass, $password_from_db))
		{
       			$stmt = $this->conn->prepare("SELECT UserID FROM UserAccount WHERE Username = ?");
        		$stmt->bind_param("s", $username);
        		$stmt->execute();
        		$stmt->store_result();
        		return $stmt->num_rows > 0;
		}

		else
		{
			return false;
		}
    	}

	public function getUserByUsername($username)
    	{
        	$stmt = $this->conn->prepare("SELECT UserID, Username, Email, FirstName, Weight, Subscription, Current_GC_Bottles FROM UserAccount WHERE Username = ?");
        	$stmt->bind_param("s", $username);
        	$stmt->execute();
        	$stmt->bind_result($id, $uname, $email, $firstname, $weight, $subscription, $current_gc_bottles);
        	$stmt->fetch();
        	$user = array();
        	$user['UserID'] = $id;
        	$user['Username'] = $uname;
        	$user['Email'] = $email;
        	$user['FirstName'] = $firstname;
		$user['Weight'] = $weight;
		$user['Subscription'] = $subscription;
		$user['Current_GC_Bottles'] = $current_gc_bottles;
        	return $user;
    	}

    	//Function to create a new user
    	public function createUser($username, $pass, $email, $firstname, $lastname, $zipcode, $weight, $age, $gender, $years_with_diabetes, $diabetes_type, $on_insulin, $subscription, $current_gc_bottles, $on_oral_med, $daily_injections_num, $avg_daily_insulin, $activity_level, $join_gc_chat_group)
    	{
		//If there is no user in database with this username or email, then create one
        	if (!$this->isUserExist($username, $email)) 
		{
			//hashing password
      			$password = password_hash($pass, PASSWORD_DEFAULT);
            		$stmt = $this->conn->prepare("INSERT INTO UserAccount (Username, Password, Email, FirstName, LastName, Zip_Code, Weight, Age, Gender, Years_With_Diabetes, Diabetes_Type, On_Insulin, Subscription, Current_GC_Bottles, On_Oral_Medication, Daily_Injections, Avg_Daily_Units_of_Insulin, Activity_Level, Join_GC_Chat_Group) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            		$stmt->bind_param("sssssssssssssssssss", $username, $password, $email, $firstname, $lastname, $zipcode, $weight, $age, $gender, $years_with_diabetes, $diabetes_type, $on_insulin, $subscription, $current_gc_bottles, $on_oral_med, $daily_injections_num, $avg_daily_insulin, $activity_level, $join_gc_chat_group);
            		
			if ($stmt->execute()) 
			{
                		return USER_CREATED;
            		} 
		
			else 
			{
                		return USER_NOT_CREATED;
            		}
		} 
	
		else 
		{
            		return USER_ALREADY_EXIST;
        	}
    	}


    	private function isUserExist($username, $email)
    	{
        	$stmt = $this->conn->prepare("SELECT UserID FROM UserAccount WHERE Username = ? OR Email = ?");
        	$stmt->bind_param("ss", $username, $email);
        	$stmt->execute();
        	$stmt->store_result();
        	return $stmt->num_rows > 0;
    	}
    
    public function getCalendarCounts($userid, $month, $year){
        $stmt = $this->conn->prepare("SELECT COUNT(*) AS COUNT, DATE(Low_Start_Time) AS DATE FROM AUC WHERE Usr_ID = ? AND MONTH(Low_Start_Time) = ? AND YEAR(Low_Start_Time) = ? GROUP BY DATE(Low_Start_Time) ORDER BY DATE;");
        $stmt->bind_param("iii", $userid, $month, $year);
        $stmt->execute();
        $result = $stmt->get_result();
        $resultArray = array();
        $tempArray = array();
        while($row = $result->fetch_object()){
            $tempArray = $row;
            array_push($resultArray,$tempArray);
        }
        return $resultArray;

    }
    
    public function getCalendarCountsYear($userid, $year){
        $stmt = $this->conn->prepare("SELECT COUNT(*) AS COUNT, DATE(Low_Start_Time) AS DATE FROM AUC WHERE Usr_ID = ? AND YEAR(Low_Start_Time) = ? GROUP BY DATE(Low_Start_Time) ORDER BY DATE;");
        $stmt->bind_param("ii", $userid, $year);
        $stmt->execute();
        $result = $stmt->get_result();
        $resultArray = array();
        $tempArray = array();
        while($row = $result->fetch_object()){
            $tempArray = $row;
            array_push($resultArray,$tempArray);
        }
        return $resultArray;

    }
    
    public function getToken($userid){
            $stmt = $this->conn->prepare("SELECT Access_Token FROM Tokens WHERE User_ID = ?");
            $stmt->bind_param("i", $userid);
            $stmt->execute();
            $stmt->bind_result($token);
            $stmt->fetch();

            return $token;
    }
    
    public function getPriorLows($userid){
        $stmt = $this->conn->prepare("SELECT Low_Start_Time, GC_or_not_GC FROM AUC WHERE Usr_ID = ? ORDER BY Low_Start_Time DESC LIMIT 3;");
        $stmt->bind_param("i", $userid);
        $stmt->execute();
        $result = $stmt->get_result();
        $resultArray = array();
        $tempArray = array();
        while($row = $result->fetch_object()){
            $tempArray = $row;
            array_push($resultArray,$tempArray);
        }
        return $resultArray;

    }
    
    public function getPointsForLow($userid, $lowTime){
        $stmt = $this->conn->prepare("(SELECT systemTime, value From egvs WHERE UID = ? AND systemTime < ? AND systemTime >= ADDTIME(?, '-0:15:01') LIMIT 3) UNION (SELECT systemTime, value From egvs WHERE UID = ? AND systemTime >= ? AND systemTime <= ADDTIME(?, '0:45:01') LIMIT 10) ORDER BY systemTime;");
        $stmt->bind_param("ississ", $userid, $lowTime, $lowTime, $userid, $lowTime, $lowTime);
        $stmt->execute();
        $result = $stmt->get_result();
        $resultArray = array();
        $tempArray = array();
        while($row = $result->fetch_object()){
            $tempArray = $row;
            array_push($resultArray,$tempArray);
        }
        return $resultArray;

    }
    
    public function getLowsNullGC($userid){
        $stmt = $this->conn->prepare("SELECT Low_Start_Time FROM AUC WHERE Usr_ID = ? AND GC_or_not_GC IS NULL ORDER BY Low_Start_Time;");
        $stmt->bind_param("i", $userid);
        $stmt->execute();
        $result = $stmt->get_result();
        $resultArray = array();
        $tempArray = array();
        while($row = $result->fetch_object()){
            $tempArray = $row;
            array_push($resultArray,$tempArray);
        }
        return $resultArray;

    }
    
    public function updateLowGC($isGC, $userid, $lowTime){
        $stmt = $this->conn->prepare("UPDATE AUC SET GC_or_not_GC = ? WHERE Usr_ID = ? AND Low_Start_Time = ? AND GC_or_not_GC IS NULL;");
        $stmt->bind_param("iis", $isGC, $userid, $lowTime);
        
        if ($stmt->execute())
        {
            return UPDATE_SUCCESS;
        }
    
        else
        {
            return UPDATE_FAILURE;
        }
    }
    
    public function getPersonalInfo($userid){
        $stmt = $this->conn->prepare("SELECT FirstName, Zip_Code, Email, Age, Gender, Weight, Diabetes_Type, Years_With_Diabetes, Oral_Medication_Name, Avg_Daily_Units_of_Insulin, Daily_Injections, Activity_Level, Current_GC_Bottles, Join_GC_Chat_Group FROM UserAccount WHERE UserID = ?;");
        $stmt->bind_param("i", $userid);
        $stmt->execute();
        $stmt->bind_result($firstName, $zipCode, $email, $age, $gender, $weight, $diabetes_type, $year_diabetes, $medName, $avg_insulin, $daily_injections, $activity_level, $current_gc_bottles, $chat_group);
        $stmt->fetch();
        
        $user = array();
        $user['FirstName'] = $firstName;
        $user['ZipCode'] = $zipCode;
        $user['Email'] = $email;
        $user['Age'] = $age;
        $user['Sex'] = $gender;
        $user['Weight'] = $weight;
        $user['Diabetes_Type'] = $diabetes_type;
        $user['Year_Diabetes'] = $year_diabetes;
        $user['Med_Name'] = $medName;
        $user['Avd_Daily_Units_of_Insulin'] = $avg_insulin;
        $user['Daily_Injections'] = $daily_injections;
        $user['Activity_Level'] = $activity_level;
        $user['Current_GC_Bottles'] = $current_gc_bottles;
        $user['Join_GC_Chat_Group'] = $chat_group;
        
        return $user;
    }
    
}

?>
