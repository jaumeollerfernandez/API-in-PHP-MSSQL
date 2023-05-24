<?php

include_once __DIR__."/../DB_utils/clsConnectToDB.php";
include_once __DIR__."/../DB_utils/clsExecuteProceduresToDB.php";

class clsDbController{
    private string $IP = "172.17.0.1";
    private string $port = "14333";
    private string $DataBase = "WS_API_07";
    private string $DataBaseUser = "SA";
    private string $DataBasePassword = "@Asix13021997";
    private clsConnectToDB $DBconnection;
    private clsExecuteProceduresToDB $ProcedureExecute;
    private Array $XMLresponse;

    function __construct(){
        $this->AddConnectionToDB($this->IP, $this->port, $this->DataBase, $this->DataBaseUser, $this->DataBasePassword);
    }

    function AddConnectionToDB(string $sql, string $port, string $DBname, string $user, string $pwd){
        $this->DBconnection = new clsConnectToDB($sql, $port, $DBname, $user, $pwd);
        $this->DBconnection->initConnection();
        $this->ProcedureExecute = new clsExecuteProceduresToDB($this->DBconnection->getPDODB());
    }

    function ExecuteProcedure($procedure, $params){
        $this->ProcedureExecute->CallProcedure($procedure, $params);
        $this->SetResponseFromProcedureToXMLresponse();
    }

    function SetResponseFromProcedureToXMLresponse(){
        $this->XMLresponse = $this->ProcedureExecute->getResult();
    }

    function ObtainResult($RenderMode){
        switch($RenderMode){
            case 'XML':
                $this->_RenderXML($this->XMLresponse);
                break;
            case 'HTML':
                $this->_RenderHTML($this->XMLresponse);
                //To Do: Think other methods to add.
                break;
            case 'OBJECT':
                // $this->_RenderOBJECT($this->XMLresponse);
                return $this->XMLresponse;
                break;
            default:
                echo('Must use XML, None, in _ObtainResult, no cases found. ');

        }
    }

    function _SetXMLheader(): void{
        header('Content-type: text/xml');
    }
    
    function _RenderXML($result): void{
        $this->_SetXMLheader();
        foreach($result[0] as $xml){
            $obj_xml = simplexml_load_string($xml);
        }

        if($obj_xml == []){
            $obj_xml = new SimpleXMLElement('<WSresponse>Acción realizada</WSresponse>');
        }

        ob_clean();
        echo $obj_xml->asXML();

    }

    function _RenderHTML($result){
        foreach($result[0] as $xml){
            $obj_xml = simplexml_load_string($xml);
        }
        ob_clean();
        echo $obj_xml->asXML();
    }

    function _RenderOBJECT($result){
        foreach($result[0] as $xml){
            $obj_xml = simplexml_load_string($xml);
        }
        return $obj_xml;
    }
}

?>