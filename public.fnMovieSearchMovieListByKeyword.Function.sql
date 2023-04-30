CREATE or REPLACE FUNCTION fnMovieSearchMovieListByKeyword (searchKeyword varchar, userName varchar) 
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

    if (searchKeyword = COALESCE(searchKeyword, '')) then 
        BEGIN
            insert into Result(MovieID, MovieTitle, ReleasedDate, Description)
            select * from Movie m where m.Ma
        END
    end if;

    select lower(searchKeyword) into searchKeyword;
    
    INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Description)
    SELECT m.ID,
            m.Title, 
            m.ReleaseDate, 
            m.Description 
    FROM Movie m 
    WHERE lower(m.Title) like ('%' || searchKeyword || '%');

    INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Description)
    SELECT m.ID,
            m.Title, 
            m.ReleaseDate, 
            m.Description 
    FROM Movie m 
    WHERE lower(m.Description) like ('%' || searchKeyword || '%');

    INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Description)
    SELECT m.ID,
            m.Title, 
            m.ReleaseDate, 
            m.Description 
    FROM Movie m 
    WHERE exists (select 1 from Genre g where (m.PrimaryGenre = g.GenreId or m.SecondaryGenre = g.GenreID) and lower(g.GenreName) like ('%' || searchKeyword || '%') limit 1);

    INSERT INTO Result (MovieID, MovieTitle, ReleasedDate, Description)
    SELECT m.ID,
            m.Title, 
            m.ReleaseDate, 
            m.Description 
    FROM Movie m 
    WHERE exists (select 1 from Staff s where s.Login = m.ManagedBy and (lower(s.FirstName) like ('%' || searchKeyword || '%') or lower(s.LastName) like ('%' || searchKeyword || '%')) limit 1);

    RETURN query (SELECT r.MovieID, 
                            r.MovieTitle, 
                            r.ReleasedDate, 
                            r.Description 
                    FROM Result r 
                    ORDER BY r.ReleasedDate DESC, 
                        r.Description ASC, 
                        r.MovieTitle DESC);
END
$$


--select * from movie; select * from staff; select * from genre
--select * from fnMovieSearchMovieListByKeyword('iron')

--select * from movie where title like '%iron%'