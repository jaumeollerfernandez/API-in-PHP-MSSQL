CREATE FUNCTION sf_sap_conn_useralreadyloggedin(@user_id NVARCHAR(255))
RETURNS INT
AS
BEGIN
    DECLARE @response INT;
    SET @response = 0;
    IF ( (SELECT COUNT(*) FROM _sap_conn WHERE user_id = @user_id) = 1)
        SET @response = -1;
    RETURN @response;
END
