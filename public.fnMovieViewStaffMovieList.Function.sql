CREATE or REPLACE FUNCTION fnMovieViewStaffMovieList (userName VARCHAR) 
RETURNS TABLE (
    MovieID INT,
    MovieTitle VARCHAR(100),
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
        ReleasedDate DATE,
        Description VARCHAR(500)
    );

    INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Description)
    SELECT m.ID,
            m.Title, 
            m.ReleaseDate, 
            m.Description 
    FROM Movie m 
    WHERE m.ManagedBy = userName;

    RETURN QUERY (SELECT r.MovieID, 
                            r.MovieTitle, 
                            r.ReleasedDate, 
                            r.Description 
                    FROM Result r 
                    ORDER BY r.ReleasedDate DESC, 
                        r.Description ASC, 
                        r.MovieTitle DESC);
END
$$


--select * from movie
--select * from fnMovieViewStaffMovieList('jdavis')
