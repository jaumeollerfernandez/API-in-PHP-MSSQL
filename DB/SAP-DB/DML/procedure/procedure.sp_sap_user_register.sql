create procedure sp_sap_user_register
    @user_id nvarchar(255),@pwd nvarchar(255),@name nvarchar(255)
as

begin
    SET NOCOUNT ON 
    DECLARE @ret INT;
    DECLARE @exists INT;
    set @ret=-1;

    EXEC @exists = sf_sap_user_exists @user_id = @user_id ;

    if(@exists = 0) begin
        insert into _sap_users (user_id,pwd,user_name)
        values (@user_id,PWDENCRYPT(@pwd),@name)
        set @ret=0;
        EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario registrado';
    end
    else
        EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario no registrado';

   /********************************* TEST UNITARIO*********************************
      exec sp_sap_user_register "mawwrc@gmail.com","123","marc"
    *********************************************************************************/
end
go