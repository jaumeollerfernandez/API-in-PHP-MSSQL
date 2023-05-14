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
