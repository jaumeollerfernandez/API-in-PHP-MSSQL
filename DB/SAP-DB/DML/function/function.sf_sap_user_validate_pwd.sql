CREATE   function  sf_sap_user_validate_pwd(@user_id nvarchar(255),@pwd nvarchar(255))
RETURNS INT
as
begin
DECLARE @response int;

SET @response = 0;

IF ( (SELECT count(*) from _sap_users where user_id = @user_id and pwd = @pwd) = 1)
    SET @response = 1;

RETURN @response

/********************************* TEST UNITARIO*********************************
DECLARE @ret INT;
EXEC @ret = sf_sap_user_validate_pwd @user_id = 'ely@gmail.com' @pwd = 'comeme los kinders' ;
select @ret;
*********************************************************************************/

end
go