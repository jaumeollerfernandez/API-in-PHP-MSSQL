-- CREATE OR ALTER function  sf_sap_user_validate_pwd(@user_id nvarchar(255),@pwd nvarchar(255))
-- RETURNS INT
-- as
-- begin
-- DECLARE @response int;
-- DECLARE @pwd_encrypted varbinary(255);
-- SET @response = 0;
-- SET @pwd_encrypted = (SELECT pwd from _sap_users where user_id = @user_id);


-- IF (PWDENCRYPT(@pwd) = @pwd_encrypted)
--     SET @response = 1;
-- ELSE
--     SET @response = 0;

-- -- IF ( (SELECT count(*) from _sap_users where user_id = @user_id and pwd = @pwd) = 1)
-- --     SET @response = 1;

-- RETURN @response

-- /********************************* TEST UNITARIO*********************************
-- DECLARE @ret INT;
-- EXEC @ret = sf_sap_user_validate_pwd @user_id = 'ely@gmail.com' @pwd = 'comeme los kinders' ;
-- select @ret;
-- *********************************************************************************/

-- end
-- go

CREATE OR ALTER FUNCTION sf_sap_user_validate_pwd(@user_id nvarchar(255),
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
