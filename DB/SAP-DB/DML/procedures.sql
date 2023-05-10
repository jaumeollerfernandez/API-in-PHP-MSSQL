
/********************************************************************************************************************/
/*sp_sap_utils_XMLrespons
  Description: genera respuesta XML  
*/
/********************************************************************************************************************/

create   procedure sp_sap_utils_XMlresponse
    @response nvarchar(255)
as

begin

    SELECT @response as 'response' FOR XML PATH(''), ROOT('ERROR')

    /********************************* TEST UNITARIO*********************************
       exec sp_sap_utils_XMLresponse hola;
    *********************************************************************************/
end
go


/********************************************************************************************************************/
/* sp_sap_conn_create 
   Description:  Registra la fecha de conexión del usuario.
   @user_id: IN -> PK - UniqueKey 
*/
/********************************************************************************************************************/
CREATE   procedure sp_sap_conn_create
    @user_id nvarchar(255)
as

begin
    DECLARE @time datetime;

    SET @time = GETDATE()
    insert into _sap_conn (user_id, cTime)
    values (@user_id, @time)

    /********************************* TEST UNITARIO*********************************
      exec sp_sap_users_login "marc@gmail.com","mac"
    *********************************************************************************/
end
go

/********************************************************************************************************************/
/* sp_sap_user_register 
   Description:  Registra un nuevo usuario.
   @user_id: IN -> NVARCHAR(255) - PK - UniqueKey,
   @pwd: IN -> NVARCHAR(255),
   @name: IN -> NVARCHAR(255)  
*/
/********************************************************************************************************************/

CREATE or alter procedure sp_sap_user_register
    @user_id nvarchar(255),@pwd nvarchar(255),@name nvarchar(255)
as

begin
    DECLARE @ret INT;
    DECLARE @exists INT;
    set @ret=-1;

    EXEC @exists = sf_sap_user_exists @user_id = @user_id ;

    if(@exists = 0) begin
        insert into _sap_users (user_id,pwd,user_name)
        values (@user_id,@pwd,@name)
    end

    if(@@rowcount=1)
        BEGIN
            set @ret=0;
            SELECT * from _sap_users where user_id = @user_id FOR XML PATH(''), ROOT('USER')

        END
    else
        begin
            EXEC sp_sap_utils_XMlresponse @ret;
        end


    return @ret

   /********************************* TEST UNITARIO*********************************
      exec sp_sap_user_register "mawwrc@gmail.com","123","marc"
    *********************************************************************************/
end
go

/********************************************************************************************************************/
/* sp_sap_user_login
    Description: Autentica al usuario
   @user_id: IN -> NVARCHAR(255) - PK - UniqueKey,
   @pwd: IN -> NVARCHAR(255),
*/
/********************************************************************************************************************/


CREATE or alter procedure sp_sap_user_login
    @user_id nvarchar(255),@pwd nvarchar(255)
as

begin
    DECLARE @ret INT;
    DECLARE @valid INT;
    set @ret=-1;

    exec @valid = dbo.sf_sap_user_validate_pwd @user_id = @user_id,@pwd = @pwd;
  print '1'
    if(@valid=1)begin
        print 'Valid'
        exec @ret=sp_sap_conn_create @user_id
    end

    if @ret=0
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



SELECT * FROM sysobjects where xtype='fn';

SELECT * from _sap_users;