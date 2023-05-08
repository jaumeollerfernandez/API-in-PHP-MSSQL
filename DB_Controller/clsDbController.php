<?php

include_once __DIR__."/../DB_utils/clsConnectToDB.php";
include_once __DIR__."/../DB_utils/clsExecuteProceduresToDB.php";

class clsDbController{
    private clsConnectToDB $DBconnection;
    private clsExecuteProceduresToDB $ProcedureExecute;

    function __construct(){}

    function AddMSSQLConnectionToDB($sql, $port, $DBname, $user, $pwd){
        $this->DBconnection = new clsConnectToDB($sql, $port, $DBname, $user, $pwd);
        $this->DBconnection->initConnection();
        $this->ProcedureExecute = new clsExecuteProceduresToDB($this->DBconnection->getPDODB());
    }
    function ExecuteProcedure($procedure, $params){
        $this->ProcedureExecute->CallProcedure($procedure, $params);
    }
}

?>