CREATE procedure sp_sap_user_login
    @user_id nvarchar(255),@pwd nvarchar(255)
AS

BEGIN
    DECLARE @ret INT;
    DECLARE @valid INT;
    set @ret=1;

    exec @valid = dbo.sf_sap_user_validate_pwd @user_id = @user_id,@pwd = @pwd;

    if(@valid=0)
    BEGIN
        set @ret=0;
        exec @ret=sp_sap_conn_create @user_id;
        EXEC sp_sap_session_XMLresponse @user_id;
    END

   ELSE
        BEGIN 
             EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario no encontrado';
        END
   /********************************* TEST UNITARIO*********************************
         exec sp_sap_user_login "u1@gmail.com","1"
         exec sp_sap_user_login "u2@gmail.com","1"
         exec sp_sap_user_login "u3@gmail.com","1"
    *********************************************************************************/
end
go