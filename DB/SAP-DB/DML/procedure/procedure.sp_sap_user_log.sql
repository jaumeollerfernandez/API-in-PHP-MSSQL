CREATE or alter procedure sp_sap_user_log
    @user_id nvarchar(255),@pwd nvarchar(255)
as

begin
    SET NOCOUNT ON
    DECLARE @ret INT;
    DECLARE @valid INT;
    set @ret=-1;

    exec @valid = dbo.sf_sap_user_validate_pwd @user_id = @user_id, @pwd = @pwd;

  print '1'
    if(@valid=1)begin
        exec @ret=sp_sap_conn_create @user_id;
        set @ret=0;
    end

    if (@ret=0)
        begin
            select * from _sap_users where user_id = @user_id for xml auto;
        end
    else
        begin 
             EXEC sp_sap_utils_XMlresponse @ret;
        end

   /********************************* TEST UNITARIO*********************************
         exec sp_sap_user_login "mawwrc@gmail.com","1234"
    *********************************************************************************/
    return @ret

end
go