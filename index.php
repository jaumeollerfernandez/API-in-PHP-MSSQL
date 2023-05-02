<?php 

include_once __DIR__."/DB_utils/clsConnectToDB.php";
include_once __DIR__."/DB_utils/clsExecuteProceduresToDB.php";

$a = new clsConnectToDB("172.17.0.1","14333","shop","SA","@Asix13021997");
$a->initConnection();
$b = new clsExecuteProceduresToDB($a->getPDODB());
// $b->prepareProcedure("EXEC insert_employee @employee_name=?, @employee_salary=?, @employee_department=?",[['testc',10,'a'],['testD',11,'b']]);
$b->CallProcedure("EXEC insert_employee @employee_name=?, @employee_salary=?, @employee_department=?",[['testc',10,'a'],['testD',11,'b']], 'multiple');
// $b->CallProcedure("EXEC insert_employee @employee_name=?, @employee_salary=?, @employee_department=?",['a','b','c'], 'single');
// $b->prepareProcedure("get_products",[],0);
// $b->executeProcedure();
// $b->fetchExecutionProcedure();
// $b->RenderXML();

?>