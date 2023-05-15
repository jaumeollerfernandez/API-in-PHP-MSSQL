<?php

class clsUser{
    private string $action;
    private string $username;
    private string $password;
    private string $cid;
    private bool $HasCookie;
    private $XMLresponseFromDB;
    private clsDbController $DBController;

    public function __construct($action, $username, $password){
        $this->action = $action;
        $this->username = $username;
        $this->password = $password;
        $this->DBController = new clsDbController();
        $this->GenerateConnectionToDB();
        $this->DetectCookieOnClient();
    }

    public function ExecuteAction(){
        switch($this->action){
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
            $this->DBController->ExecuteProcedure("sp_sap_user_log", [$this->username, $this->password]);
            $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');
            var_dump($this->XMLresponseFromDB);
        }
    }

    protected function LogOut(){

    }

    protected function Register(){

    }

    
    function _SetXMLheader(): void{
        header('Content-type: text/xml');
    }

    protected function _RenderXML($result): void{
        $this->_SetXMLheader();
        foreach($result[0] as $xml){
            $obj_xml = simplexml_load_string($xml);
        }
        ob_clean();
        echo $obj_xml->asXML();
    }

    
}

?>