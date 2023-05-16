CREATE PROCEDURE sp_sap_conn_update_lbatch
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