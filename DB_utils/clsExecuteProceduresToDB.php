<?php

include_once __DIR__."/interface/ControllerDataBaseInterface.php";

class clsExecuteProceduresToDB implements ControllerDataBaseInterface{

    private PDO $DBconnection;
    private string $ProcedureName;
    private PDOStatement $PreparedProcedure;
    private Array $result;

    function __construct(PDO $PDOconnection)
    {
        $this->DBconnection = $PDOconnection;
    }

    function prepareProcedure(string $name_procedure, array $params = []): void
    {
        $this->ProcedureName = $name_procedure;
        $this->PreparedProcedure = $this->DBconnection->prepare($this->ProcedureName);
    }

    function BindParamToProcedure($MatrixOfParams){
        for($i = 0; $i < count($MatrixOfParams); $i++){
            $this->PreparedProcedure->bindParam($MatrixOfParams[0], $MatrixOfParams[1]);
        }
    }    

    function executeProcedure(): void
    {
        $this->PreparedProcedure->execute();
    }

    function fetchExecutionProcedure(): void
    {   
        // $this->result = $this->PreparedProcedure->fetchAll(PDO::FETCH_ASSOC);
        $this->result = $this->PreparedProcedure->fetchAll(PDO::FETCH_OBJ);
    }

    function RenderXML():void{
        $this->_SetXMLheader();
        foreach($this->result[0] as $xml){
            $obj_xml = simplexml_load_string($xml);
        }
        echo $obj_xml->asXML();
    }

    function _SetXMLheader(){
        header('Content-type: text/xml');
    }

}
