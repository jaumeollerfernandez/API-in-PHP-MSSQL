CREATE OR ALTER PROCEDURE sp_sap_conn_useralreadyloggedin
    @user_id nvarchar(255)
AS
BEGIN

    DECLARE @ret INT;
    DECLARE @valid INT;
    set @ret=-1;

    exec @valid = dbo.sf_sap_conn_useralreadyloggedin @user_id = @user_id;
    if(@valid=0)
        BEGIN
            return @valid;
        END    
    ELSE
        BEGIN
            EXEC dbo.sp_sap_utils_XMlresponse_successful @user_id=@user_id;
        END

END
GO