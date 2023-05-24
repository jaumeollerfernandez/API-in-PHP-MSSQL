create procedure sp_sap_utils_XMlresponse
    @error nvarchar(255),@message nvarchar(255) 
AS
BEGIN
    SELECT @error AS 'ret', @message AS 'message' FOR XML PATH(''), ROOT('XMLresponse')
end
go