create procedure sp_sap_user_logout
    @conn_guid UNIQUEIDENTIFIER
AS
BEGIN
DECLARE @ret integer = 1
   DELETE FROM _sap_conn where conn_guid = @conn_guid 

   if(@@rowcount = 1) SET @ret = 0;

   EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario desconectado';
END
go 