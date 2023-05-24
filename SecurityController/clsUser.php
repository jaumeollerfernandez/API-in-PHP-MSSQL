<?php

include_once __DIR__."/../DB_Controller/clsDbController.php";

class clsUser{
    
    private string $action;
    private array $params;
    private string $cid;
    private bool $HasCookie;
    private string $CookieName = 'CID';
    private int $CookieTime = 3600;
    private $XMLresponseFromDB;
    private clsDbController $DBController;

    public function __construct(){
        $this->DBController = new clsDbController();
        $this->_DetectCookieOnClient();
    }

    /**
     * Public functions to call
     */

    public function ExecuteAction($action, $params){
        $this->action = strtolower($action);
        $this->params = $params;
        $this->_InteractionWithDBcontroller($action);
    }

    public function GetXMLresponseFromDB(){
        return $this->XMLresponseFromDB;
    }

    
    /**
     * Private functions
     */

     /**
      * MOVE TO CLS SESSION
      */

    protected function _DetectCookieOnClient(){
        if(isset($_COOKIE[$this->CookieName])){
            $this->cid = $_COOKIE[$this->CookieName];
            $this->HasCookie = true;
        }else{
            $this->HasCookie = false;
        }
    }
    
    protected function _InteractionWithDBcontroller($action){

        $this->_ExecuteActionIntoDB($action);

        $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');

        $this->_ExecuteActionIntoUserClient($action, $this->XMLresponseFromDB);
    }

     /**
      * MOVE TO CLS SESSION
      */

    protected function _SetCookieToClient($stdClass){
        $xml = simplexml_load_string($stdClass);
        setcookie($this->CookieName,  $xml->conn_guid, time() + $this->CookieTime);
    }

    /**
    * MOVE TO CLS SESSION
    */

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