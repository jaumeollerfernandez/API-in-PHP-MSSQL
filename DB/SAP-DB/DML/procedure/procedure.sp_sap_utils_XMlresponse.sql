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