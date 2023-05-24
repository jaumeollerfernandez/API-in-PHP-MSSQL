<?php

class clsSecurityController{
    private string $action;
    private array $params;
    private $XMLresponse;

    function __construct(){}

    /**
     * Public Functions
     */

    public function ExecuteAction($action, $params){
        $this->action = $action;
        $this->params = $params;
        
        switch(strtolower($this->action)){
            case 'login':
                $this->_TryLogin();
                break;
                case 'logout':
                $this->_TryLogout();
                break;
            case 'register':
                $this->_TryRegister();
                break;
            }
            
        }
    public function ObtainXMLResponse(){
        return $this->XMLresponse;
    }

    /**
     * Private Functions
     */

    protected function _TryLogin(){
        $user = new clsUser("172.17.0.1","14333","WS_API_07","SA","@Asix13021997");
        $user->GenerateConnectionToDB();
        $user->ExecuteAction('login', $this->params);
        $this->XMLresponse = $user->GetXMLresponseFromDB();
    }
    protected function _TryLogout(){
        $user = new clsUser("172.17.0.1","14333","WS_API_07","SA","@Asix13021997");
        $user->GenerateConnectionToDB();
        $user->ExecuteAction('logout', $this->params);
        $this->XMLresponse = $user->GetXMLresponseFromDB();
    }
    protected function _TryRegister(){
        $user = new clsUser("172.17.0.1","14333","WS_API_07","SA","@Asix13021997");
        $user->GenerateConnectionToDB();
        $user->ExecuteAction('register', $this->params);
        $this->XMLresponse = $user->GetXMLresponseFromDB();
    }

    
}

?>