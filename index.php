<?php 

include_once __DIR__."/DB_Controller/clsDbController.php";

$test = new clsDbController();
$test->AddConnectionToDB("172.17.0.1","14333","WS_API_07","SA","@Asix13021997");
// $a->ExecuteProcedure("insert_employee",[['testc',10,'a'],['testD',11,'b'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC']]);
$test->ExecuteProcedure("sp_sap_user_regist",['Kothannnnn', '1234', 'Jaume']);
$test->_ObtainResult('None');

?>