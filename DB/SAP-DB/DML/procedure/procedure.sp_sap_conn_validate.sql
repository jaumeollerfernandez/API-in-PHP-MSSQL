create procedure sp_sap_conn_validate
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