<?php 

include_once __DIR__."/DB_utils/clsConnectToDB.php";
include_once __DIR__."/DB_utils/clsExecuteProceduresToDB.php";

$a = new clsConnectToDB("172.17.0.1","14333","shop","SA","@Asix13021997");
$a->initConnection();
$b = new clsExecuteProceduresToDB($a->getPDODB());
$b->prepareProcedure("get_products");
$b->executeProcedure();
$b->fetchExecutionProcedure();

?>