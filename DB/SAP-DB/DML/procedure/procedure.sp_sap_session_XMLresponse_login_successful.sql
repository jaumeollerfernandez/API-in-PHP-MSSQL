CREATE PROCEDURE sp_sap_session_XMLresponse_login_successful
    @user_id nvarchar(255)
AS
BEGIN
   SELECT [user].user_name, conn.conn_guid, CONVERT(int, 0) AS [error]
   FROM _sap_conn [user]
       where [user].user_id = @user_id 
   FOR XML PATH('WSresponse'), ELEMENTS, ROOT('XMLresponse')
END
   /********************************* TEST UNITARIO*********************************
         exec sp_sap_session_XMLresponse "u1@gmail.com"
    *********************************************************************************/
go