-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

--To find a safer housing with good rating
SELECT h.list_id, h.type, h.price_per_month, a.area_name, l.city_name, round(avg(hr.rating),1)
as avg_rating, count(hr.review_id) as number_of_reviews
from housing h
join areas a on h.area_id = a.area_id
join locations l on a.city_id = l.loc_id
left join housing_reviews hr on h.list_id = hr.listing_id
where l.safety_rating >= 4
and h.available_from <=  CURRENT_DATE
group by h.list_id
having avg_rating >= 3.5
order by h.price_per_month;

--To get the events which are open to register
select * from vw_events
where status = 'open';

--To get all the details of a user with id = 4
select u.name, l_h.city_name as "from", l_c.city_name as "now_living_in",
(select count(*) from Buddy where new_user_id = u.user_id) as "has_buddy",
(select count(*) from vw_events where city_name = l_c.city_name and status = 'open')as 'upcoming_events'
from users u
join locations l_h on u.home_city_id = l_h.loc_id
join locations l_c on u.current_city_id = l_c.loc_id
where user_id = 4;

--To find an employee who has work experience more than 2 years in Business Analyst
select u.name, u.email, u.phone, c.company_name, c.completed_years
from users u join company_log c on c.employee_id = u.user_id
where c.role = 'Business Analyst'
and c.completed_years >= 2;

--To know all the services of Hyderabad having more than 4 rating
select ls.category, ls.name, ls.price_range, ls.location, round(avg(sr.rating),1) as avg_rating, count(sr.review_id) as "votes",
l.city_name
from local_services ls
join service_reviews sr on ls.service_id = sr.service_id
join locations l on ls.location = l.loc_id
where l.city_name = 'Hyderabad'
group by ls.service_id
having avg(sr.rating) > 4
order by ls.name;


--To get the top 10 tips of any particular service
select t.category, t.title, t.content, l.city_name, t.upvotes
from Tips t
join locations l on l.loc_id = t.location
order by upvotes desc
limit 10;

--Finding the employee who works in Tata Consultancy Services from Delhi
select u.name, u.email, u.phone, c.company_name, c.completed_years,l.city_name as "home_city"
from users u join company_log c on c.employee_id = u.user_id
join locations l on u.home_city_id = l.loc_id
where c.company_name = 'Tata Consultancy Services'
and l.city_name = 'Delhi';

-- Find potential roommates with similar budgets
SELECT u.user_id, u.name, u.languages, h.type AS "current_housing", h.price_per_month, a.area_name
FROM users u
JOIN housing h ON u.housing_id = h.list_id
JOIN areas a ON h.area_id = a.area_id
WHERE u.current_city_id = 3  -- Bangalore
AND h.price_per_month BETWEEN 20000 AND 30000  -- Budget range
AND u.user_id != 5  -- Don't show current user
ORDER BY h.price_per_month;

-- Find nearby hospitals
SELECT s.name, s.category, s.price_range, (SELECT ROUND(AVG(rating), 1) FROM service_reviews
     WHERE service_id = s.service_id) AS "rating"
FROM local_services s
WHERE s.location = 3  -- Bangalore
AND s.category IN ('Hospital')
ORDER BY rating DESC;

-- Get tips and recommendations from the user's buddy
SELECT t.title, t.category, t.content, t.upvotes
FROM tips t
JOIN Buddy b ON t.author_id = b.buddy_id
WHERE b.new_user_id = 4  -- Current user
AND b.status = 'Active'
ORDER BY t.upvotes DESC;

--To update the current city of user 1
update users set current_city_id = (select loc_id from locations where city_name = 'Hyderabad')
where user_id = 1;

--Deleting the past events
delete from events
where date(event_date) < CURRENT_DATE
and not exists (select 1 from event_registrations where event_id = events.event_id);

--Locations
INSERT INTO locations ("loc_id", "city_name", "state_name", "cost_of_living_index", "safety_rating") VALUES
(1, 'Mumbai', 'Maharashtra', 85.5, 3),
(2, 'Delhi', 'Delhi', 82.3, 3),
(3, 'Bangalore', 'Karnataka', 78.9, 4),
(4, 'Hyderabad', 'Telangana', 72.1, 4),
(5, 'Chennai', 'Tamil Nadu', 70.8, 4),
(6, 'Pune', 'Maharashtra', 68.5, 4),
(7, 'Kolkata', 'West Bengal', 65.2, 3),
(8, 'Ahmedabad', 'Gujarat', 62.7, 4),
(9, 'Visakhapatnam', 'Andhra Pradesh', 58.0, 4),
(10, 'Jaipur', 'Rajasthan', 60.3, 3);

--Areas
INSERT INTO areas ("area_id", "city_id", "area_name", "metro_availability_in_bool", "avg_rent") VALUES
-- Mumbai areas (city_id 1)
(101, 1, 'Bandra', 1, 45000),
(102, 1, 'Andheri', 1, 38000),
-- Delhi areas (city_id 2)
(201, 2, 'Connaught Place', 1, 50000),
(202, 2, 'Gurgaon', 1, 48000),
-- Bangalore areas (city_id 3)
(301, 3, 'Koramangala', 1, 35000),
(302, 3, 'Whitefield', 1, 32000),
-- Hyderabad areas (city_id 4)
(401, 4, 'Gachibowli', 1, 30000),
(402, 4, 'Hitech City', 1, 32000),
-- Visakhapatnam areas (city_id 9)
(901, 9, 'MVP Colony', 0, 18000),
(902, 9, 'Rushikonda', 0, 22000);


--Users
INSERT INTO users ("user_id", "name", "email", "phone", "home_city_id", "current_city_id", "languages", "budget_range", "housing_id", "profile_completion") VALUES
-- User from Vizag working in Bangalore
(1, 'Rajesh Kumar', 'rajesh.k@example.com', '0000000000', 9, 3, 'Telugu,Hindi,English', 25000, 301, 85),
-- User from Delhi working in Mumbai
(2, 'Priya Singh', 'priya.s@example.com', '1111111111', 2, 1, 'Hindi,English', 35000, 101, 90),
-- User from Mumbai working in Hyderabad
(3, 'Amit Desai', 'amit.d@example.com', '2222222222', 1, 4, 'Marathi,Hindi,English', 30000, 401, 80),
-- User from Bangalore working in Visakhapatnam
(4, 'Ananya Reddy', 'ananya.r@example.com', '3333333333', 3, 9, 'Kannada,English,Telugu', 20000, 901, 75),
-- User from Hyderabad working in Delhi
(5, 'Vikram Patel', 'vikram.p@example.com', '4444444444', 4, 2, 'Telugu,Hindi,English', 40000, 201, 95);

--Housing
INSERT INTO housing ("list_id", "type", "price_per_month", "owner_id", "area_id", "available_from", "verified_in_bool", "contact_number") VALUES
-- Mumbai properties (city_id 1)
(1, 'PG', 12000, 2, 101, '2023-11-01', 1, '1111111111'),
(2, 'Private_Room', 25000, 2, 102, '2023-11-15', 1, '1111111111'),
-- Delhi properties (city_id 2)
(3, 'Shared_Room', 18000, 5, 201, '2023-12-01', 1, '4444444444'),
(4, 'Private_Room', 32000, 5, 202, '2023-11-20', 0, '4444444444'),
-- Bangalore properties (city_id 3)
(5, 'PG', 10000, 1, 301, '2023-11-10', 1, '0000000000'),
(6, 'Shared_Room', 15000, 1, 302, '2023-12-05', 1, '0000000000'),
-- Hyderabad properties (city_id 4)
(7, 'Private_Room', 18000, 3, 401, '2023-11-25', 1, '2222222222'),
(8, 'PG', 9000, 3, 402, '2023-12-01', 0, '2222222222'),
-- Visakhapatnam properties (city_id 9)
(9, 'Shared_Room', 8000, 4, 901, '2023-11-15', 1, '3333333333'),
(10, 'Private_Room', 12000, 4, 902, '2023-12-10', 1, '3333333333');

-- Tenant experiences at different properties
INSERT INTO housing_reviews ("review_id", "listing_id", "user_id", "rating", "comment") VALUES
(1, 5, 5, 4, 'Great location near office, but water pressure could be better. Owner responds quickly.'),
(2, 5, 3, 5, 'Perfect for working professionals! WiFi is super fast and the housekeeping service is reliable.'),
(3, 2, 1, 3, 'Decent space but the building needs pest control. Good value for the price though.'),
(4, 7, 4, 1, 'Photos were misleading - apartment was much smaller than advertised. Broken appliances on arrival.'),
(5, 9, 5, 5, 'Best PG in Vizag! Homely food and caring staff. Made my relocation so comfortable.');

--Company Log
INSERT INTO company_log ("employment_id", "company_name", "location_id", "employee_id", "industry", "completed_years", "role") VALUES
(1, 'Infosys', 3, 1, 'IT Services', 2, 'Software Engineer'),
(2, 'Tata Consultancy Services', 1, 2, 'Information Technology', 3, 'Project Manager'),
(3, 'Wipro', 3, 1, 'Technology', 1, 'Associate Consultant'),
(4, 'HDFC Bank', 2, 5, 'Banking', 5, 'Relationship Manager'),
(5, 'Reliance Industries', 1, 2, 'Conglomerate', 2, 'Business Analyst'),
(6, 'Tech Mahindra', 4, 3, 'Telecom', 4, 'Technical Lead'),
(7, 'Amazon India', 3, 1, 'E-commerce', 1, 'SDE I'),
(8, 'Vizag Steel Plant', 9, 4, 'Manufacturing', 7, 'Production Engineer'),
(9, 'Hyderabad Metro', 4, 3, 'Transportation', 2, 'Operations Executive'),
(10, 'Delhi Public School', 2, 5, 'Education', 4, 'Administrator');

--Local Services
INSERT INTO local_services ("service_id", "location", "category", "name", "price_range") VALUES
-- Mumbai (loc_id 1)
(1, 1, 'Hospital', 'Lilavati Hospital', 'Premium'),
(2, 1, 'Grocery', 'Nature''s Basket', 'Medium'),
-- Delhi (loc_id 2)
(3, 2, 'Shopping', 'Select Citywalk Mall', 'Premium'),
(4, 2, 'Restaurant', 'Bukhara', 'Premium'),
-- Bangalore (loc_id 3)
(5, 3, 'Gym', 'Cult Fit Koramangala', 'Medium'),
(6, 3, 'Bank', 'HDFC Bank Whitefield', 'Cheap'),
-- Hyderabad (loc_id 4)
(7, 4, 'Hospital', 'Apollo Hospital', 'Premium'),
(8, 4, 'Restaurant', 'Paradise Biryani', 'Medium'),
-- Visakhapatnam (loc_id 9)
(9, 9, 'Grocery', 'Vizag Central Market', 'Cheap'),
(10, 9, 'Bank', 'SBI MVP Colony Branch', 'Cheap');

--Reviews for Local Services
INSERT INTO service_reviews("review_id", "service_id", "user_id", "rating", "comment") VALUES
-- Reviews for Mumbai services
(1, 1, 2, 4, 'Excellent facilities but waiting time is long'),
(2, 2, 2, 3, 'Good quality but slightly overpriced'),
-- Review for Delhi restaurant
(3, 4, 5, 5, 'Best Indian food I''ve ever had!'),
-- Review for Bangalore gym
(4, 5, 1, 2, 'Equipment needs maintenance'),
-- Review for Vizag grocery
(5, 9, 4, 4, 'Fresh produce at reasonable prices');

--Events
INSERT INTO events ("event_id", "title", "organizer_id", "description", "type", "is_free", "max_members", "event_date", "location") VALUES
-- Mumbai events (loc_id 1)
(1, 'Tech Startup Mixer', 2, 'Networking event for tech entrepreneurs', 'Networking', 0, 50, '2023-12-15', 1),
(2, 'Mumbai Marathon', 2, 'Annual city marathon', 'Sports', 1, 1000, '2024-01-21', 1),
-- Delhi events (loc_id 2)
(3, 'Digital Marketing Workshop', 5, 'Learn SEO and social media strategies', 'Workshop', 0, 30, '2023-12-10', 2),
(4, 'Delhi Food Festival', 5, 'Annual culinary showcase', 'Social', 1, 200, '2024-02-05', 2),
-- Bangalore events (loc_id 3)
(5, 'AI Conference 2023', 1, 'Annual artificial intelligence summit', 'Conferences', 0, 150, '2023-11-25', 3),
(6, 'Bangalore Book Club', 1, 'Monthly book discussion meetup', 'Social', 1, 20, '2023-12-03', 3),
-- Visakhapatnam events (loc_id 9)
(7, 'Beach Cleanup Drive', 4, 'Community coastal cleanup', 'Social', 1, 100, '2023-11-19', 9),
(8, 'Vizag Tech Meetup', 4, 'Monthly technology discussion', 'Networking', 1, 40, '2023-12-07', 9);

--Event Registrations
INSERT INTO event_registrations ("reg_id", "event_id", "user_id") VALUES
-- Registrations for Mumbai events
(1, 1, 3),  -- Amit attending Tech Startup Mixer
(2, 2, 2),  -- Priya running in Mumbai Marathon
-- Registration for Delhi event
(3, 3, 5),  -- Vikram attending Digital Marketing Workshop
-- Registration for Bangalore event
(4, 5, 1),  -- Rajesh attending AI Conference
-- Registration for Vizag event
(5, 7, 4);  -- Ananya joining Beach Cleanup

--Buddies
INSERT INTO Buddy ("match_id", "new_user_id", "buddy_id", "status") VALUES
(1, 1, 2, 'Active'),    -- Rajesh (Bangalore newcomer) paired with Priya (Mumbai)
(2, 3, 4, 'Completed'), -- Amit (Hyderabad) was helped by Ananya (Vizag)
(3, 4, 1, 'Active'),    -- Ananya (Vizag newcomer) paired with Rajesh
(4, 2, 5, 'Rejected'),  -- Priya's request to Vikram was rejected
(5, 5, 3, 'Active');    -- Vikram (Delhi) paired with Amit

--Transport Details
INSERT INTO Transport ("transport_id", "location", "mode", "avg_cost_per_km", "best_for") VALUES
-- Mumbai (loc_id 1)
(1, 1, 'Metro', 10.0, 'Commute'),
(2, 1, 'Auto', 18.0, 'Late Night'),
-- Delhi (loc_id 2)
(3, 2, 'Metro', 8.0, 'Commute'),
(4, 2, 'Bus', 5.0, 'Budget'),
-- Bangalore (loc_id 3)
(5, 3, 'Auto', 15.0, 'Late Night'),
(6, 3, 'Bike rental', 12.0, 'Budget'),
-- Visakhapatnam (loc_id 9)
(7, 9, 'Auto', 12.0, 'Commute'),
(8, 9, 'Bus', 6.0, 'Budget');

--Tips
INSERT INTO Tips ("tips_id", "location", "author_id", "category", "title", "content", "upvotes") VALUES
-- Mumbai tips (loc_id 1)
(1, 1, 2, 'Housing', 'Best Areas for Expats', 'Bandra and Juhu have great international communities', 15),
(2, 1, 3, 'Transport', 'Avoid Autos During Rush Hour', 'Metro is much faster 8-10am and 5-7pm', 32),
-- Bangalore tips (loc_id 3)
(3, 3, 1, 'Safety', 'Night Travel Safety', 'Use only registered cabs after 10pm', 28),
(4, 3, 1, 'Transport', 'Namma Metro Tips', 'Get a smart card to avoid ticket queues', 45),
-- Visakhapatnam tips (loc_id 9)
(5, 9, 4, 'Housing', 'Budget Areas Near Beach', 'MVP Colony offers affordable places with sea view', 12),
(6, 9, 4, 'Safety', 'Beach Safety', 'Avoid Rushikonda beach after dark', 8);
