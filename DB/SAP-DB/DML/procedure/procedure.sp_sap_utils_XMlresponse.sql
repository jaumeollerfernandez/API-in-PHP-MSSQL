create procedure sp_sap_utils_XMlresponse
    @error nvarchar(255),@message nvarchar(255) 
AS
BEGIN
    SELECT @error AS 'error', @message AS 'message' FOR XML PATH(''), ROOT('XMLresponse')

    /********************************* TEST UNITARIO*********************************
       exec sp_sap_utils_XMLresponse hola;
    *********************************************************************************/
end
go