<?php

include_once __DIR__."/interface/ConnectionDbInterface.php";


class clsConnectToDB implements ConnectionDbInterface{

    private string $_sqlServer = '';
    private string $_port = '';
    private string $_DBname = '';
    private string $_Username = '';
    private string $_Password = '';
    private ?PDO $Connection = null;


    function __construct($SQLserver, $Port, $DBname, $User, $Password)
    {
        $this->_sqlServer = $SQLserver;
        $this->_port = $Port;
        $this->_DBname = $DBname;
        $this->_Username = $User;
        $this->_Password = $Password;
    }
    
    function getPDODB(): PDO{
        return $this->Connection;
    }

    function initConnection(): void
    {
        try{

            $ConfigVariables = "sqlsrv:Server=" . $this->_sqlServer . "," . $this->_port . ";Database=" . $this->_DBname;
            $this->Connection = new PDO($ConfigVariables,$this->_Username, $this->_Password);
            $this->_setAttributesToDB();
            echo('Connection Established');

        } catch(Exception $error) {
            print_r($error);
            echo('Connection not established, something went wrong at initConnection');
        }
    }

    function _setAttributesToDB(){
        $this->Connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    }

    function EchoThings($thing){
        print_r($thing);
    }

}

// $a = new clsConnectToDB("172.17.0.1","14333","gisdb","SA","@Asix13021997");
// $a->initConnection();

?>