<?php 

include_once __DIR__."/Server_API/new_modules/clsServerAPI.php";
include_once __DIR__."/Server_API/new_modules/clsParam.php";
include_once __DIR__."/Server_API/new_modules/clsRequest.php";
include_once __DIR__."/Server_API/new_modules/clsError.php";
include_once __DIR__."/SecurityController/clsUser.php";
include_once __DIR__."/SecurityController/clsSecurityController.php";

/**
 *  LOGOUT: Preparar un config en el xml de server api que gestione la entrada de un CID.
 * 
 * LOGOUT: Preparar que cuando no coincida el CID emita un error concreto.
 */

$Request = new clsRequest();
$API = new clsServerAPI("Server_API/xml/web_api_0_1.xml");
$response = new clsResponse();
$SecurityController = new clsSecurityController();
$action_value = $Request->getValueURL("action");

if( $action_value != 'undefined'){

    $API->ParseWebMethod();
    $API->Validate($action_value);
    $tempErrorMethod = $API->getErrors();
    $response->appendError($tempErrorMethod);
    if($API->ValidateThereIsNoErrors()){
        $SecurityController->ExecuteAction($action_value, $response->getURLvalues());
        $response->setResponseDataInClass($SecurityController->ObtainXMLResponse());
    }

}else{

    $error = new clsError(1007);
    $response->setError($error);
}     

$response->Render('XML');

?>