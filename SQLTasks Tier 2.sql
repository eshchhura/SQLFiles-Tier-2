/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

 SELECT * FROM `Facilities` WHERE membercost = 0; 

/* Q2: How many facilities do not charge a fee to members? */

/* 4 Facilities do not charge a fee. */

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

/*  (0, 'Tennis Court 1', 5.0, 200),
    (1, 'Tennis Court 2', 5.0, 200),
    (4, 'Massage Room 1', 9.9, 3000),
    (5, 'Massage Room 2', 9.9, 3000),
    (6, 'Squash Court', 3.5, 80); */

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM `Facilities` WHERE facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */


SELECT name,
	monthlymaintenance,
     CASE 
        WHEN monthlymaintenance > 100 THEN 'expensive'
        ELSE 'cheap'
    END AS expenses
FROM `Facilities`;

/*
name	monthlymaintenance	expenses	
Tennis Court 1	200	expensive	
Tennis Court 2	200	expensive	
Badminton Court	50	cheap	
Table Tennis	10	cheap	
Massage Room 1	3000	expensive	
Massage Room 2	3000	expensive	
Squash Court	80	cheap	
Snooker Table	15	cheap	
Pool Table	15	cheap	
*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX(joindate)
    FROM Members
)


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


SELECT DISTINCT
	CONCAT(m.firstname, " ", m.surname) as member_name,
    f.name as court_name
FROM `Members` as m
JOIN `Bookings` AS b
	ON b.memid = m.memid
JOIN `Facilities` AS f
	ON b.facid = f.facid
WHERE f.name LIKE "Tennis Court%"
ORDER BY member_name

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


SELECT 
	b.starttime as booking_time,
    f.name as facility_name,
    CASE
    	WHEN (m.firstname = "GUEST") THEN "GUEST"
        ELSE CONCAT(m.firstname, " ", m.surname) 
        END as member_name,
    CASE
    	WHEN (b.memid = 0) THEN b.slots * f.guestcost
        ELSE b.slots * f.membercost
        END as booking_cost
FROM `Bookings` AS b
JOIN `Facilities` AS f ON b.facid = f.facid
JOIN `Members` AS m ON b.memid = m.memid
WHERE b.starttime LIKE "2012-09-14%"
HAVING booking_cost > 30
ORDER BY booking_cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */


SELECT
	q.starttime,
	q.facility_name,
	q.member_name,
	q.booking_cost
FROM (
	SELECT
		b.starttime,
		f.name AS facility_name,
		CASE
			WHEN b.memid = 0 THEN 'GUEST'
			ELSE CONCAT(m.firstname, ' ', m.surname)
    	END AS member_name,
    	CASE
			WHEN b.memid = 0 THEN b.slots * f.guestcost
			ELSE b.slots * f.membercost
    	END AS booking_cost
	FROM `Bookings` AS b
	JOIN `Facilities` AS f ON f.facid = b.facid
    JOIN `Members` AS m ON m.memid = b.memid
    WHERE b.starttime LIKE "2012-09-14%"
) AS q
WHERE q.booking_cost > 30
ORDER BY q.booking_cost DESC;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/*
Q10_Query = pd.read_sql_query("""
SELECT f.name, 
    SUM(
        CASE 
         WHEN b.memid = 0 THEN f.guestcost * b.slots
         ELSE f.membercost * b.slots
        END
    ) AS revenue
FROM Facilities f
JOIN Bookings b ON f.facid = b.facid
GROUP BY f.name
HAVING revenue < 1000
ORDER BY revenue;
""", conn)
display(Q10_Query)
*/

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

/*
Q11_Query = pd.read_sql_query("""
SELECT CONCAT(m.surname, " ", m.firstname) AS member,
    CONCAT(r.surname, " ", r.firstname) AS recommended_by
FROM Members m
LEFT JOIN Members r ON m.recommendedby = r.memid
ORDER BY m.surname, m.firstname;
""", conn)
display(Q11_Query)
*/

/* Q12: Find the facilities with their usage by member, but not guests */

/*
Q12_Query = pd.read_sql_query("""
SELECT f.name AS facility, 
    SUM(b.slots) AS member_usage
FROM Facilities f
JOIN Bookings b 
    ON f.facid = b.facid
WHERE b.memid <> 0
GROUP BY f.name
ORDER BY member_usage DESC;
""", conn)
display(Q12_Query)
*/

/* Q13: Find the facilities usage by month, but not guests */

/* 
Q13_Query = pd.read_sql_query("""
SELECT
    strftime('%Y-%m', b.starttime) AS month,
    f.name AS facility,
    SUM(b.slots) AS usage
FROM Facilities f
JOIN Bookings b 
    ON f.facid = b.facid
WHERE b.memid <> 0
GROUP BY month, facility
ORDER BY month, usage DESC;
""", conn)
display(Q13_Query)
*/
