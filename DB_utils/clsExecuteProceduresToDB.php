<?php

include_once __DIR__."/interface/ControllerDataBaseInterface.php";

class clsExecuteProceduresToDB implements ControllerDataBaseInterface{

    private PDO $DBconnection;
    private string $ProcedureName;
    private $PreparedProcedure;
    private Array $_ProcedureQueue = [];
    private $result = [];
    private int $_id = 1;

    function __construct(PDO $PDOconnection)
    {
        $this->DBconnection = $PDOconnection;
    }

    /**
     * Public functions to call
     */

    function CallProcedure(string $NameProcedure, Array $Params = []){

        /**
         * NOTE: Checking a Matrix is because you can put a Matrix in DBController params and will execute multiple times the procedure called. This was intended because on the first thought I didn't know if it will be one procedure each time or multiples. This part can be ignored, and see the code from "case:false" in the switch below.
         */

        $CheckIfItsMatrix = $this->_CheckIfItsMatrix($Params);

        switch($CheckIfItsMatrix){

            case true:
                $this->_PrepareProcedureQueue($NameProcedure, $Params);
                $this->_BindParamsAndExecuteProcedureQueue($Params);
                break;

            case false:
                $ItHasParams = $this->_CheckIfItsEmpty($Params);
                if ($ItHasParams == false){
                   $this->_PrepareProcedureWithParams($NameProcedure, $Params);
                }else{
                    $this->_PrepareProcedureWithoutParams($NameProcedure);
                }
                break;

            default:
                echo('Error in your Procedure Call');
        }
    }

    function GetResult(){
        return $this->result;
    }

    /**
     * Internal functions
     */
    
    function _PrepareProcedureQueue(string $NameProcedure, Array $Params): void{
        for($i = 0; $i < count($Params); $i++){
            $ConcatenatedString = $this->_PrepareStringToPrepareProcedure($NameProcedure, $Params);
            $this->prepareProcedure($ConcatenatedString, $Params[$i], count($Params[0]));
            $this->_InsertProcedureIntoQueue($this->PreparedProcedure);
        }
    }
    
    function _PrepareProcedureWithParams(string $NameProcedure, Array $Params): void{
        $ConcatenatedString = $this->_PrepareStringToPrepareProcedure($NameProcedure, $Params);
        $this->prepareProcedure($ConcatenatedString, $Params, 0);
        $this->_BindParamToProcedure($Params);
        $this->executeProcedure($this->PreparedProcedure);
        $this->fetchExecutionProcedure();
    }

    function _PrepareProcedureWithoutParams($NameProcedure){
        $this->prepareProcedure($NameProcedure, [], 0);
        $this->executeProcedure($this->PreparedProcedure);
        $this->fetchExecutionProcedure();
    }

    function _BindParamsAndExecuteProcedureQueue(Array $Params): void{
        try{
            for($j = 0; $j < count($this->_ProcedureQueue); $j++){
                print_r($Params[$j]);
                $this->_BindParamToProcedure($Params[$j]);
                $this->executeProcedure();
            }
        }catch(PDOException $error){
            echo($error);
        }
    }
    
    function _SetXMLheader(): void{
        header('Content-type: text/xml');
    }
    
    function _RenderXML(): void{
        $this->_SetXMLheader();
        foreach($this->result[0] as $xml){
            $obj_xml = simplexml_load_string($xml);
        }
        ob_clean();
        echo $obj_xml->asXML();
    }
    
    function _CheckIfItsMatrix(Array $Matrix):bool{
        try{
            $result = is_array($Matrix[0]);
        }catch(PDOException $error){
            echo($error);
        }
        return $result;
    }

    function _CheckIfItsEmpty(Array $Array){
        try{
            $result = empty($Array);
        }catch(PDOException $error){
            echo($error);
        }
        return $result;
    }
    
    
    function prepareProcedure(string $name_procedure, array $params = []): void
    {
        $this->ProcedureName = $name_procedure;
        $this->PreparedProcedure = $this->DBconnection->prepare($this->ProcedureName);
    }

    function _BindParamToProcedure($ArrayOfParams){
        $this->_id = 1;
        for($j = 1; $j <= count($ArrayOfParams); $j++){
            $this->PreparedProcedure->bindParam($this->_id,$ArrayOfParams[$j-1]);
            $this->_id++;
        }
    }   

    function executeProcedure(): void
    {
        $this->PreparedProcedure->execute();
    }

    function _InsertProcedureIntoQueue($Procedure): void{
        array_push($this->_ProcedureQueue, $Procedure);
    }

    function _PrepareStringToPrepareProcedure(string $name_procedure, $ArrayOfParams): string{

        $EXEC = "EXEC ";
        $Interrogation = $this->_ObtainNumberOfInterrogations($ArrayOfParams);
        $ConcatenatedString = $EXEC . $name_procedure . " ". $Interrogation;
        return $ConcatenatedString;
    }

    function _ObtainNumberOfInterrogations(Array $Array): string{
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
        }
        else{
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

    function fetchExecutionProcedure(): void
    {   
        $this->result = $this->PreparedProcedure->fetchAll();
    }

    
}
