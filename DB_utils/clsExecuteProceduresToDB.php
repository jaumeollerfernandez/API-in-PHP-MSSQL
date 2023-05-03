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

    function CallProcedure(string $NameProcedure, Array $Params = [], string $TypeOfParam = 'single'){

        $CheckIfItsMatrix = $this->_CheckIfItsMatrix($Params);

        switch($CheckIfItsMatrix){
            case true:
                for($i = 0; $i < count($Params); $i++){
                    $ConcatenatedString = $this->_PrepareStringToPrepareProcedure($NameProcedure, $Params);
                    $this->prepareProcedure($ConcatenatedString, $Params[$i], count($Params[0]));
                    array_push($this->_ProcedureQueue, $this->PreparedProcedure);
                }
                try{
                    print_r(count($this->_ProcedureQueue));
                    for($j = 0; $j < count($this->_ProcedureQueue); $j++){
                        print_r($Params[$j]);
                        $this->BindParamToProcedure($Params[$j]);
                        var_dump($this->PreparedProcedure);
                        echo('<br>');
                        echo('<br>');
                        echo('<br>');
                        echo('<br>');
                        $this->executeProcedure($this->PreparedProcedure);
                    }
                }catch(PDOException $error){
                    echo('<br>');
                    echo($error);
                }
                break;
            case false:
                if (count($Params) > 0){
                    $ConcatenatedString = $this->_PrepareStringToPrepareProcedure($NameProcedure, $Params);
                    $this->prepareProcedure($ConcatenatedString, $Params, 0);
                    $this->BindParamToProcedure($Params);
                }else{
                    $this->prepareProcedure($NameProcedure, [], 0);
                    $this->executeProcedure($this->PreparedProcedure);
                    $this->fetchExecutionProcedure();
                    $this->RenderXML();
                }
                break;
            default:
                echo('Error in your Procedure Call');
        }
            

    }

    function _CheckIfItsMatrix($Matrix){
        $result = is_array($Matrix[0]);
        return $result;
    }

    function _PrepareStringToPrepareProcedure(string $name_procedure, $ArrayOfParams){

        $EXEC = "EXEC ";
        $Interrogation = $this->_ObtainNumberOfInterrogations($ArrayOfParams);
        $ConcatenatedString = $EXEC . $name_procedure . " ". $Interrogation;
        return $ConcatenatedString;
    }

    function _ObtainNumberOfInterrogations(Array $Array){
        $result = [];
        $CheckIfItsMatrix = $this->_CheckIfItsMatrix($Array);
        
        if($CheckIfItsMatrix == true){
            if(count($Array[0]) > 0){
                for($i = 1; $i <= count($Array[0]); $i++){
                    array_push($result, "?");
                    if($i != count($Array[0])){
                        array_push($result, ",");
                    }
                }
            }
        }else{
            if(count($Array) > 0){
                for($i = 1; $i <= count($Array); $i++){
                    array_push($result, "?");
                    if($i != count($Array)){
                        array_push($result, ",");
                    }
                }
            }

        }
        return implode("",$result);
    }
    
    function prepareProcedure(string $name_procedure, array $params = []): void
    {
        $this->ProcedureName = $name_procedure;
        $this->PreparedProcedure = $this->DBconnection->prepare($this->ProcedureName);
    }

    function BindParamToProcedure($ArrayOfParams){
        $this->_id = 1;
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