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

    public function _ExecuteActionIntoDB($Mode, $params){
        $PreparedArray = [];
        switch($Mode){
            case 'login':
                array_push($PreparedArray, $params['user']);
                array_push($PreparedArray, $params['pwd']);
                $this->ExecuteProcedure("sp_sap_user_login", $PreparedArray);
                return $PreparedArray;
                break;
            case 'register':
                array_push($PreparedArray, $params['user_id']);
                array_push($PreparedArray, $params['pwd']);
                array_push($PreparedArray, $params['user']);
                $this->ExecuteProcedure("sp_sap_user_register", $PreparedArray);
                return $PreparedArray;
                break;
            case 'logout':
                array_push($PreparedArray, $params['cid']);
                $this->ExecuteProcedure("sp_sap_user_logout", $PreparedArray);
                return $PreparedArray;
                break;
        }
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
                $result = $this->_ManageResponseFromDB($this->XMLresponse[0]);
                return $result;
                break;
            default:
                echo('Must use XML, None, in _ObtainResult, no cases found. ');

        }
    }

    protected function _ManageResponseFromDB($stdClass){
        $stdClassObject = $stdClass;
        $properties = get_object_vars($stdClassObject);
        $firstProperty = reset($properties);
        return $firstProperty;
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