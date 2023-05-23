CREATE OR ALTER FUNCTION sf_conn_validate_cid(@cid nvarchar(255))
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
GO;