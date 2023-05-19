CREATE PROCEDURE sp_sap_session_XMLresponse_successful
    @user_id nvarchar(255)
AS
BEGIN
      SET NOCOUNT ON;
    DECLARE @ret int = 1;
    DECLARE @time datetime;
	DECLARE @conn_guid uniqueidentifier;
	SET @conn_guid = (SELECT conn_guid FROM _sap_conn WHERE user_id=@user_id);

    SELECT @ret AS [ret],
           @user_id AS [user_id],
           @conn_guid AS [conn_guid]
	FOR XML PATH('sp_sap_conn_create'), ROOT('XMLresponse');
    /********************************* TEST UNITARIO*********************************
      exec sp_sap_user_login "marc@gmail.com","mac"
    *********************************************************************************/
END
go