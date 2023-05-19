<?php

include_once __DIR__."/../DB_Controller/clsDbController.php";

class clsUser{
    private string $IP;
    private string $port;
    private string $DataBase;
    private string $DataBaseUser;
    private string $DataBasePassword;
    private string $action;
    private array $params;
    private string $cid;
    private bool $HasCookie;
    private $XMLresponseFromDB;
    private clsDbController $DBController;

    public function __construct($IP, $port, $DataBase, $DataBaseUser, $DataBasePassword){
        $this->DBController = new clsDbController();
        $this->IP = $IP;
        $this->port = $port;
        $this->DataBase = $DataBase;
        $this->DataBaseUser = $DataBaseUser;
        $this->DataBasePassword = $DataBasePassword;
        $this->GenerateConnectionToDB();
        $this->DetectCookieOnClient();
    }

    public function ExecuteAction($action, $params){
        $this->action = $action;
        $this->params = $params;
        print_r($this->params);
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

    public function GenerateConnectionToDB(){
        $this->DBController->AddConnectionToDB($this->IP, $this->port, $this->DataBase, $this->DataBaseUser, $this->DataBasePassword);
    }

    public function GetXMLresponseFromDB(){
        return $this->XMLresponseFromDB;
    }

    public function DetectCookieOnClient(){
        if(isset($_COOKIE['CID'])){
            $this->cid = $_COOKIE['CID'];
            $this->HasCookie = true;
        }else{
            $this->HasCookie = false;
        }
    }

    protected function SetCookieToClient(){
        setcookie('cid', $this->cid, time() + 3600);
    }

    protected function _ManageResponseFromDB($stdClass){
        $stdClassObject = $stdClass;
        $properties = get_object_vars($stdClassObject);
        $firstProperty = reset($properties);
        return $firstProperty;

    }
    
    protected function LogIn(){
        if($this->HasCookie == false){
            $PreparedParams = $this->_PrepareParams('Login');
            $this->DBController->ExecuteProcedure("sp_sap_user_login", $PreparedParams);
            $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');
            var_dump($this->XMLresponseFromDB);
            // $ManagedStdClass = $this->_ManageResponseFromDB($this->XMLresponseFromDB[0]);
            // $xml = simplexml_load_string($ManagedStdClass);
            // setcookie("CID", $xml->sp_sap_conn_create->conn_guid, time()+3600);
            // $this->_RenderXML($this->XMLresponseFromDB);
        }else{
            $this->_RenderXMLError();
        }
    }

    protected function LogOut(){
        if($this->HasCookie == false){
            $this->_RenderXMLError();
        }else{
            echo($this->HasCookie);
        }

    }

    protected function Register(){
        $PreparedParams = $this->_PrepareParams('Register');
        $this->DBController->ExecuteProcedure("sp_sap_user_register", $PreparedParams);
        $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');
        $this->_RenderXML($this->XMLresponseFromDB);

    }

    protected function _PrepareParams($Mode){
        $PreparedArray = [];
        switch($Mode){
            case 'Login':
                array_push($PreparedArray, $this->params['user']);
                array_push($PreparedArray, $this->params['pwd']);
                return $PreparedArray;
                break;
            case 'Register':
                array_push($PreparedArray, $this->params['user_id']);
                array_push($PreparedArray, $this->params['user']);
                array_push($PreparedArray, $this->params['pwd']);
                return $PreparedArray;
                break;
            case 'Logout':
                array_push($PreparedArray, $this->params[0]);
                return $PreparedArray;
                break;
        }
    }

    
    protected function _SetXMLheader(): void{
        header('Content-type: text/xml');
    }

    protected function _RenderXML($result): void{
        $this->_SetXMLheader();
        foreach($result[0] as $xml){
            $obj_xml = simplexml_load_string($xml);
        }

        if($obj_xml == []){
            $obj_xml = new SimpleXMLElement('<WSresponse>No hay respuesta por parte del servidor</WSresponse>');
        }

        ob_clean();
        echo $obj_xml->asXML();
    }

    protected function _RenderXMLError(){
        $this->_SetXMLheader();
        $obj_xml = new SimpleXMLElement('<WSresponse>Acción no realizada, error en la petición</WSresponse>');
        ob_clean();
        echo $obj_xml->asXML();

    }

    
}

?>