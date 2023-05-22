<?php

class clsSecurityController{
    private string $action;
    private array $params;
    private $XMLresponse;

    function __construct(){}

    public function ExecuteAction($action, $params){
        $this->action = $action;
        $this->params = $params;
        
        switch(strtolower($this->action)){
            case 'login':
                $user = new clsUser("172.17.0.1","14333","WS_API_07","SA","@Asix13021997");
                $user->GenerateConnectionToDB();
                // $user->DetectCookieOnClient();
                $user->ExecuteAction('login', $this->params);
                break;
                case 'logout':
                $user = new clsUser("172.17.0.1","14333","WS_API_07","SA","@Asix13021997");
                $user->GenerateConnectionToDB();
                $user->ExecuteAction('logout', $this->params);
                break;
            case 'register':
                $user = new clsUser("172.17.0.1","14333","WS_API_07","SA","@Asix13021997");
                $user->GenerateConnectionToDB();
                $user->ExecuteAction('register', $this->params);
                break;
            }
            
            $this->XMLresponse = $user->GetXMLresponseFromDB();
    }

    public function ObtainXMLResponse(){
        return $this->XMLresponse;
    }

    
}

?>