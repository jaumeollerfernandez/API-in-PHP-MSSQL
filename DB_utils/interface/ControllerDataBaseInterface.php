<?php

/**
 *  CONSTRUCTOR PARAMS
 * ----------------------------------
 * $this->db = $pDB;
 * 
 * 
 * PRIVATE FUNCTION
 * ----------------------------------
 * bindParamsToProcedure(string $name, array $params): void;
 * putInterrogationMarks(array $params): string;
 * 
 */

interface ControllerDataBaseInterface {

    public function prepareProcedure(string $name_procedure, array $params=[], int $NumberOfFields): void;

    public function executeProcedure(PDOStatement $Procedure): void;

    public function fetchExecutionProcedure(): void;

    // public function renderData(): void;

    // public function renderDataXML(): void;

}

?>