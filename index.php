<?php 

include_once __DIR__."/Server API/new_modules/clsServerAPI.php";
include_once __DIR__."/Server API/new_modules/clsParam.php";
include_once __DIR__."/Server API/new_modules/clsRequest.php";
include_once __DIR__."/Server API/new_modules/clsError.php";
include_once __DIR__."/SecurityController/clsUser.php";

// $test = new clsUser('Register', ['JJ', '1234', 'Jaume']);
// $test = new clsUser('login', ['JJ', '1234']);
// $test = new clsUser("172.17.0.1","14333","TEST_WS_API_07","SA","@Asix13021997");
// $test->ExecuteAction('register', ['JJ', '1234', 'Jaume']);
// $test->ExecuteAction('login', ['JJ', '1234']);
// $test->ExecuteAction('logout', ['']);
$API = new clsServerAPI("Server API/xml/web_api_0_1.xml");
$response = new clsResponse();
$Request = new clsRequest();

try{
    $action_value = $Request->getValueURL("action");
}finally{
    if( $action_value != 'undefined'){
        $API->ParseWebMethod();
        $API->Validate($action_value);
        $tempErrorMethod = $API->getErrors();
        $response->appendError($tempErrorMethod);
    }else{
        $error = new clsError(1007);
        $response->setError($error);
    }     

    $response->Render('XML');
}
?>