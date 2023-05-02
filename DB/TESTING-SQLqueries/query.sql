ALTER PROCEDURE f_table_name
AS
BEGIN
    SELECT *
    FROM road_segments
	FOR XML RAW, root('roads');
END

DROP PROCEDURE f_table_name


-- ///////////////

use gisdb

CREATE TABLE users(
	id INT NOT NULL PRIMARY KEY,
	username VARCHAR(50) NOT NULL,
	password VARCHAR(50) NOT NULL
);


INSERT INTO users(id, username, password)
VALUES (1, 'alice', 'mypassword'),
       (2, 'bob', 'letmein'),
       (3, 'charlie', 'password123');


SELECT * FROM USERS;





CREATE OR ALTER PROCEDURE login_user @user VARCHAR(50), @password VARCHAR(50), @dummy VARCHAR(20)="DS" OUTPUT
AS 
BEGIN
	/*
	DECLARE @RET INT
	DECLARE @P VARCHAR(50)
	DECLARE @dummy VARCHAR(50)
	EXEC @RET=login_user  'alice','mypassword', @dummy OUTPUT
	PRINT @RET

	*/
	DECLARE @user_id INT;

	SET @dummy = 'test'

	SELECT @user_id = id FROM USERS WHERE username = @user AND password = @password

	IF @user_id IS NOT NULL
	BEGIN 
		SELECT 'Login Succes' AS message,@dummy dummy, @user_id AS user_id, @user, @password FOR XML RAW, root('userController');
		return 0;
	END
	ELSE
	BEGIN
		SELECT 'Invalid login or password' AS message, NULL AS user_id, @user, @password FOR XML RAW, root('userController');
		return -1;
	END
END



	


call @dummy

EXEC login_user @user = 'alice', @password = 'mypassword';