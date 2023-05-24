<?php

include_once __DIR__."/clsSession.php";

class clsSecurityController{
    private string $action;
    private array $params;
    private $XMLresponseString;
    private $XMLresponseObject;

    public function __construct(){
        
    }

    /**
     * Public Functions
     */

    public function ExecuteAction($action, $params){
        $this->action = $action;
        $this->params = $params;
        
        switch(strtolower($this->action)){
            case 'login':
                $this->_TryLogin();
                if($this->_ValidateReturn()){
                    $session = new clsSession();
                    $session->SetCID($this->XMLresponseObject->conn_guid);
                    $session->SetCookie();
                }
                break;

                case 'logout':
                $this->_TryLogout();
                if($this->_ValidateReturn()){
                    $session = new clsSession();
                    $session->UnsetCookie();
                }
                break;
                
            case 'register':
                $this->_TryRegister();
                break;
            }
        }

    public function ObtainXMLResponse(){
        return $this->XMLresponseString;
    }

    /**
     * Private Functions
     */

    protected function _TryLogin(){
        $user = new clsUser();
        $user->ExecuteAction('login', $this->params);
        $this->XMLresponseString = $user->GetXMLresponseFromDB();
        $this->XMLresponseObject = simplexml_load_string($this->XMLresponseString);

    }
    protected function _TryLogout(){
        $user = new clsUser();
        $user->ExecuteAction('logout', $this->params);
        $this->XMLresponseString = $user->GetXMLresponseFromDB();
        $this->XMLresponseObject = simplexml_load_string($this->XMLresponseString);
    }
    protected function _TryRegister(){
        $user = new clsUser();
        $user->ExecuteAction('register', $this->params);
        $this->XMLresponseString = $user->GetXMLresponseFromDB();
        $this->XMLresponseObject = simplexml_load_string($this->XMLresponseString);
    }

    protected function _ValidateReturn(){
        /**
         * Return que será de segunda respuesta. Ahora de momento es en XML. Deberá refactorizarse en que pille la segunda respuesta de retorno.
         */
        if($this->XMLresponseObject->ret == 0){
            return true;
        }else{
            return false;
        }
    }
    
}

?>