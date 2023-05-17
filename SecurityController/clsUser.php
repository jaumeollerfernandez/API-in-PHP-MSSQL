<?php

include_once __DIR__."/../DB_Controller/clsDbController.php";

class clsUser{
    private string $action;
    private array $params;
    private string $cid;
    private bool $HasCookie;
    private $XMLresponseFromDB;
    private clsDbController $DBController;

    public function __construct($action, $params){
        $this->action = $action;
        $this->params = $params;
        $this->DBController = new clsDbController();
        $this->GenerateConnectionToDB();
        $this->DetectCookieOnClient();
    }

    public function ExecuteAction(){
        switch(strtolower($this->action)){
            case 'login':
                $this->LogIn();
                break;
            case 'logout':
                $this->LogOut();
                break;
            case 'register':
                $this->Register();
                break;
        }
    }

    public function SendResponse(){
        return $this->XMLresponseFromDB;
    }

    protected function GenerateConnectionToDB(){
        $this->DBController->AddConnectionToDB("172.17.0.1","14333","WS_API_07","SA","@Asix13021997");
    }

    protected function DetectCookieOnClient(){
        if(isset($_COOKIE['cid'])){
            $this->cid = $_COOKIE['cid'];
            $this->HasCookie = true;
        }else{
            $this->HasCookie = false;
        }
    }

    protected function SetCookieToClient(){
        setcookie('cid', $this->cid, time() + 3600);
    }
    
    protected function LogIn(){
        if($this->HasCookie == false){
            $PreparedParams = $this->_PrepareParams('Login');
            $this->DBController->ExecuteProcedure("sp_sap_user_login", $PreparedParams);
            $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');
            $this->_RenderXML($this->XMLresponseFromDB);
        }
    }

    protected function LogOut(){

    }

    protected function Register(){

    }

    protected function _PrepareParams($Mode){
        $PreparedArray = [];
        switch($Mode){
            case 'Login':
                array_push($PreparedArray, $this->params[0]);
                array_push($PreparedArray, $this->params[1]);
                return $PreparedArray;
                break;
            case 'Register':
                array_push($PreparedArray, $this->params[0]);
                array_push($PreparedArray, $this->params[1]);
                array_push($PreparedArray, $this->params[2]);
                return $PreparedArray;
                break;
            case 'Logout':
                array_push($PreparedArray, $this->params[0]);
                return $PreparedArray;
                break;
        }
    }

    
    function _SetXMLheader(): void{
        header('Content-type: text/xml');
    }

    protected function _RenderXML($result): void{
        $this->_SetXMLheader();
        foreach($result[0] as $xml){
            $obj_xml = simplexml_load_string($xml);
        }

        if($obj_xml == []){
            $obj_xml = new SimpleXMLElement('<WSresponse>Acción realizada, no respuesta por parte de Procedure</WSresponse>');
        }

        ob_clean();
        echo $obj_xml->asXML();
        ob_clean();
        echo $obj_xml->asXML();
    }

    
}

?>