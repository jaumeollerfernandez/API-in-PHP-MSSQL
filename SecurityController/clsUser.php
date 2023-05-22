<?php

use function PHPSTORM_META\type;

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
    private string $CookieName = 'CID';
    private int $CookieTime = 3600;
    private $XMLresponseFromDB;
    private clsDbController $DBController;
    private stdClass $XMLtoIntroduceInResponseData;

    public function __construct($IP, $port, $DataBase, $DataBaseUser, $DataBasePassword){
        $this->DBController = new clsDbController();
        $this->IP = $IP;
        $this->port = $port;
        $this->DataBase = $DataBase;
        $this->DataBaseUser = $DataBaseUser;
        $this->DataBasePassword = $DataBasePassword;
        $this->GenerateConnectionToDB();
        $this->_DetectCookieOnClient();
    }

    /**
     * Public functions to call
     */

    public function ExecuteAction($action, $params){
        $this->action = strtolower($action);
        $this->params = $params;
        print_r($this->params);
        $this->_ExecuteUserAction($action);
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

    protected function _DetectCookieOnClient(){
        if(isset($_COOKIE[$this->CookieName])){
            $this->cid = $_COOKIE[$this->CookieName];
            $this->HasCookie = true;
        }else{
            $this->HasCookie = false;
        }
    }

    /**
     * Private functions
     */

    protected function _ExecuteUserAction($action){

        $this->_ExecuteActionIntoDB($action);

        $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');
        $ManagedStdClass = $this->_ManageResponseFromDB($this->XMLresponseFromDB[0]);
        $this->XMLtoIntroduceInResponseData = $this->XMLresponseFromDB[0];

        $this->_ExecuteActionIntoUserClient($action, $ManagedStdClass);
        
        $this->_RenderXML($this->XMLresponseFromDB);
    }

    protected function _SetCookieToClient($stdClass){
        $xml = simplexml_load_string($stdClass);
        setcookie($this->CookieName,  $xml->sp_sap_conn_create->conn_guid, time() + $this->CookieTime);
    }

    protected function _UnSetCookieToClient(){
            setcookie($this->CookieName, "", time()-3600);    
    }

    protected function _ManageResponseFromDB($stdClass){
        $stdClassObject = $stdClass;
        $properties = get_object_vars($stdClassObject);
        $firstProperty = reset($properties);
        return $firstProperty;

    }


    protected function _ExecuteActionIntoDB($action){
        $PreparedParams = $this->_PrepareParams($action);
        switch(strtolower($action)){
            case 'login':
                $this->DBController->ExecuteProcedure("sp_sap_user_login", $PreparedParams);
                break;
            case 'logout':
                $this->DBController->ExecuteProcedure("sp_sap_user_logout", $PreparedParams);
                break;
            case 'register':
                $this->DBController->ExecuteProcedure("sp_sap_user_register", $PreparedParams);
                break;
        }
    }

    protected function _ExecuteActionIntoUserClient($action, $stdClass){
        switch($action){
            case 'login':
                $this->_SetCookieToClient($stdClass);
                break;
            case 'logout':
                if($this->HasCookie){
                    $this->_UnSetCookieToClient();
                }
                break;
            case 'register':
                break;
        }
    }
    
    protected function LogIn(){
            $PreparedParams = $this->_PrepareParams('Login');
            $this->DBController->ExecuteProcedure("sp_sap_user_login", $PreparedParams);
            $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');
            $ManagedStdClass = $this->_ManageResponseFromDB($this->XMLresponseFromDB[0]);
            $this->_SetCookieToClient($ManagedStdClass);
            $this->XMLtoIntroduceInResponseData = $this->XMLresponseFromDB[0];
            // setcookie("CID", $xml->sp_sap_conn_create->conn_guid, time()+3600);
            $this->_RenderXML($this->XMLresponseFromDB);
    }

    protected function LogOut(){
        if ($this->HasCookie == true) {
            $this->cid = $_COOKIE['CID'];
            $PreparedParams = $this->_PrepareParams('Logout');
            $this->DBController->ExecuteProcedure("sp_sap_user_logout", $PreparedParams);
            $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');
            $ManagedStdClass = $this->_ManageResponseFromDB($this->XMLresponseFromDB[0]);
            $xml = simplexml_load_string($ManagedStdClass);
            $this->XMLtoIntroduceInResponseData = $this->XMLresponseFromDB[0];
           
            $this->_RenderXML($this->XMLresponseFromDB);
        }else{
            $this->_RenderXMLErrorLogout();
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
            case 'login':
                array_push($PreparedArray, $this->params['user']);
                array_push($PreparedArray, $this->params['pwd']);
                return $PreparedArray;
                break;
            case 'register':
                array_push($PreparedArray, $this->params['user_id']);
                array_push($PreparedArray, $this->params['pwd']);
                array_push($PreparedArray, $this->params['user']);
                return $PreparedArray;
                break;
            case 'logout':
                array_push($PreparedArray, $this->params['cid']);
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
    protected function _RenderXMLErrorLogout(){
        $this->_SetXMLheader();
        $obj_xml = new SimpleXMLElement('<WSresponse>Debe proporcionar su CID para ello. Contacte con su administrador.</WSresponse>');
        ob_clean();
        echo $obj_xml->asXML();

    }

    
}

?>