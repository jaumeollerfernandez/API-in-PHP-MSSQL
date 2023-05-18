CREATE PROCEDURE sp_sap_conn_purgue
AS
BEGIN
DELETE FROM _sap_conn where  DATEDIFF(second,last_batch,GETDATE()) > 10*60; 
/************************************************TEST UNITARIO***********************************************/
/*
select DATEDIFF(minute,last_batch,GETDATE()),* from _sap_conn

BEGIN tran
DELETE FROM _sap_conn where  DATEDIFF(minute,last_batch,GETDATE()) > 3; 
rollback
                                                                                                                           */
/****************************************************************************************************************************/
END
go