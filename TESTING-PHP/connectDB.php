<?php
class ConnectDB {


    public function __construct() {
        
        // phpinfo();

        $conn = odbc_connect("MSSQL", "SA", "@Asix13021997");
        print_r($conn);
        // $res = odbc_exec($conn, "SELECT * FROM mytable");
        
    }

    private function connectON() {


       
    }

    public function consulta() {
       
    }
}

new ConnectDB();

?>