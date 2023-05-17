CREATE PROCEDURE sp_sap_conn_useralreadyloggedin
    @user_id nvarchar(255)
AS
BEGIN

    DECLARE @ret INT;
    DECLARE @valid INT;
    set @ret=-1;

    exec @valid = dbo.sf_sap_conn_useralreadyloggedin @user_id = @user_id;

    if(@valid=0)
    BEGIN
        set @ret=0;
        EXEC sp_sap_session_XMLresponse @user_id;
    END    
        RETURN @ret;
    END
    GO