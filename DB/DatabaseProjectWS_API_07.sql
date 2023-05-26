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




CREATE   function  sf_sap_user_validate_pwd(@user_id nvarchar(255),@pwd nvarchar(255))
RETURNS INT
as
begin
DECLARE @response int;
DECLARE @hashedPassword varbinary(64) = HASHBYTES('SHA2_256', @pwd);
SET @response = 1;

IF ( (SELECT count(*) from _sap_users where user_id = @user_id and pwd = @hashedPassword) = 1)
    SET @response = 0;

RETURN @response

end

GO

CREATE   function sf_sap_conn_cid_notconnected (@conn_guid nvarchar(255))
RETURNS INT
as

begin
DECLARE @response int;

SET @response = 0;
IF ( (SELECT count(*) from _sap_conn where conn_guid = @conn_guid) = 0)
    BEGIN
        SET @response = -1;
    END

RETURN @response

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

end

GO

CREATE   FUNCTION sf_conn_validate_cid(@cid nvarchar(255))
RETURNS INT
AS
BEGIN
    DECLARE @isValid INT;
    IF TRY_CAST(@cid AS UNIQUEIDENTIFIER) IS NOT NULL
        SET @isValid = 0;
    ELSE
        SET @isValid = 1;

    RETURN @isValid;
END;

GO


CREATE   function sf_sap_conn_useralreadyloggedin (@user_id nvarchar(255))
RETURNS INT
as

begin
DECLARE @response int;

SET @response = 0;
IF ( (SELECT count(*) from _sap_conn where user_id = @user_id) = 1)
    BEGIN
        SET @response = -1;
    END


RETURN @response

END

GO


CREATE   function sf_sap_user_exists(@user_id nvarchar(255))
RETURNS INT
as

begin
DECLARE @response int;

SET @response = 0;
IF ( (SELECT count(*) from _sap_users where user_id = @user_id) = 1)
    BEGIN
        SET @response = -1;
    END


RETURN @response

END

GO





create procedure sp_sap_user_register
    @user_id nvarchar(255),@pwd nvarchar(255),@name nvarchar(255)
as

begin
    SET NOCOUNT ON 
    DECLARE @ret INT;
    DECLARE @exists INT;
    DECLARE @encryptedPWD varbinary(64);
    set @ret=-1;


    EXEC @exists = sf_sap_user_exists @user_id = @user_id ;

    if(@exists = 0) begin
        SET @encryptedPWD = HASHBYTES('SHA2_256', @pwd)
        insert into _sap_users (user_id,pwd,user_name)
        values (@user_id,@encryptedPWD,@name)
        set @ret=0;
        EXEC sp_sap_utils_XMlresponse @ret,@message = 'Usuario registrado';
    end
    else
        EXEC sp_sap_utils_XMlresponse @ret,@message = 'Usuario no registrado';

end

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

    IF(@validpwd=0)
        BEGIN
            EXEC @valid = dbo.sp_sap_conn_useralreadyloggedin @user_id = @user_id;
            IF(@valid=0)
                BEGIN
                    exec @ret= dbo.sp_sap_conn_create @user_id;
                END
        END

   ELSE
        BEGIN 
             EXEC dbo.sp_sap_utils_XMlresponse @ret,@message = 'Error en el proceso de Login. Vigile que el usuario o la contraseña sean correctos';
        END
end

GO

create   procedure sp_sap_user_logout
    @conn_guid nvarchar(255)
AS
BEGIN
DECLARE @ret INTEGER = 1
DECLARE @validatecid INTEGER;
DECLARE @validatecidconnected INTEGER;
	SET NOCOUNT ON;
    EXEC @validatecid = dbo.sf_conn_validate_cid @cid = @conn_guid;

    IF(@validatecid = 0)
        BEGIN
            EXEC @validatecidconnected = dbo.sf_sap_conn_cid_notconnected @conn_guid = @conn_guid;
            IF(@validatecidconnected = 0)
                BEGIN
                    DELETE FROM _sap_conn where conn_guid = @conn_guid;
                    SET @ret = 0;
                    EXEC sp_sap_utils_XMlresponse @ret, @message = 'Usuario desconectado satisfactoriamente.';
                END
            ELSE
                BEGIN
                    SET @ret = 1;
                    EXEC sp_sap_utils_XMlresponse @ret, @message = 'El CID correspondiente no se encuentra en la base de datos. No se ha realizado la acción.';
                END
           
        END
    ELSE
        BEGIN
             EXEC sp_sap_utils_XMlresponse @ret, @message = 'El CID no cumple con las características de un UNIQUEIDENTIFIER. No se ha realizado la acción.';
        END   
END

GO

CREATE PROCEDURE usp_GetUsers
AS
BEGIN
SET NOCOUNT ON;
WITH OrderedUsers AS (
SELECT ROW_NUMBER() OVER (ORDER BY DATEDIFF(YEAR, birthdate, GETDATE())) AS row_number,
name,
birthdate,
DATEDIFF(YEAR, birthdate, GETDATE()) AS age,
LAG(DATEDIFF(YEAR, birthdate, GETDATE())) OVER (ORDER BY DATEDIFF(YEAR, birthdate, GETDATE())) AS
previous_age
FROM users
)
SELECT row_number, name, birthdate, age, age - previous_age AS previous_age_diff
FROM OrderedUsers
ORDER BY age;
END;

GO



CREATE   PROCEDURE sp_sap_conn_useralreadyloggedin
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
            EXEC dbo.sp_sap_session_XMLresponse_successful @user_id=@user_id;
        END

END

GO

create   procedure sp_sap_utils_XMlresponse
    @error nvarchar(255),@message nvarchar(255) 
AS
BEGIN
    SELECT @error AS 'ret', @message AS 'message' FOR XML PATH(''), ROOT('XMLresponse')

    /********************************* TEST UNITARIO*********************************
       exec sp_sap_utils_XMLresponse hola;
    *********************************************************************************/
end

GO

CREATE   PROCEDURE sp_sap_session_XMLresponse_successful
    @user_id nvarchar(255)
AS
BEGIN
      SET NOCOUNT ON;
    DECLARE @ret int = 0;
    DECLARE @time datetime;
	DECLARE @conn_guid uniqueidentifier;
	SET @conn_guid = (SELECT conn_guid FROM _sap_conn WHERE user_id=@user_id);

    SELECT @ret AS [ret],
           @user_id AS [user_id],
           @conn_guid AS [conn_guid]
	FOR XML PATH(''), ROOT('XMLresponse');
    /********************************* TEST UNITARIO*********************************
      exec sp_sap_user_login "marc@gmail.com","mac"
    *********************************************************************************/
END

GO

CREATE   procedure sp_sap_conn_create
    @user_id nvarchar(255)
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @ret int = 0;
    DECLARE @time datetime;
	DECLARE @conn_guid uniqueidentifier;

    SET @time = GETDATE()
    insert into _sap_conn (user_id, cTime,last_batch)
    values (@user_id, @time,@time)

	SET @conn_guid = (SELECT conn_guid FROM _sap_conn WHERE user_id = @user_id);

    SELECT @ret AS [ret],
           @user_id AS [user_id],
           @time AS [cTime],
           @time AS [last_batch],
           @conn_guid AS [conn_guid]
	FOR XML PATH(''), ROOT('XMLresponse');
    /********************************* TEST UNITARIO*********************************
      exec sp_sap_user_login "marc@gmail.com","mac"
    *********************************************************************************/
END

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
   
END

GO




CREATE PROCEDURE sp_sap_conn_purgue
AS
BEGIN
DELETE FROM _sap_conn where  DATEDIFF(second,last_batch,GETDATE()) > 10*60; 
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
END

GO

CREATE   PROCEDURE sp_sap_session_XMLresponse
    @user_id nvarchar(255)
AS
BEGIN
   SELECT [user].user_name, conn.conn_guid, CONVERT(int, 0) AS [ret]
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

