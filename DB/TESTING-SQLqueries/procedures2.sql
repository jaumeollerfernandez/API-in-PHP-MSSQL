/*create procedure sp_get_cart
create procedure sp_add_cart
create procedure sp_update_cart
create procedure sp_drop_cart
create procedure sp_get_products*/
   


/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/********************************************************************************************************************/
/*sp_sap_conn_validate 
  Desccription : Valida si existe una conexión usando la función sf_conn_exist 
  @conn_guid: IN-> UNIQUEIDENTIFIER    
  Return: @ret Bool                                                                                                 */
/********************************************************************************************************************/
USE WS_API_M07

create or alter procedure sp_sap_conn_validate
    @conn_guid UNIQUEIDENTIFIER
AS
BEGIN

    DECLARE @ret integer = 0;
    DECLARE @response integer;

    EXEC @response =  dbo.sf_conn_exist  @conn_guid = @conn_guid ;

    if(@response = 1) set @ret = 1;

    return @ret;
   
    /********************************* TEST UNITARIO*********************************
       exec sp_sap_conn_validate 'fdb7b93b-d47c-456f-b885-a626458fc0bf' ;

       select * from _sap_conn;
    *********************************************************************************/
END
go

/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/********************************************************************************************************************/
/*sp_sap_utils_XMLresponse
  Description: genera respuesta XML                                                                                                                      
                                                                                                                    */
/********************************************************************************************************************/

create or alter  procedure sp_sap_utils_XMlresponse
    @error nvarchar(255),@message nvarchar(255) 
AS
BEGIN
    SELECT @error AS 'error', @message AS 'message' FOR XML PATH(''), ROOT('XMLresponse')

    /********************************* TEST UNITARIO*********************************
       exec sp_sap_utils_XMLresponse hola;
    *********************************************************************************/
end
go

/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/********************************************************************************************************************/
/* sp_sap_session_XMLresponse
   Description: DEvuelve información del usuario logeado.
   @user_id: IN -> NVARCHAR(255) - PK - UniqueKey,
*/
/********************************************************************************************************************/

CREATE or alter PROCEDURE sp_sap_session_XMLresponse
    @user_id nvarchar(255)
AS
BEGIN
   SELECT [user].user_name, conn.conn_guid, CONVERT(int, 0) AS [error]
   FROM _sap_users [user] 
   JOIN _sap_conn conn 
   ON [user].user_id = conn.user_id
   where [user].user_id = @user_id 
   FOR XML PATH(''), ELEMENTS, ROOT('XMLresponse')
END
   /********************************* TEST UNITARIO*********************************
         exec sp_sap_session_XMLresponse "u1@gmail.com"
    *********************************************************************************/
go

/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/********************************************************************************************************************/
/* sp_sap_conn_create 
   Description:  Registra la fecha de conexión del usuario.
   @user_id: IN -> PK - UniqueKey
   Return: @ret bool 
*/
/********************************************************************************************************************/
CREATE or alter  procedure sp_sap_conn_create
    @user_id nvarchar(255)
AS
BEGIN
    DECLARE @ret int = 1;
    DECLARE @time datetime;


    SET @time = GETDATE()
    insert into _sap_conn (user_id, cTime,last_batch)
    values (@user_id, @time,@time)


    if (@@ROWCOUNT = 1) set @ret = 0;

    return  @ret;
    /********************************* TEST UNITARIO*********************************
      exec sp_sap_users_login "marc@gmail.com","mac"
    *********************************************************************************/
END
go

/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/********************************************************************************************************************/
/* sp_sap_user_register 
   Description:  Registra un nuevo usuario.
   @user_id: IN -> NVARCHAR(255) - PK - UniqueKey,
   @pwd: IN -> NVARCHAR(255),
   @name: IN -> NVARCHAR(255)  
*/
/********************************************************************************************************************/

CREATE or alter procedure sp_sap_user_register
    @user_id nvarchar(255),@pwd nvarchar(255),@name nvarchar(255)
AS
BEGIN
    DECLARE @ret INT;
    DECLARE @exists INT;
    DECLARE @encryptedPWD varbinary(64);
    set @ret=1;

    EXEC @exists = sf_sap_user_exists @user_id = @user_id ;

    if(@exists = 0) 
    BEGIN
        SET @encryptedPWD = HASHBYTES('SHA2_256', @pwd)
        insert into _sap_users (user_id,pwd,user_name)
        values (@user_id,@encryptedPWD,@name);
        set @ret=0;
        EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario registrado';
    end
    else
        EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario no registrado';


   /********************************* TEST UNITARIO*********************************
      exec sp_sap_user_register "u1@gmail.com","1","u1"
      exec sp_sap_user_register "u2@gmail.com","1","u2"
      exec sp_sap_user_register "u3@gmail.com","1","u3"
    *********************************************************************************/
end
go



/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/********************************************************************************************************************/
/* sp_sap_conn_update_lbatch
   Description: Actualiza el last_batch del usuario (la última vez que ha interactuado (control de conexión))
   @conn_guid: IN-> UNIQUEIDENTIFIER,
   Return: @ret Bool
*/
/********************************************************************************************************************/

CREATE or alter PROCEDURE sp_sap_conn_update_lbatch
     @conn_guid NVARCHAR(255)
AS
BEGIN
DECLARE @ret integer = 1;
UPDATE _sap_conn  SET last_batch = GETDATE() where conn_guid = @conn_guid;
if(@@rowcount = 1) SET @ret = 0

return @ret;
/*********************************************TEST UNITARIO*************************************************************
    select * from _sap_conn
    exec  sp_sap_conn_update_lbatch 'fdb7b93b-d47c-456f-b885-a626458fc0bf' 
***********************************************************************************************************************/
END
go




/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/***********************************************************************************************************************/
/*    sp_sap_conn_purgue
                                                                                                                       */               
/***********************************************************************************************************************/

CREATE OR ALTER PROCEDURE sp_sap_conn_purgue
AS
BEGIN
DELETE FROM _sap_conn where  DATEDIFF(second,last_batch,GETDATE()) > 10*60; 
/************************************************TEST UNITARIO***********************************************/
/*
select DATEDIFF(minute,last_batch,GETDATE()),* from _sap_conn

BEGIN tran
DELETE FROM _sap_conn where  DATEDIFF(minute,last_batch,GETDATE()) > 3; 
rollback
                                                                                                                           */
/****************************************************************************************************************************/
END
go


/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/********************************************************************************************************************/
/* sp_sap_user_login
    Description: Autentica al usuario
   @user_id: IN -> NVARCHAR(255) - PK - UniqueKey,
   @pwd: IN -> NVARCHAR(255),
*/
/********************************************************************************************************************/

CREATE or alter procedure sp_sap_user_login
    @user_id nvarchar(255),@pwd nvarchar(255)
AS

BEGIN
    DECLARE @ret INT;
    DECLARE @valid INT;
    set @ret=1;

    exec @valid = dbo.sf_sap_user_validate_pwd @user_id = @user_id,@pwd = @pwd;

    if(@valid=0)
    BEGIN
        set @ret=0;
        exec @ret=sp_sap_conn_create @user_id;
        EXEC sp_sap_session_XMLresponse @user_id;
    END

   ELSE
        BEGIN 
             EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario no encontrado';
        END
   /********************************* TEST UNITARIO*********************************
         exec sp_sap_user_login "u1@gmail.com","1"
         exec sp_sap_user_login "u2@gmail.com","1"
         exec sp_sap_user_login "u3@gmail.com","1"
    *********************************************************************************/
end
go



/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/********************************************************************************************************************/
/* sp_sap_user_logout
   Description: Elimina la conexión del usuario.
   @user_id: IN -> NVARCHAR(255) - PK - UniqueKey,
   @pwd: IN -> NVARCHAR(255),
*/
/********************************************************************************************************************/

create or alter procedure sp_sap_user_logout
    @conn_guid UNIQUEIDENTIFIER
AS
BEGIN
DECLARE @ret integer = 1
   DELETE FROM _sap_conn where conn_guid = @conn_guid 

   if(@@rowcount = 1) SET @ret = 0;

   EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario desconectado';
END
go  

/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/
/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/



use WS_API_M07
DElete from _sap_conn;
DElete from _sap_users;






Iniciar DB 

    /********************************* TEST UNITARIO*********************************

        use WS_API_M07
        SELECT * FROM sysobjects where xtype='p';

    *********************************************************************************/

Registrar usuarios

    /********************************* TEST UNITARIO*********************************

      exec sp_sap_user_register "u1@gmail.com","1","u1"
      exec sp_sap_user_register "u2@gmail.com","1","u2"
      exec sp_sap_user_register "u3@gmail.com","1","u3"

      select * from _sap_users

    *********************************************************************************/

Logear usuarios

    /********************************* TEST UNITARIO*********************************

         exec sp_sap_user_login "u1@gmail.com","11"
         exec sp_sap_user_login "u2@gmail.com","1"
         exec sp_sap_user_login "u3@gmail.com","1"

    *********************************************************************************/

Ver tabla conexiones

    /********************************* TEST UNITARIO*********************************

       select * from _sap_conn;

    *********************************************************************************/


Validar si hay conexiones

    /********************************* TEST UNITARIO*********************************

       exec sp_sap_conn_validate '2f033304-6418-4f7d-9bb0-e4c0ab46864e';

       select * from _sap_conn;

    *********************************************************************************/

Deslogear usuarios

    /********************************* TEST UNITARIO*********************************

         exec sp_sap_user_logout '328bb1b3-d7e7-49f1-b7e8-f96ce7fe71fc'

         select * from _sap_conn;

    *********************************************************************************/

Ver Tiempo de las conexiones

    /********************************* TEST UNITARIO*********************************

        select DATEDIFF(second,last_batch,GETDATE()),* from _sap_conn;

    *********************************************************************************/

Actualizar el last_batch

    /*********************************************TEST UNITARIO**********************

        select * from _sap_conn
        exec  sp_sap_conn_update_lbatch 'cb7f1975-103e-4fd6-8b5a-3503bac762de' 

    *********************************************************************************/

Purgar conexiones

    /*************************************TEST UNITARIO******************************

    BEGIN tran
    DELETE FROM _sap_conn where  DATEDIFF(minute,last_batch,GETDATE()) > 3*60; 
    rollback

    *********************************************************************************/