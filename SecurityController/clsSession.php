<?php

class clsSession{
    private string $CookieName = 'PHPESSID';
    private string $CID;
    private int $CookieTime = 3600;
    private bool $HasCookie;

    public function __construct(){}

    public function ItHasCookie(){
        $this->_DetectCookieOnClient();
        return $this->HasCookie;
    }

    public function SetCID($cid){
        $this->CID = $cid;
    }

    public function SetCookie(){
        setcookie($this->CookieName,  $this->CID, time() + $this->CookieTime);
    }

    public function UnsetCookie(){
        setcookie($this->CookieName, "", time()-3600);   
    }

    protected function _DetectCookieOnClient(){
        if(isset($_COOKIE[$this->CookieName])){
            $this->HasCookie = true;
        }else{
            $this->HasCookie = false;
        }
    }



}

?>