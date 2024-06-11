USE IPL;
-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
SELECT 
    *
FROM
    ipl_bidding_details;
SELECT 
    *
FROM
    ipl_match;
SELECT 
    *
FROM
    ipl_tournament;
with temp as
(select bd.*,case when m.match_winner=1 then m.team_id1 else m.team_id2 end as  winningteam  from ipl_match m
join ipl_match_schedule ms on m.match_id=ms.match_id
join ipl_bidding_details bd on bd.SCHEDULE_ID=ms.SCHEDULE_ID)
select bidder_id,sum(case when winningteam=bid_team then 1 else 0 end)*100/count(bid_team) percentage from temp
group by bidder_id;
-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.
SELECT 
    COUNT(m.match_id), s.stadium_name, s.stadium_id
FROM
    ipl_stadium s
        JOIN
    ipl_match_schedule m ON s.STADIUM_ID = m.STADIUM_ID
GROUP BY s.stadium_name , s.stadium_id;
-- 3.	In a given stadium, what is the percentage of wins by a team that has won the toss?
 
(SELECT 
    m1.match_id, m1.match_winner
FROM
    ipl_match m1
        JOIN
    ipl_match m2 ON m1.match_id = m2.match_id
        AND m1.toss_winner = m2.match_winner);

-- 4.	Show the total bids along with the bid team and team name.
SELECT 
    *
FROM
    ipl_team;
SELECT 
    i.team_name, g.bid_team, COUNT(no_of_bids)
FROM
    ipl_bidder_points r
        JOIN
    ipl_bidding_details g ON r.bidder_id = g.bidder_id
        JOIN
    ipl_team i ON g.bid_team = i.team_id
GROUP BY g.bid_team
;
 -- 5.	Show the team ID who won the match as per the win details
SELECT 
    team_id, team_name
FROM
    ipl_team
WHERE
    EXISTS( SELECT 
            TRIM('w' FROM SUBSTR(win_details, 5, 5))
        FROM
            ipl_match);
-- 6.	Display the total matches played, total matches won and total matches lost by the team along with its team name
SELECT DISTINCT
    s.matches_played, s.matches_won, s.matches_lost, t.team_name
FROM
    ipl_team_standings s
        JOIN
    ipl_team t ON s.team_id = t.team_id;
-- 7.	Display the bowlers for the Mumbai Indians team
SELECT 
    *
FROM
    ipl_PLAYER;
SELECT 
    *
FROM
    IPL_TEAM T
        JOIN
    IPL_TEAM_PLAYERS P ON T.TEAM_ID = P.TEAM_ID
        JOIN
    IPL_PLAYER L ON P.PLAYER_ID = L.PLAYER_ID
WHERE
    P.PLAYER_ROLE = 'BOWLER'
        AND T.TEAM_NAME LIKE '%MUMBAI INDIANS%';
-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 
-- all-rounders in descending order.
SELECT 
    TEAM_ID, COUNT(PLAYER_ROLE)
FROM
    IPL_TEAM_PLAYERS
WHERE
    PLAYER_ROLE = 'ALL-ROUNDER'
GROUP BY TEAM_ID
HAVING COUNT(PLAYER_ROLE) > 4;
-- Write a query to get the total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium bidding year-wise.
--  Note the total bidders’ points in descending order and the year is the bidding year.
              --  Display columns: bidding status, bid date as year, total bidder’s points
SELECT * FROM IPL_STADIUM;
SELECT DISTINCT
    POINTS.TOTAL_POINTS,
    DETAILS.BID_STATUS,
    (SELECT 
            TEAM_NAME
        FROM
            IPL_TEAM
        WHERE
            TEAM_NAME = 'Chennai Super Kings'),
    YEAR(DETAILS.BID_DATE) BID_YEAR
FROM
    IPL_BIDDER_POINTS POINTS
        JOIN
    ipl_bidding_details DETAILS ON POINTS.BIDDER_ID = DETAILS.BIDDER_ID
        JOIN
    IPL_MATCH_SCHEDULE SCHED_ULE ON SCHED_ULE.SCHEDULE_ID = DETAILS.SCHEDULE_ID
        JOIN
    IPL_STADIUM STADIUM ON STADIUM.STADIUM_ID = SCHED_ULE.STADIUM_ID
WHERE
    STADIUM.STADIUM_NAME = 'Wankhede Stadium'
GROUP BY DETAILS.BID_STATUS , POINTS.TOTAL_POINTS , BID_YEAR
ORDER BY BID_YEAR DESC
;
-- 10.	Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
-- Note 
-- 1. Use the performance_dtls column from ipl_player to get the total number of wickets
--  2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3.	Do not use joins in any cases.
-- 4.	Display the following columns teamn_name, player_name, and player_role.
select* from ipl_match;

select t.team_name,team.player_role,player.player_name,cast(substring_index(substring_index(PERFORMANCE_DTLS,'Wkt-',-1),'Dot',1) as unsigned) wickets from ipl_player player
join ipl_team_players team on team.player_id=player.player_id
join ipl_team t on t.TEAM_ID=team.TEAM_ID
order by wickets desc;
-- 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
select * from ipl_bidding_details;
with temp as 
(select bd.BIDDER_ID,bd.BID_TEAM,
 case when toss_winner =1 then team_id1 else team_id2 end as toss_winning_team 
 FROM  ipl_bidding_details bd JOIN ipl_match_schedule MS ON MS.SCHEDULE_ID=bd.SCHEDULE_ID
 join ipl_match m on m.MATCH_ID=ms.MATCH_ID)
 select bidder_id,round(sum(case when toss_winning_team=bid_team then 1 else 0 end)*100/count(bidder_id),2) percentage_tosswin from temp 
 group by bidder_id
 order by percentage_tosswin desc;
 -- 12.	find the IPL season which has a duration and max duration.
-- Output columns should be like the below:
 -- Tournment_ID, Tourment_name, Duration column, Duration
 select * from ipl_tournament;
 select TOURNMT_ID,TOURNMT_NAME,datediff(TO_DATE,FROM_DATE) duration from ipl_tournament
 
 order by duration desc;
 -- 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year.
 -- sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. Bid date as Year, 4. Bid date as Month, 5. Total points
-- Only use joins for the above query queries
select* from ipl_bidder_points;
select bidder.bidder_name,bd.BIDDER_ID,bp.TOTAL_POINTS,extract(month from bd.BID_DATE)mon_th from ipl_bidding_details bd 
join ipl_bidder_points bp on bd.BIDDER_ID=bp.BIDDER_ID
join ipl_bidder_details bidder on bidder.BIDDER_ID=bd.BIDDER_ID
where extract(year from bd.BID_DATE)=2017
group by mon_th,bidder.bidder_name,bd.BIDDER_ID,bp.TOTAL_POINTS
order by bp.TOTAL_POINTS desc , mon_th ;
 -- 14.	Write a query for the above question using sub-queries by having the same constraints as the above question
-- 	Write a query to display to calculate the total points month-wise for the 2017 bid year.
 -- sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns: 
SELECT 
    BIDDER_NAME,
    (SELECT 
            total_points
        FROM
            ipl_bidder_points bp
        where bp.bidder_id=bd.bidder_id
        ORDER BY total_points DESC),
    (SELECT 
            bidder_id
        FROM
            ipl_bidding_details
        WHERE
            EXTRACT(YEAR FROM BID_DATE) = 2017
        ORDER BY EXTRACT(MONTH FROM BID_DATE))
FROM
    ipl_bidder_details bd;
-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be:
-- like
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, 
-- Lowest_3_Bidders  --> columns contains name of bidder;
with temp as
(select bd.BIDDER_NAME,bp.bidder_id, dense_rank()over( order by bp.TOTAL_POINTS)ranking from ipl_bidder_points bp
join ipl_bidder_details bd on bp.BIDDER_ID=bd.BIDDER_ID )
select * from temp
where ranking in (1,2,3) or  ranking in (14,15,16);
-- 


 

