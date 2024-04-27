#-	1)What are the different tables in the database and how are they connected to each other in the database?
-- ANS- The database likely includes tables for movies, genres, director mappings, role mappings, names, and ratings. These tables are interconnected through foreign key relationships, where the movies table acts as the central entity. Other tables link to the movies table using foreign keys to establish relationships based on movie IDs.

#-  2)Find the total number of rows in each table of the schema.
-- Number of rows for the table 'movie'
SELECT COUNT(*) AS Total_Rows_count
FROM movies;

-- Number of rows for the table 'genre'
SELECT COUNT(*) AS Total_Rows_count
FROM genre;

-- Number of rows for the table 'director_mapping'
SELECT COUNT(*) AS Total_Rows_count
FROM director_mapping;

-- Number of rows for the table 'role_mapping'
SELECT COUNT(*) AS Total_Rows_count
FROM role_mapping;

-- Number of rows for the table 'names'
SELECT COUNT(*) AS Total_Rows_count
FROM names;

-- Number of rows for the table 'ratings'
SELECT COUNT(*) AS Total_Rows_count
FROM ratings;

# 3)Identify which columns in the movie table have null values.
SELECT 
      SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) AS ID_NULL,
      SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_NULL,
      SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_NULL,
      SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_NULL,
      SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_NULL,
      SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_NULL,
      SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worlwide_gross_income_NULL,
      SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_NULL,
      SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_NULL
      
FROM movies;
# 

# 4.1)Determine the total number of movies released?
SELECT year, COUNT(DISTINCT id) as Number_of_movies
FROM movies
GROUP BY year
ORDER BY year;

# 4.2)Analyse the month-wise trend?
SELECT month(date_published) as month_num, COUNT(DISTINCT id) as Number_of_movies
FROM movies
GROUP BY month_num
ORDER BY month_num; 

# 5)Calculate the number of movies produced in the USA or India in the year 2019.
SELECT COUNT(id) AS number_of_movies, year 
FROM movies
WHERE country = 'USA' OR country = 'India'
GROUP BY country
HAVING year = 2019;

# 6)Retrieve the unique list of genres present in the dataset.
SELECT DISTINCT genre
FROM genre
ORDER BY genre;

# 7)Identify the genre with the highest number of movies produced overall.
SELECT genre,COUNT(id) as movie_count
FROM genre as g
INNER JOIN movies as m
ON g.movie_id = m.id
WHERE year = 2019
GROUP BY genre
ORDER BY movie_count DESC
LIMIT 1;

# 8)Determine the count of movies that belong to only one genre.
SELECT COUNT(movie_id) as Total_movies_with_1_genre
FROM
(
SELECT movie_id,COUNT(genre) as genre_count
FROM genre
GROUP BY movie_id
HAVING genre_count = 1) As genre_count;

# 9)Calculate the average duration of movies in each genre.
SELECT DISTINCT genre,
       ROUND(avg(duration),2) as avg_duration
FROM genre as g
INNER JOIN movies as m
ON m.id = g.movie_id
GROUP BY genre
ORDER BY avg_duration DESC;

# 10)Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
WITH genre_wise_moviecount AS
(
SELECT DISTINCT g.genre,COUNT(m.id) as movie_count
FROM genre as g
INNER JOIN movies as m
ON g.movie_id = m.id
GROUP BY genre
),
genre_ranks as
(
SELECT genre,movie_count,
       RANK() OVER(ORDER BY movie_count DESC) as genre_rank
FROM genre_wise_moviecount
)
SELECT * FROM genre_ranks
WHERE genre = 'thriller';

# 11)Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
SELECT ROUND(MIN(avg_rating),0) AS min_avg_rating,
       ROUND(MAX(avg_rating),0) AS max_avg_rating,
       MIN(total_votes) AS min_total_votes,
       MAX(total_votes) AS max_total_votes,
       MIN(median_rating) AS min_median_rating,
       MAX(median_rating) AS max_median_rating
FROM ratings;

# 12)Identify the top 10 movies based on average rating.
SELECT m.title, r.avg_rating,
       DENSE_RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM ratings as r
INNER JOIN movies as m
ON r.movie_id = m.id
LIMIT 10;

# 13)Summarise the ratings table based on movie counts by median ratings.
SELECT median_rating,COUNT(movie_id) As movie_count
FROM ratings
GROUP 
BY median_rating
ORDER BY movie_count DESC;

# 14)Identify the production house that has produced the most number of hit movies (average rating > 8).
SELECT m.production_company, COUNT(*) AS num_of_hits
FROM movies m
JOIN ratings r ON m.id = r.movie_id
WHERE r.avg_rating > 8
GROUP BY m.production_company
ORDER BY num_of_hits DESC
LIMIT 1;

# 15)Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
SELECT genre, COUNT(id) as movie_count
FROM genre as g
INNER JOIN movies as m
ON m.id = g.movie_id
INNER JOIN ratings as r
ON r.movie_id = m.id
WHERE r.total_votes > 1000 AND country = 'USA' AND year = 2017 AND month(date_published) = 03
GROUP BY genre
ORDER BY movie_count DESC;	

# 16)Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.
SELECT title,avg_rating,genre
FROM movies as m
INNER JOIN ratings as r
ON m.id = r.movie_id
INNER JOIN genre as g
ON g.movie_id = m.id
WHERE title LIKE "The%" AND avg_rating > 8
ORDER BY avg_rating DESC;

# 17)Identify the columns in the names table that have null values
SELECT 
		SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, 
		SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
		SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
		SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
		
FROM names;

# 18)Determine the top three directors in the top three genres with movies having an average rating > 8.
WITH top_genres AS (
    SELECT genre, COUNT(*) AS num_of_movies
    FROM genre
    GROUP BY genre
    ORDER BY num_of_movies DESC
    LIMIT 3
),
top_directors AS (
    SELECT name, COUNT(*) AS num_of_movies
    FROM names
    JOIN ratings ON id = ratings.movie_id
    WHERE ratings.avg_rating > 8
    GROUP BY name
    ORDER BY num_of_movies DESC
    LIMIT 3
)
SELECT tg.genre, td.name, td.num_of_movies
FROM top_genres tg
JOIN top_directors td ON 1=1 -- Cartesian product to combine all top genres with all top directors
ORDER BY tg.num_of_movies DESC, td.num_of_movies DESC;

# 19)Find the top two actors whose movies have a median rating >= 8.
SELECT actor_name, COUNT(movie_id) as movie_count
FROM (
    SELECT n.name AS actor_name, 
           r.movie_id,
           AVG(r.avg_rating) AS median_rating
    FROM names AS n
    INNER JOIN role_mapping AS rm ON n.id = rm.name_id
    INNER JOIN ratings AS r ON rm.movie_id = r.movie_id
    WHERE rm.category = 'actor'
    GROUP BY n.name, r.movie_id
) AS actor_movie_ratings
WHERE median_rating >= 8
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;

# 20)Identify the top three production houses based on the number of votes received by their movies.
SELECT production_company, SUM(total_votes) AS vote_count,
		DENSE_RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movies AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
GROUP BY production_company
LIMIT 3;

# 21)Rank actors based on their average ratings in Indian movies released in India.
SELECT category, AVG(avg_rating) AS avg_rating
FROM role_mapping
JOIN movies ON role_mapping.movie_id = movies.id
JOIN ratings ON movies.id = ratings.movie_id
WHERE movies.country = 'India'
GROUP BY category
ORDER BY avg_rating DESC;

# 22)Identify the top five actresses in Hindi movies released in India based on their average ratings.
 select rm.movie_id,rm.name_id,r.avg_rating, rm.category , m.country, m.languages from role_mapping as rm
  join ratings as r
  on rm.movie_id = r.movie_id
  join names as n
  on rm.name_id = n.id
 join movies as m
  on r.movie_id = m.id
 where rm.category = 'actress' and m.country= 'India' and m.languages= 'hindi'
   order by r.avg_rating desc
   limit 5;

# 23)Classify thriller movies based on average ratings into different categories.
SELECT title,avg_rating,
       CASE WHEN avg_rating>8 THEN 'Superhit'
            WHEN avg_rating BETWEEN 7 and 8 THEN 'Hit'
            WHEN avg_rating BETWEEN 5 and 7 THEN 'One-time-watch'
            ELSE 'flop'
            END AS rating_category
FROM movies as m
INNER JOIN genre as g
ON g.movie_id = m.id
INNER JOIN ratings as r
ON r.movie_id = g.movie_id
WHERE genre = 'thriller';

# 24)analyse the genre-wise running total and moving average of the average movie duration.
SELECT genre, 
       ROUND(AVG(duration),2) AS avg_duration,
       SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
       AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) AS moving_avg_duration
FROM genre as g
INNER JOIN movies as m
ON m.id = g.movie_id
GROUP BY genre
ORDER BY genre;

# 25)Identify the five highest-grossing movies of each year that belong to the top three genres.
WITH top_3_genre AS
( 	
	SELECT genre, COUNT(movie_id) AS number_of_movies
    FROM genre AS g
    INNER JOIN movies AS m
    ON g.movie_id = m.id
    GROUP BY genre
    ORDER BY COUNT(movie_id) DESC
    LIMIT 3
),

top_5 AS
(
	SELECT genre,
			year,
			title AS movie_name,
			worlwide_gross_income,
			DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
        
	FROM movies AS m 
    INNER JOIN genre AS g 
    ON m.id= g.movie_id
	WHERE genre IN (SELECT genre FROM top_3_genre)
)

SELECT *
FROM top_5
WHERE movie_rank<=5;

# 26)Determine the top two production houses that have produced the highest number of hits among multilingual movies.
SELECT production_company,
		COUNT(m.id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY count(id) DESC) AS prod_comp_rank
FROM ratings AS r 
INNER JOIN movies AS m 
ON m.id=r.movie_id
GROUP BY production_company
LIMIT 2;

# 27)Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.
SELECT name as actress_name,
       SUM(total_votes) AS total_votes,
       COUNT(r.movie_id) as movie_count,
       AVG(avg_rating) as actress_avg_rating,
       DENSE_RANK() OVER(ORDER BY AVG(avg_rating) DESC) AS actress_rank
FROM names as n
INNER JOIN role_mapping as rm
ON n.id = rm.name_id
INNER JOIN ratings as r
ON rm.movie_id = r.movie_id
INNER JOIN genre as g
ON g.movie_id = r.movie_id
WHERE category = 'actress' AND genre = 'Drama'
GROUP BY actress_name
HAVING actress_avg_rating > 8
ORDER BY actress_rank
LIMIT 3;

# 28)Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.
WITH movie_date_info AS (
    SELECT d.name_id, n.name, d.movie_id,
           m.date_published, 
           LEAD(date_published, 1) OVER(PARTITION BY d.name_id ORDER BY date_published) AS next_movie_date
    FROM director_mapping d
    JOIN names AS n ON d.name_id = n.id 
    JOIN movies AS m ON d.movie_id = m.id
),

date_difference AS (
    SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
    FROM movie_date_info
),

avg_inter_days AS (
    SELECT name_id, AVG(diff) AS avg_inter_movie_days
    FROM date_difference
    GROUP BY name_id
),

director_details AS (
    SELECT d.name_id AS director_id,
           n.name AS director_name,
           COUNT(d.movie_id) AS number_of_movies,
           ROUND(avg_inter_movie_days) AS inter_movie_days,
           ROUND(AVG(r.avg_rating), 2) AS avg_rating,
           SUM(r.total_votes) AS total_votes,
           MIN(r.avg_rating) AS min_rating,
           MAX(r.avg_rating) AS max_rating,
           SUM(m.duration) AS total_duration
    FROM names AS n 
    JOIN director_mapping AS d ON n.id = d.name_id
    JOIN ratings AS r ON d.movie_id = r.movie_id
    JOIN movies AS m ON m.id = r.movie_id
    JOIN avg_inter_days AS a ON a.name_id = d.name_id
    GROUP BY director_id, director_name
    ORDER BY COUNT(d.movie_id) DESC
)
SELECT director_id,
       director_name,
       number_of_movies,
       inter_movie_days,
       avg_rating,
       total_votes,
       min_rating,
       max_rating,
       total_duration	
FROM director_details
LIMIT 9;
