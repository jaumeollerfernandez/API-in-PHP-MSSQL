/********************************************************************************************************************/
/* sp_sap_conn_create 
   Description:  Registra la fecha de conexión del usuario.
   @user_id: IN -> PK - UniqueKey 
*/
/********************************************************************************************************************/
CREATE   procedure sp_sap_conn_create
    @user_id nvarchar(255)
as

begin
    DECLARE @time datetime;

    SET @time = GETDATE()
    insert into _sap_conn (user_id, cTime)
    values (@user_id, @time)

    /********************************* TEST UNITARIO*********************************
      exec sp_sap_users_login "marc@gmail.com","mac"
    *********************************************************************************/
end
go