/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM Facilities 
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) AS no_fee_facilities
FROM Facilities 
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance 
FROM Facilities
WHERE (membercost > 0) AND (membercost < 0.2 * monthlymaintenance)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM Facilities 
WHERE name LIKE "%2"

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	CASE WHEN monthlymaintenance < 100 THEN 'cheap'
		 WHEN monthlymaintenance >= 100 THEN 'expensive'
		 ELSE NULL END AS is_expensive
FROM `Facilities` 
ORDER BY name

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT mem.firstname, mem.surname, mem.joindate
FROM `Members` mem
INNER JOIN
	(SELECT firstname, surname, MAX(joindate) AS most_recent
     FROM `Members`) mem_recent
ON mem.joindate = mem_recent.most_recent


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT 	concat(members.firstname, ' ', members.surname) AS member_name,
		facilities.name AS facility_name
	FROM `Bookings` bookings
	JOIN `Facilities`facilities
		ON bookings.facid = facilities.facid
	JOIN `Members` members
		ON bookings.memid = members.memid
	WHERE facilities.name LIKE "Tennis Court%" AND members.firstname NOT LIKE "GUEST"
	GROUP BY members.firstname, members.surname, facilities.name
	ORDER BY members.surname, members.firstname, facilities.name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

/* Perhaps I misunderstood the question since no member costs exceed $30
and only Massage Rooms exceed $30 for GUESTS */

SELECT 	concat(members.firstname, ' ', members.surname) AS member_name,
		facilities.name AS facility_name,
		facilities.guestcost AS cost_guest,
		facilities.membercost AS cost_member
FROM `Bookings` bookings
	JOIN `Facilities`facilities
		ON bookings.facid = facilities.facid
	JOIN `Members` members
		ON bookings.memid = members.memid
WHERE 	(starttime BETWEEN '2012-09-14' AND '2012-09-15')
	AND ((bookings.memid = 0 AND facilities.guestcost > 30)
		OR (bookings.memid != 0 AND facilities.membercost > 30))
ORDER BY cost_guest DESC, cost_member DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT concat(members.firstname, ' ', members.surname) AS member_name,
		over_30.name AS facility_name,
		over_30.guestcost AS cost_guest,
		over_30.membercost AS cost_member 
FROM
	(
	SELECT 	bookings.facid AS bookings_facid, 
        	bookings.memid, bookings.starttime,
        	facilities.facid AS facilities_facid,
        	facilities.guestcost, facilities.membercost, facilities.name
	FROM `Bookings` bookings
	JOIN `Facilities`facilities
		ON bookings.facid = facilities.facid
	WHERE ((bookings.starttime BETWEEN '2012-09-14' AND '2012-09-15')
           AND ((bookings.memid = 0 AND facilities.guestcost > 30)
			OR (bookings.memid != 0 AND facilities.membercost > 30)))
	) over_30
JOIN `Members` members
	ON over_30.memid = members.memid
ORDER BY cost_guest DESC, cost_member DESC 

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT 	fac.name,
		SUM(CASE WHEN book.memid = 0 THEN fac.guestcost
			 ELSE fac.membercost END) AS revenue
FROM Bookings book
JOIN Facilities fac
	ON book.facid = fac.facid
GROUP BY fac.name
HAVING revenue < 1000
ORDER BY revenue

