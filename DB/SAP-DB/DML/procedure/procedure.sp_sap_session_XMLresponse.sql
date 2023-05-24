CREATE OR ALTER PROCEDURE sp_sap_session_XMLresponse
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
go