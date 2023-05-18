CREATE function sf_conn_exist(@conn_guid uniqueidentifier)
RETURNS INT
AS
BEGIN
DECLARE @response int;

SET @response = 1;

if((select count(*) from _sap_conn where conn_guid = @conn_guid) = 1) 
SET @response = 0

RETURN @response;

/********************************* TEST UNITARIO*********************************
DECLARE @ret INT;
EXEC @ret = sf_conn_exist @conn_guid = '211e3628-362b-40da-a07d-1ba438f68ab6' ;
select @ret;

SELECT * from _sap_conn;

ANOTACIÓN : si la length guid no es convencional devuelve NULL;;;;;;;
*********************************************************************************/

end 
go