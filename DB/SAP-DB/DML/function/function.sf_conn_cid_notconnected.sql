CREATE or alter function sf_sap_conn_cid_notconnected (@conn_guid nvarchar(255))
RETURNS INT
as

begin
DECLARE @response int;

SET @response = 0;
IF ( (SELECT count(*) from _sap_conn where conn_guid = @conn_guid) = 0)
    BEGIN
        SET @response = -1;
    END

RETURN @response

END
go