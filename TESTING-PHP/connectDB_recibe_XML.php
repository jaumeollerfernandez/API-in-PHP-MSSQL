<?php
class ConnectDB {

    private $password;
    private $user;
    private $databaseName;
    private $host;
    private $db;

    public function __construct() {
        $this -> connectON();
    }

    private function connectON() {
        try {
            $this -> db = new PDO("sqlsrv:Server=172.17.0.1,14333;Database=gisdb","SA","@Asix13021997");
            $this -> db -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this -> consulta(); 
        } catch (Exception $error) {
            echo "No se ha podido conectar a la bd: ". $error -> getMessage();
        }
    }

    public function consulta() {
        $request = $this -> db -> prepare("EXEC f_table_name");
        $request-> execute();
        $datos = $request -> fetchAll(PDO::FETCH_ASSOC);
        header("Content-type: text/xml");
        foreach ($datos[0] as $xml) {
            $obj_xml = simplexml_load_string($xml);
        }
        echo $obj_xml -> asXML();
        
        // var_dump($datos);
        // echo $datos[0]["XML_F52E2B61-18A1-11d1-B105-00805F49916B"];
    }
}

new ConnectDB();

?>