USE WS_API_07;

DROP TABLE _sap_users;

create table _sap_users
(
    user_id   nvarchar(255) not null
        primary key,
    nickname  nvarchar(255),
    user_name nvarchar(255) not null,
    surname   nvarchar(255),
    pwd       varbinary(255) not null,
    phone     nvarchar(255),
    _mndt     int              default 0,
    _created  datetime         default getdate(),
    _updated  datetime,
    _deleted  datetime,
    _row_guid uniqueidentifier default newid()
)
go

-- DROP TABLE IF EXISTS _sap_errors;

-- CREATE TABLE _sap_errors(
--     id INT IDENTITY (1,1) PRIMARY KEY,
--     numError VARCHAR(30) not null,
--     messageError VARCHAR(30) not null,
--     severity VARCHAR(30) not null,
--     userMessage VARCHAR(30) not null,
--     _mndt integer default 0,
--     _created datetime default getdate(),
--     _updated datetime,
--     _deleted datetime,
--     _row_guid UNIQUEIDENTIFIER DEFAULT NEWID()
-- );

-- DROP TABLE IF EXISTS _sap_log;

-- CREATE TABLE _sap_log(
--     _sapId INT IDENTITY (1,1) PRIMARY KEY,
--     _sapGuid UNIQUEIDENTIFIER DEFAULT NEWID(),
--     userIp INIT PRIMARY KEY,
--     idioma  VARCHAR(30),
--     _mndt integer default 0,
--     _created datetime default getdate(),
--     _updated datetime,
--     _deleted datetime,
--     _row_guid UNIQUEIDENTIFIER DEFAULT NEWID()

-- );

DROP TABLE IF EXISTS _sap_conn;


 create table _sap_conn
(
    conn_guid uniqueidentifier default newid() not null,
    user_id   nvarchar(255) primary key constraint _sap_conn__sap_users_user_id_fk references _sap_users,
    cTime     datetime,
    _mndt     int              default 0,
    _created  datetime         default getdate(),
    _updated  datetime,
    _deleted  datetime,
    _row_guid uniqueidentifier default newid()
)
go

SELECT * from _sap_users;