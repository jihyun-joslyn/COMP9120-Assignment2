CREATE or REPLACE FUNCTION fnMovieSearchMovieListByKeyword (searchKeyword VARCHAR, userName VARCHAR) 
RETURNS TABLE (
    MovieID INT,
    MovieTitle VARCHAR(100),
    Genre VARCHAR(100),
    Rating VARCHAR(5),
    ReleasedDate DATE,
    Description VARCHAR(500)
)
LANGUAGE PLPGSQL 
AS $$
BEGIN
    DROP TABLE IF EXISTS Result;

    CREATE TEMP TABLE Result (
        MovieID INT,
        MovieTitle VARCHAR(100),
        Genre VARCHAR(100),
        Rating VARCHAR(5),
        ReleasedDate DATE,
        Description VARCHAR(500)
    );

    IF (searchKeyword = COALESCE(searchKeyword, '')) THEN 
        BEGIN
            INSERT INTO Result(MovieID, MovieTitle, ReleasedDate, Rating, Description)
            SELECT m.ID, 
                m.Title, 
                m.ReleaseDate, 
                CAST(m.AVGRating AS VARCHAR(5)), 
                m.Description 
            FROM Movie m 
            WHERE m.ManagedBy =  userName;
        END;
    ELSE
        BEGIN
            SELECT LOWER(searchKeyword) INTO searchKeyword;
    
            INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Rating, Description)
            SELECT m.ID,
                    m.Title, 
                    m.ReleaseDate, 
                    CAST(m.AVGRating AS VARCHAR(5)),
                    m.Description 
            FROM Movie m 
            WHERE LOWER(m.Title) LIKE ('%' || searchKeyword || '%');

            INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Rating, Description)
            SELECT m.ID,
                m.Title, 
                m.ReleaseDate, 
                CAST(m.AVGRating AS VARCHAR(5)),
                m.Description 
            FROM Movie m 
            WHERE LOWER(m.Description) LIKE ('%' || searchKeyword || '%');

            INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Rating, Description)
            SELECT m.ID,
                    m.Title, 
                    m.ReleaseDate, 
                    CAST(m.AVGRating AS VARCHAR(5)),
                    m.Description 
            FROM Movie m 
            WHERE EXISTS (SELECT 1 
                            FROM Genre g 
                            WHERE (m.PrimaryGenre = g.GenreId 
                                    OR m.SecondaryGenre = g.GenreID) 
                                AND LOWER(g.GenreName) LIKE ('%' || searchKeyword || '%') 
                            LIMIT 1);

            INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Rating, Description)
            SELECT m.ID,
                m.Title, 
                m.ReleaseDate, 
                CAST(m.AVGRating AS VARCHAR(5)),
                m.Description 
            FROM Movie m 
            WHERE EXISTS (SELECT 1 
                            FROM Staff s 
                            WHERE s.Login = m.ManagedBy 
                                AND (LOWER(s.FirstName) LIKE ('%' || searchKeyword || '%') 
                                    OR LOWER(s.LastName) LIKE ('%' || searchKeyword || '%')) 
                            LIMIT 1);

        END;
    END IF;

    UPDATE Result r 
    SET Genre = (SELECT STRING_AGG(g.GenreName, ', ') 
                    FROM Genre g 
                    WHERE m.PrimaryGenre = g.GenreID 
                        OR m.SecondaryGenre = g.GenreID) 
    FROM Movie m 
    WHERE r.MovieID = m.ID;

    RETURN query (SELECT r.MovieID, 
                            r.MovieTitle, 
                            r.Genre, 
                            r.Rating,
                            r.ReleasedDate, 
                            r.Description 
                    FROM Result r 
                    ORDER BY r.ReleasedDate DESC, 
                        r.Description ASC, 
                        r.MovieTitle DESC);
END
$$


--SELECT * FROM movie; SELECT * FROM staff; SELECT * FROM genre
--SELECT * FROM fnMovieSearchMovieListByKeyword('', 'jdavis')

--SELECT * FROM movie WHERE title LIKE '%iron%'

--drop function fnMovieSearchMovieListByKeyword(VARCHAR, VARCHAR)