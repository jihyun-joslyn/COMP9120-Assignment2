CREATE or REPLACE FUNCTION fnStaffCheckStaffCredentials (userName VARCHAR, userPwd VARCHAR) 
RETURNS TABLE (
    Result VARCHAR(30)
)
LANGUAGE PLPGSQL 
AS $$
DECLARE loginName VARCHAR;
        loginPassword VARCHAR;
BEGIN
    DROP TABLE IF EXISTS Result;

    CREATE TEMP TABLE Result (
        Result varchar(30)
    );

    IF EXISTS (SELECT 1 
                FROM staff s 
                WHERE s.login = userName 
                LIMIT 1) THEN
        SELECT s.login, s.password INTO loginName, loginPassword 
        FROM staff s 
        WHERE s.login = userName;
    ELSE
        BEGIN
            RAISE NOTICE 'User not exists';

            INSERT INTO Result (Result) VALUES ('User not exists');

            RETURN QUERY (SELECT * FROM Result);
        END;
    END IF;

    IF loginPassword <> userPwd THEN
        BEGIN
            RAISE NOTICE 'Wrong password';

            INSERT INTO Result (Result) VALUES ('Wrong password');
        END;
    ELSE
        INSERT INTO Result (Result) VALUES ('Login Success');
    END IF;

    RETURN QUERY (SELECT * FROM result);
END
$$


--select * from fnStaffCheckStaffCredentials('123', '0123')

--select * from movie
--select * from staff