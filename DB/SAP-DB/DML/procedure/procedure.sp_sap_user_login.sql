CREATE procedure sp_sap_user_login
    @user_id nvarchar(255),@pwd nvarchar(255)
AS

BEGIN

    DECLARE @ret INT;
    DECLARE @validpwd INT;
    DECLARE @valid INT;
    set @ret=1;

    exec @validpwd = dbo.sf_sap_user_validate_pwd @user_id = @user_id, @pwd = @pwd;

    IF(@validpwd=1)
    BEGIN
        EXEC @valid = dbo.sp_sap_conn_useralreadyloggedin @user_id = @user_id;
        IF(@valid=0)
            BEGIN
                set @ret=0;
                exec @ret= dbo.sp_sap_conn_create @user_id;
            END
        ELSE
            BEGIN 
                 EXEC dbo.sp_sap_utils_XMlresponse @ret, @message = 'Error en el proceso de Login. Vigile que no este ya en el servicio o que el usuario o la contraseña sean correctos';
            END
    END

   ELSE
        BEGIN 
             EXEC dbo.sp_sap_utils_XMlresponse @ret,@message = 'Error en el proceso de Login. Vigile que el usuario o la contraseña sean correctos';
        END
end
go