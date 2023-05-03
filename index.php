<?php 

include_once __DIR__."/DB_utils/clsConnectToDB.php";
include_once __DIR__."/DB_utils/clsExecuteProceduresToDB.php";

$a = new clsConnectToDB("172.17.0.1","14333","shop","SA","@Asix13021997");
$a->initConnection();
$b = new clsExecuteProceduresToDB($a->getPDODB());
$b->CallProcedure("insert_employee",[['testc',10,'a'],['testD',11,'b'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC']]);
// $b->CallProcedure("insert_employee",['pingo',1000,'ICC']);
// $b->CallProcedure("get_products", [], 'none');
// $b->prepareProcedure("get_products",[],0);
// $b->executeProcedure();
// $b->fetchExecutionProcedure();
// $b->RenderXML();

?>