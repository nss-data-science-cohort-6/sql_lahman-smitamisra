--1. Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
-- select *
-- from schools
-- Where schoolname like 'Vanderbilt%'

-- SELECT 
-- 	namefirst, namelast, schoolname, 
-- 	COALESCE(SUM(salary), 0) AS total_salary$
-- FROM people 
-- INNER JOIN salaries
-- USING (playerid)
-- INNER JOIN collegeplaying
-- USING(playerid)
-- INNER JOIN schools
-- USING(schoolid)
-- Where schoolname like 'Vanderbilt%'
-- GROUP BY namefirst, namelast, schoolname --this adds the rows multiple times so it needs to be rewriten with distinct
-- ORDER BY total_salary$ DESC;
--The top query was wrong because it gave values three times becuase of grouping function.

----
SELECT namefirst, namelast,
	SUM(salary)::numeric::money AS total_salary,
	COUNT(DISTINCT yearid) AS years_played
	FROM people
	INNER JOIN salaries
	USING(playerid)
	WHERE playerid IN (
		SELECT 
		playerid
		FROM collegeplaying
		LEFT JOIN schools
		USING(schoolid)
		WHERE schoolid = 'vandy'
	)
	GROUP BY playerid, namefirst, namelast
	ORDER BY total_salary DESC;
-----
-- WITH earnings AS(
-- 	SELECT playerid,
-- 		SUM(salary) as big_league_pay 
-- 	FROM salaries
-- 	GROUP BY playerid),
-- vandy AS(
-- 	SELECT DISTINCT(playerid)
-- 	FROM collegeplaying
-- 	WHERE schoolid = 'vandy')
-- SELECT playerid, p.namelast, p.namefirst, big_league_pay 
-- FROM people as p
-- INNER JOIN vandy
-- USING(playerid)
-- LEFT JOIN earnings
-- USING(playerid)
-- ORDER BY big_league_pay DESC;

---
WITH vandy_players AS (
						SELECT DISTINCT playerid
						FROM collegeplaying 
							LEFT JOIN schools
							USING(schoolid)
						WHERE schoolid = 'vandy'
)
SELECT namefirst, 
	   namelast, 
	   SUM(salary)::numeric::money AS total_salary, 
	   COUNT(DISTINCT yearid) AS years_played
FROM people
	 INNER JOIN vandy_players
	 USING(playerid)
	 INNER JOIN salaries
	 USING(playerid)
GROUP BY playerid, namefirst, namelast
ORDER BY total_salary DESC;

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

-----using the IN key word-----
SELECT(
	CASE
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('C', 'P') THEN 'Battery'
		ELSE 'neither'
		END) AS position,
		COALESCE(SUM(po), 0) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position
ORDER by total_putouts DESC;
--Total putout for each position are -- "Infield"	58934, -- "Battery"	41424, -- "Outfield"	29560

--Q3Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

-- select *
-- FROM pitching

-- select DISTINCT yearid
-- FROM pitching
-- ORDER BY yearid DESC;
--The pitching table spans over 146 years from 1871 to 2016.

--we need to create the decade series and then join
WITH decade AS (SELECT 
generate_series (1920, 2016, 10) AS decade_group)
	SELECT decade_group,
	COALESCE(ROUND (SUM(g), 2), 0) as sum_game,
	COALESCE(ROUND (SUM(so), 2), 0) as sum_strikeout,
	COALESCE(ROUND (SUM(hr), 2), 0) as sum_homerun,
	COALESCE(ROUND (SUM(so)*1.0/SUM(g), 2), 0) as AvgSO_game,
	COALESCE(ROUND (SUM(hr)*1.0/SUM(g), 2), 0) as AvgHR_game
	FROM pitching
	INNER JOIN decade
		ON decade_group+1 <= yearid 
		AND decade_group+10 >= yearid
		WHERE yearid >= 1920
		GROUP BY decade_group
	ORDER BY decade_group ASC;
	
--Q4Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases. Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.

