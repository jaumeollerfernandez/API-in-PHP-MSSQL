<?php 

include_once __DIR__."/SecurityController/clsUser.php";

// $test = new clsUser('Register', ['JJ', '1234', 'Jaume']);
// $test = new clsUser('login', ['JJ', '1234']);
$test = new clsUser();
// $test->ExecuteAction('register', ['JJ', '1234', 'Jaume']);
$test->ExecuteAction('login', ['JJ', '1234']);
// $test->ExecuteAction('logout', ['']);
?>