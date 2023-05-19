CREATE function sf_sap_user_exists(@user_id nvarchar(255))
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

/********************************* TEST UNITARIO*********************************
DECLARE @ret INT;
EXEC @ret = sf_if_exist_user @user_id = 'ely@gmail.com' ;
select @ret;
*********************************************************************************/
END
go