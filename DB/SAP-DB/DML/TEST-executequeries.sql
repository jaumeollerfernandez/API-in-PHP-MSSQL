SELECT * FROM sysobjects where xtype='fn';

SELECT * from _sap_users;

SELECT * from _sap_conn;

--remove user from _sap_conn
DELETE FROM _sap_conn WHERE user_id = 'Chouso';