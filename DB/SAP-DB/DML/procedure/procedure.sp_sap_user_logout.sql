create OR ALTER procedure sp_sap_user_logout
    @conn_guid nvarchar(255)
AS
BEGIN
DECLARE @ret INTEGER = 1
DECLARE @validatecid INTEGER;
	SET NOCOUNT ON;
    EXEC @validatecid = dbo.sf_conn_validate_cid @cid = @conn_guid;

    IF(@validatecid = 0)
        BEGIN
            DELETE FROM _sap_conn where conn_guid = @conn_guid;
            SET @ret = 0;
            EXEC sp_sap_utils_XMlresponse @ret, @message = 'Usuario desconectado satisfactoriamente.';
        END
    ELSE
        BEGIN
             EXEC sp_sap_utils_XMlresponse @ret, @message = 'El CID correspondiente no se encuentra en la base de datos. No se ha realizado la acción.';
        END   
END
go 