<?php

include_once __DIR__."/interface/ControllerDataBaseInterface.php";

class clsExecuteProceduresToDB implements ControllerDataBaseInterface{

    private PDO $DBconnection;
    private string $ProcedureName;
    private PDOStatement $PreparedProcedure;

    function __construct(PDO $PDOconnection)
    {
        $this->DBconnection = $PDOconnection;
    }

    function prepareProcedure(string $name_procedure, array $params = []): void
    {
        
    }

    function BindParamToProcedure($ParamName, $ParamVariable, $ParamType){
       $this->PreparedProcedure->bindParam($ParamType, $ParamVariable); 
    
        // Ejemplo de porqué es así
        // $calorías = 150;
        // $color = 'red';
        // $gsent = $gbd->prepare('SELECT name, colour, calories
        // FROM fruit
        // WHERE calories < :calories AND colour = :colour');
        // $gsent->bindParam(':calories', $calorías, PDO::PARAM_INT);
        // $gsent->bindParam(':colour', $color, PDO::PARAM_STR, 12);
        // $gsent->execute();
    
    }

    function executeProcedure(): void
    {
        
    }

    function fetchExecutionProcedure(): void
    {
        
    }

    function RenderXML($Data){
        
    }

}


?>