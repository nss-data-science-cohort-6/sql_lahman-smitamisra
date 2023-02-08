-- Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- select *
-- from schools
-- Where schoolname like 'Vanderbilt%'

SELECT 
	namefirst, namelast, schoolname, 
	COALESCE(SUM(salary), 0) AS total_salary$
FROM people 
INNER JOIN salaries
USING (playerid)
INNER JOIN collegeplaying
USING(playerid)
INNER JOIN schools
USING(schoolid)
Where schoolname like 'Vanderbilt%'
GROUP BY namefirst, namelast, schoolname
ORDER BY total_salary$ DESC;

--q2.Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- SELECT *
-- FROM fielding
-- LIMIT 5

SELECT 
	(CASE
	 WHEN pos = 'OF' THEN 'Outfield'
	 WHEN pos = 'SS'
	 	OR pos = '1B'
	 	OR pos = '2B'
	 	OR pos = '3B' THEN 'Infield'
	 WHEN pos = 'P'
	 	OR pos= 'C' THEN 'Battery'
	 ELSE 'none'
	END) AS position,
	  COALESCE(SUM(po), 0) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position
ORDER by total_putouts DESC;

--Q3Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

select *
FROM pitching

select DISTICT 

	   