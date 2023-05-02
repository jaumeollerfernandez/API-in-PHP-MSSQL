<?php

include_once __DIR__."/interface/ControllerDataBaseInterface.php";

class clsExecuteProceduresToDB implements ControllerDataBaseInterface{

    private PDO $DBconnection;
    private string $ProcedureName;
    private $PreparedProcedure;
    private Array $_ProcedureQueue = [];
    private Array $result;
    private int $_id = 1;

    function __construct(PDO $PDOconnection)
    {
        $this->DBconnection = $PDOconnection;
    }

    function CallProcedure(string $NameProcedure, Array $Params = [], string $TypeOfParam){

        switch($TypeOfParam){
            case 'multiple':
                for($i = 0; $i < count($Params); $i++){
                    $this->prepareProcedure($NameProcedure, $Params[$i], count($Params[0]));
                    array_push($this->_ProcedureQueue, $this->PreparedProcedure);
                }
                print_r($this->_ProcedureQueue);
                
                foreach($this->_ProcedureQueue as $Procedure){
                    var_dump($Procedure);
                    // $this->executeProcedure($Procedure);
                }
                break;
            case 'single':
                $this->prepareProcedure($NameProcedure, $Params, 0);
                $this->executeProcedure($this->PreparedProcedure);
                break;
            case 'none':
                $this->prepareProcedure($NameProcedure, [], 0);
                $this->executeProcedure($this->PreparedProcedure);
                $this->fetchExecutionProcedure();
                $this->RenderXML();
                break;
            default:
                echo('Error in your Procedure Call');
        }
            

    }
    
    function prepareProcedure(string $name_procedure, array $params = [], int $NumberOfFields): void
    {
        $this->PreparedProcedure = null;
        $this->ProcedureName = $name_procedure;
        $this->PreparedProcedure = $this->DBconnection->prepare($this->ProcedureName);
        if(count($params) > 0){
            $this->BindParamToProcedure($params, $NumberOfFields);
        }
    }

    function BindParamToProcedure($ArrayOfParams){
        for($j = 1; $j <= count($ArrayOfParams); $j++){
            $this->PreparedProcedure->bindParam($this->_id,$ArrayOfParams[$j-1]);
            $this->_id++;
        }
    }   
    
    function executeProcedure($Procedure): void
    {
        $Procedure->execute();
    }
    
    function fetchExecutionProcedure(): void
    {   
        $this->result = $this->PreparedProcedure->fetchAll();
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
// function BindParamToProcedure($MatrixOfParams, $NumberOfFields){
//     $id = 1;
//     for($i = 0; $i < count($MatrixOfParams); $i++){
//         for($j = 1; $j <= $NumberOfFields+1; $j++){
//             echo($MatrixOfParams[$i][$j-1]);
//             $this->PreparedProcedure->bindParam($id,$MatrixOfParams[$i][$j-1]);
//             $id++;
//         }
//     }
// }    
?>