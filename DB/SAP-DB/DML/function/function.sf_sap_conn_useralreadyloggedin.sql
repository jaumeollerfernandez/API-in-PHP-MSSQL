CREATE or alter function sf_sap_conn_useralreadyloggedin (@user_id nvarchar(255))
RETURNS INT
as

begin
DECLARE @response int;

SET @response = 0;
IF ( (SELECT count(*) from _sap_conn where user_id = @user_id) = 1)
    BEGIN
        SET @response = -1;
    END


RETURN @response

END
go