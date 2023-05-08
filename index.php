<?php 

include_once __DIR__."/DB_Controller/clsDbController.php";

$a = new clsDbController();
$a->AddMSSQLConnectionToDB("172.17.0.1","14333","shop","SA","@Asix13021997");
$a->ExecuteProcedure("insert_employee",[['testc',10,'a'],['testD',11,'b'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC'],['Quimo',1000,'ICC']]);

?>