CREATE or ALTER procedure sp_sap_conn_create
    @user_id nvarchar(255)
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @ret int = 1;
    DECLARE @time datetime;


    SET @time = GETDATE()
    insert into _sap_conn (user_id, cTime,last_batch)
    values (@user_id, @time,@time)

    SELECT @ret AS [ret],
           @user_id AS [user_id],
           @time AS [cTime],
           @time AS [last_batch]
    FOR XML PATH('sp_sap_conn_create'), ROOT('XMLresponse');
    /********************************* TEST UNITARIO*********************************
      exec sp_sap_users_login "marc@gmail.com","mac"
    *********************************************************************************/
END
go