CREATE TABLE [dbo].[_sap_users] (
    [user_id]   NVARCHAR (255)   NOT NULL,
    [nickname]  NVARCHAR (255)   NULL,
    [user_name] NVARCHAR (255)   NOT NULL,
    [surname]   NVARCHAR (255)   NULL,
    [pwd]       VARBINARY (255)  NOT NULL,
    [phone]     NVARCHAR (255)   NULL,
    [_mndt]     INT              DEFAULT ((0)) NULL,
    [_created]  DATETIME         DEFAULT (getdate()) NULL,
    [_updated]  DATETIME         NULL,
    [_deleted]  DATETIME         NULL,
    [_row_guid] UNIQUEIDENTIFIER DEFAULT (newid()) NULL,
    PRIMARY KEY CLUSTERED ([user_id] ASC)
);


GO
CREATE TABLE [dbo].[_sap_conn] (
    [conn_guid]  UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [user_id]    NVARCHAR (255)   NOT NULL,
    [cTime]      DATETIME         NULL,
    [last_batch] DATETIME         NULL,
    [_mndt]      INT              DEFAULT ((0)) NULL,
    [_created]   DATETIME         DEFAULT (getdate()) NULL,
    [_updated]   DATETIME         NULL,
    [_deleted]   DATETIME         NULL,
    [_row_guid]  UNIQUEIDENTIFIER DEFAULT (newid()) NULL,
    PRIMARY KEY CLUSTERED ([user_id] ASC),
    CONSTRAINT [_sap_conn__sap_users_user_id_fk] FOREIGN KEY ([user_id]) REFERENCES [dbo].[_sap_users] ([user_id])
);


GO


CREATE function sf_sap_user_exists(@user_id nvarchar(255))
RETURNS INT
as

begin
DECLARE @response int;

SET @response = 0;
IF ( (SELECT count(*) from _sap_users where user_id = @user_id) = 1)

SET @response = -1;

RETURN @response

/********************************* TEST UNITARIO*********************************
DECLARE @ret INT;
EXEC @ret = sf_if_exist_user @user_id = 'ely@gmail.com' ;
select @ret;
*********************************************************************************/
END

GO

CREATE FUNCTION sf_sap_user_validate_pwd(@user_id nvarchar(255),
    @pwd nvarchar(255))
RETURNS INT
AS
BEGIN
    DECLARE @encryptedPassword varbinary(256);
    DECLARE @isMatch INT;

    SET @encryptedPassword = PWDENCRYPT(@pwd)

    SELECT @isMatch = PWDCOMPARE(@pwd, @encryptedPassword)
    FROM _sap_users
    WHERE user_id = @user_id;

    return @isMatch;
END

GO

CREATE function sf_conn_exist(@conn_guid uniqueidentifier)
RETURNS INT
AS
BEGIN
DECLARE @response int;

SET @response = 1;

if((select count(*) from _sap_conn where conn_guid = @conn_guid) = 1) 
SET @response = 0

RETURN @response;

/********************************* TEST UNITARIO*********************************
DECLARE @ret INT;
EXEC @ret = sf_conn_exist @conn_guid = '211e3628-362b-40da-a07d-1ba438f68ab6' ;
select @ret;

SELECT * from _sap_conn;

ANOTACIÓN : si la length guid no es convencional devuelve NULL;;;;;;;
*********************************************************************************/

end

GO

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

GO

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
        -- EXEC sp_sap_session_XMLresponse @user_id;
    END    
        RETURN @ret;
    END

GO

create procedure sp_sap_utils_XMlresponse
    @error nvarchar(255),@message nvarchar(255) 
AS
BEGIN
    SELECT @error AS 'error', @message AS 'message' FOR XML PATH(''), ROOT('XMLresponse')

    /********************************* TEST UNITARIO*********************************
       exec sp_sap_utils_XMLresponse hola;
    *********************************************************************************/
end

GO


CREATE   procedure sp_sap_conn_create
    @user_id nvarchar(255)
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @ret int = 1;
    DECLARE @time datetime;


    SET @time = GETDATE()
    insert into _sap_conn (user_id, cTime,last_batch)
    values (@user_id, @time,@time)

    SELECT @ret AS [ret],
           @user_id AS [user_id],
           @time AS [cTime],
           @time AS [last_batch]
    FOR XML PATH('sp_sap_conn_create'), ROOT('XMLresponse');
    /********************************* TEST UNITARIO*********************************
      exec sp_sap_users_login "marc@gmail.com","mac"
    *********************************************************************************/
END

GO

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
                -- EXEC dbo.sp_sap_session_XMLresponse @user_id;
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

GO


create procedure sp_sap_conn_validate
    @conn_guid UNIQUEIDENTIFIER
AS
BEGIN

    DECLARE @ret integer = 0;
    DECLARE @response integer;

    EXEC @response =  dbo.sf_conn_exist  @conn_guid = @conn_guid ;

    if(@response = 1) set @ret = 1;

    return @ret;
   
    /********************************* TEST UNITARIO*********************************
       exec sp_sap_conn_validate 'fdb7b93b-d47c-456f-b885-a626458fc0bf' ;

       select * from _sap_conn;
    *********************************************************************************/
END

GO

CREATE PROCEDURE sp_sap_session_XMLresponse_login_successful
    @user_id nvarchar(255)
AS
BEGIN
   SELECT [user].user_name
   FROM _sap_users [user] 
   where [user].user_id = @user_id 
   FOR XML PATH(''), ELEMENTS, ROOT('XMLresponse')
END
   /********************************* TEST UNITARIO*********************************
         exec sp_sap_session_XMLresponse "u1@gmail.com"
    *********************************************************************************/

GO

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

GO

create procedure sp_sap_user_logout
    @conn_guid UNIQUEIDENTIFIER
AS
BEGIN
DECLARE @ret integer = 1
   DELETE FROM _sap_conn where conn_guid = @conn_guid 

   if(@@rowcount = 1) SET @ret = 0;

   EXEC sp_sap_utils_XMlresponse @ret,@message = 'usuario desconectado';
END

GO


CREATE PROCEDURE sp_sap_session_XMLresponse
    @user_id nvarchar(255)
AS
BEGIN
   SELECT [user].user_name, conn.conn_guid, CONVERT(int, 0) AS [error]
   FROM _sap_users [user] 
   JOIN _sap_conn conn 
   ON [user].user_id = conn.user_id
   where [user].user_id = @user_id 
   FOR XML PATH(''), ELEMENTS, ROOT('XMLresponse')
END
   /********************************* TEST UNITARIO*********************************
         exec sp_sap_session_XMLresponse "u1@gmail.com"
    *********************************************************************************/

GO

CREATE PROCEDURE sp_sap_conn_purgue
AS
BEGIN
DELETE FROM _sap_conn where  DATEDIFF(second,last_batch,GETDATE()) > 10*60; 
/************************************************TEST UNITARIO***********************************************/
/*
select DATEDIFF(minute,last_batch,GETDATE()),* from _sap_conn

BEGIN tran
DELETE FROM _sap_conn where  DATEDIFF(minute,last_batch,GETDATE()) > 3; 
rollback
                                                                                                                           */
/****************************************************************************************************************************/
END

GO

CREATE PROCEDURE sp_sap_conn_update_lbatch
     @conn_guid NVARCHAR(255)
AS
BEGIN
DECLARE @ret integer = 1;
UPDATE _sap_conn  SET last_batch = GETDATE() where conn_guid = @conn_guid;
if(@@rowcount = 1) SET @ret = 0

return @ret;
/*********************************************TEST UNITARIO*************************************************************
    select * from _sap_conn
    exec  sp_sap_conn_update_lbatch 'fdb7b93b-d47c-456f-b885-a626458fc0bf' 
***********************************************************************************************************************/
END

GO


