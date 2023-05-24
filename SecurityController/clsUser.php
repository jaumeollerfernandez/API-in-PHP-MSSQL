<?php

include_once __DIR__."/../DB_Controller/clsDbController.php";

class clsUser{
    
    private string $action;
    private array $params;
    private $XMLresponseFromDB;
    private clsDbController $DBController;

    public function __construct(){
        $this->DBController = new clsDbController();
    }

    /**
     * Public functions to call
     */

    public function ExecuteAction($action, $params){
        $this->action = strtolower($action);
        $this->params = $params;
        $this->DBController->_ExecuteActionIntoDB($this->action, $this->params);
        $this->XMLresponseFromDB = $this->DBController->ObtainResult('OBJECT');
    }

    public function GetXMLresponseFromDB(){
        return $this->XMLresponseFromDB;
    }

    
    /**
     * Private functions
     */


    
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