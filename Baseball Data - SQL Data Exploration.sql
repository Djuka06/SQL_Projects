/*

In this project I wanted to explore Lahman's Baseball Database and for that I used the following SQL commands:

- Basic Clauses (SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY)
- Modifiers (TOP, DISTINCT)
- Aggregations (COUNT, AVG, MIN, MAX, SUM)
- Joins (INNER, LEFT)
- Subquerie
- View

*/


-- Select all columns from People table

SELECT *  
FROM [BaseballProject].[dbo].[People]



-- Select top 1000 rows from People table

SELECT TOP (1000) [playerID]
      ,[birthYear]
      ,[birthMonth]
      ,[birthDay]
      ,[birthCountry]
      ,[birthState]
      ,[birthCity]
      ,[deathYear]
      ,[deathMonth]
      ,[deathDay]
      ,[deathCountry]
      ,[deathState]
      ,[deathCity]
      ,[nameFirst]
      ,[nameLast]
      ,[nameGiven]
      ,[weight]
      ,[height]
      ,[bats]
      ,[throws]
      ,[debut]
      ,[finalGame]
      ,[retroID]
      ,[bbrefID]
  FROM [BaseballProject].[dbo].[People]



-- Show all players ID, birthday, first name and last name from People table

SELECT playerID, birthYear, nameFirst, nameLast
FROM [BaseballProject].[dbo].[People]



-- Select all players who were born after 1990 and in USA

SELECT *
FROM [BaseballProject].[dbo].[People]
WHERE birthYear >= 1990 AND birthCountry = 'USA'



-- Select unique cities where players were born 

SELECT DISTINCT birthCity
FROM [BaseballProject].[dbo].[People]



-- How average weight of player has changed over time, group by birthYear in ascending order

SELECT birthYear, AVG(weight) as avg_weight
FROM [BaseballProject].[dbo].[People]
GROUP BY birthYear
ORDER BY birthYear ASC



-- On the above query add HAVING clause (count total number of weight >= 100)

SELECT birthYear, AVG(weight) as avg_weight, COUNT(weight) as weight_cnt
FROM [BaseballProject].[dbo].[People]
GROUP BY birthYear
HAVING COUNT(weight) >= 100
ORDER BY birthYear ASC



-- Join (INNER) two tables (Batting and People) on playerID

SELECT *
FROM dbo.Batting as bat
INNER JOIN dbo.People as peop
ON bat.playerID = peop.playerID



-- Show all players who had At Bats > 100

SELECT bat.*, peop.nameFirst, peop.nameLast
FROM dbo.Batting as bat
INNER JOIN dbo.People as peop
ON bat.playerID = peop.playerID
WHERE AB > 100



-- Join (LEFT) two tables (Batting and Pitching) on playerID and yearID

SELECT *
FROM dbo.Batting as bat
LEFT JOIN dbo.Pitching as pitch
ON bat.playerID = pitch.playerID AND bat.yearID = pitch.yearID



-- Subquery (Figure out which Pitcher had over 10 wins, also had over 40 At Bats)

SELECT bat.*, pitch.*
FROM dbo.Batting as bat
INNER JOIN (SELECT *
            FROM dbo.Pitching
			WHERE W > 10) as pitch
ON bat.playerID = pitch.playerID AND bat.yearID = pitch.yearID
WHERE AB >= 40



-- Create a View

CREATE VIEW WinningPitchers
AS
SELECT bat.*, pitch.W
FROM dbo.Batting as bat
INNER JOIN (SELECT *
            FROM dbo.Pitching
			WHERE W > 10) as pitch
ON bat.playerID = pitch.playerID AND bat.yearID = pitch.yearID
WHERE AB >= 40


