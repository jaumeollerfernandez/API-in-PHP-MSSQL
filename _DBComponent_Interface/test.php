<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");


include_once __DIR__."/config.php";
include_once __DIR__."/interface/ConnectionDbInterface.php";
include_once __DIR__."/interface/ControllerDataBaseInterface.php";

include_once __DIR__."/com/clsDatabaseConnection.php";
include_once __DIR__."/com/clsDatabaseController.php";



class DbConnection implements ConnectionDbInterface {


    function __construct()
    {
        
    }

    public function getPDODB(): PDO {
        return new PDO("DS");
    }


    public function initConnection(): void  {

    }

}


?>