CREATE PROCEDURE sp_sap_conn_useralreadyloggedin
    @user_id nvarchar(255), @pwd nvarchar(255)
AS
BEGIN

    DECLARE @ret INT;
    DECLARE @valid INT;
    set @ret=-1;

    exec @valid = dbo.sf_sap_conn_useralreadyloggedin @user_id = @user_id;

    if(@valid=0)
        BEGIN
            EXEC dbo.sp_sap_utils_XMlresponse @ret, @message = 'Login autorizado, cookie correcta';
        END    
    ELSE
        BEGIN
            EXEC dbo.sp_sap_user_login @user_id = @user_id, @pwd = @pwd;
        END

    END

GO