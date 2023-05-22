CREATE procedure sp_sap_conn_create
    @user_id nvarchar(255)
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @ret int = 1;
    DECLARE @time datetime;
	DECLARE @conn_guid uniqueidentifier;

    SET @time = GETDATE()
    insert into _sap_conn (user_id, cTime,last_batch)
    values (@user_id, @time,@time)

	SET @conn_guid = (SELECT conn_guid FROM _sap_conn WHERE user_id = @user_id);

    SELECT @ret AS [ret],
           @user_id AS [user_id],
           @time AS [cTime],
           @time AS [last_batch],
           @conn_guid AS [conn_guid]
	FOR XML PATH(''), ROOT('XMLresponse');
    /********************************* TEST UNITARIO*********************************
      exec sp_sap_user_login "marc@gmail.com","mac"
    *********************************************************************************/
END
go