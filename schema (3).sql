-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it
create table locations(
    "loc_id" integer,
    "city_name" text not null,
    "state_name" text not null,
    "country_name" text not null default 'India',
    "cost_of_living_index" real not null,
    "safety_rating" integer check("safety_rating" between 1 and 5),
    primary key("loc_id")
);

create index idx_location_names on locations("city_name");
create index idx_location_safety on locations("safety_rating");

create table areas(
    "area_id" integer,
    "city_id" integer not null,
    "area_name" text not null,
    "metro_availability_in_bool" integer default 0 check("metro_availability_in_bool" in (0,1)),
    "avg_rent" real not null check(avg_rent > 0),
    primary key("area_id"),
    foreign key ("city_id") references locations("loc_id") on delete cascade
);

create index idx_area on areas("area_name");

create table housing(
    "list_id" integer,
    "type" text check(type in('PG','Shared_Room','Private_Room')),
    "price_per_month" real not null check("price_per_month" > 0 ),
    "owner_id" integer not null,
    "area_id" integer not null,
    "available_from" date not null,
    "verified_in_bool" integer default 0 check("verified_in_bool" in (0,1)),
    "contact_number" text not null,
    primary key("list_id"),
    foreign key("area_id") references areas("area_id") on delete cascade
);

create index idx_housing_area on housing("area_id");
create index idx_housing_price on housing("price_per_month");
create index idx_housing_type on housing("type");
create index idx_housing_owner on housing("owner_id");

create table users(
    "user_id" integer,
    "name" text unique not null,
    "email" text unique not null,
    "phone" text unique not null,
    "home_city_id" integer not null,
    "current_city_id" integer not null,
    "languages" text,
    "budget_range" real check("budget_range" > 0),
    "housing_id" integer,
    "profile_completion" integer default 0 check(profile_completion between 0 and 100),
    primary key("user_id"),
    foreign key("home_city_id") references locations("loc_id") on delete cascade,
    foreign key("current_city_id") references locations("loc_id") on delete cascade,
    foreign key("housing_id") references housing("list_id") on delete set null,
    constraint different_city check (current_city_id <> home_city_id)
);

create index idx_user_name on users("name");
create index idx_email on users("email");
create index idx_user_current_city on users("current_city_id");

create table housing_reviews(
    "review_id" integer,
    "listing_id" integer not null,
    "user_id" integer not null,
    "rating" integer not null check(rating between 1 and 5),
    "comment" text,
    "review_date" date not null default CURRENT_DATE,
    primary key("review_id"),
    foreign key("listing_id") references housing("list_id") on delete cascade,
    foreign key("user_id") references users("user_id")on delete cascade
);
create index idx_house_review on housing_reviews("listing_id","rating");

create table company_log(
    "employment_id" integer,
    "company_name" text not null,
    "location_id" integer not null,
    "employee_id" integer not null,
    "industry" text,
    "completed_years" integer,
    role text,
    primary key("employment_id"),
    foreign key("location_id") references locations("loc_id") on delete cascade,
    foreign key("employee_id") references users("user_id") on delete cascade
);

create table local_services(
    "service_id" integer,
    "location" integer not null,
    "category" text check(category in('Grocery','Shopping','Hospital','Gym','Bank','Restaurant')),
    "name" text not null,
    "price_range" text check (price_range in ('Cheap','Medium','Premium')),
    primary key("service_id"),
    foreign key("location") references locations("loc_id") on delete cascade
);

create table service_reviews(
    "review_id" integer,
    "service_id" integer not null,
    "user_id" integer not null,
    "rating" integer not null check(rating between 1 and 5),
    "comment" text,
    "review_date" date not null default CURRENT_DATE,
    primary key("review_id"),
    foreign key("service_id") references local_services("service_id") on delete cascade,
    foreign key("user_id") references users("user_id") on delete cascade
);

create index idx_service_loc_category on local_services("location","category");
create index idx_service_prices on local_services("price_range");


create index idx_service_review on service_reviews("service_id","rating");

create table events(
    "event_id" integer,
    "title" text not null,
    "organizer_id" integer not null,
    "description" text not null,
    "type" text check(type in ('Networking','Sports','Conferences','Workshop','Social')),
    "is_free" integer default 1,
    "max_members" integer not null check("max_members" > 0),
    "event_date" DATE not null default CURRENT_DATE,
    "location" integer not null,
    primary key("event_id"),
    foreign key("location") references locations("loc_id") on delete cascade,
    foreign key("organizer_id") references users("user_id") on delete cascade
);

create index idx_events_date on events("event_date");
create index idx_events_location on events("location");
create index idx_events_type on events("type");

create table event_registrations(
    "reg_id" integer,
    "event_id" integer not null,
    "user_id" integer not null,
    "register_time" DATE not null default CURRENT_DATE,
    primary key("reg_id"),
    foreign key("user_id") references users("user_id") on delete cascade,
    foreign key("event_id") references events("event_id") on delete cascade,
    unique("event_id","user_id")
);

create table Buddy(
    "match_id" integer,
    "new_user_id" integer not null,
    "buddy_id" integer not null,
    "match_date" DATE default CURRENT_DATE,
    "status" text check("status" in ('Active', 'Completed', 'Rejected')),
    primary key("match_id"),
    foreign key("new_user_id") references users("user_id") on delete cascade,
    foreign key("buddy_id") references users("user_id") on delete cascade,
    constraint buddies check("new_user_id" <> "buddy_id")
);

CREATE INDEX idx_buddy_matches_new_user ON Buddy("new_user_id", "status");
CREATE INDEX idx_buddy_matches_buddy_user ON Buddy("buddy_id", "status");

create table Transport(
    "transport_id" integer,
    "location" integer not null,
    "mode" text check("mode" in ('Metro','Bus','Auto','Bike rental')),
    "avg_cost_per_km" real not null,
    "best_for" text check("best_for" in('Commute','Late Night','Budget')),
    primary key("transport_id"),
    foreign key("location") references locations("loc_id") on delete cascade
);

CREATE INDEX idx_transport_location_mode ON Transport("location", "mode");
CREATE INDEX idx_transport_cost_mode ON Transport("avg_cost_per_km", "mode");

create table Tips(
    "tips_id" integer,
    "location" integer not null,
    "author_id" integer not null,
    "category" text check("category" in ('Housing','Transport','Safety')),
    "title" text not null,
    "content" text not null,
    "upvotes" integer default 0,
    primary key("tips_id"),
    foreign key("location") references locations("loc_id") on delete cascade,
    foreign key("author_id") references users("user_id") on delete cascade
);

create view vw_safe_housing as
select h.list_id, h.type, h.price_per_month, a.area_name, l.city_name, h.available_from, round(avg(hr.rating),1) as avg_rating, h.contact_number from housing h
join areas a on a.area_id = h.area_id
join locations l on a.city_id = l.loc_id
left join housing_reviews hr on hr.listing_id = h.list_id
where l.safety_rating >= 4
and h.price_per_month >= (select avg(price_per_month) from housing)
group by h.list_id
order by h.price_per_month,avg_rating desc ;

create view vw_events as
select e.event_id, e.title, e.type, e.event_date, l.city_name, count(er.reg_id) as "registered_numbers",e.max_members - count(er.reg_id) as "slots_remaining",
case when count(er.reg_id) >= e.max_members then "full"
else "open" end as "status"
from events e
join locations l on l.loc_id = e.location
left join event_registrations er on er.event_id = e.event_id
where e.event_date >= CURRENT_DATE
group by e.event_id
order by e.event_date;

create view active_buddies as
select u1.name as new_employee, u1.current_city_id,
u2.name as buddy, b.match_date
from Buddy b
join users u1 on u1.user_id = b.new_user_id
join users u2 on u2.user_id = b.buddy_id
where b.status = 'Active';

create view vw_city_analysis as
select l.city_name, l.cost_of_living_index, l.safety_rating,
avg(h.price_per_month) as avg_rent, count(distinct s.service_id) as number_of_services,
count(distinct e.event_id) as upcoming_events
from locations l
left join areas a on l.loc_id = a.city_id
left join housing h on  a.area_id = h.area_id
left join local_services s on l.loc_id = s.location
left join events e on l.loc_id = e.location
group by l.loc_id;

create view vw_user_engagement as
select u.user_id, u.name,
count(distinct er.event_id) as events_attended,
count(distinct h.review_id) as reviews_posted,
count(distinct case when b.new_user_id = u.user_id then b.match_id end )
as "times_helped_by",
count(distinct case when b.buddy_id = u.user_id then b.match_id end) as "times_helped"
from users u
left join event_registrations er on u.user_id = er.user_id
left join Buddy b on u.user_id in (b.new_user_id, b.buddy_id)
left join housing_reviews h on u.user_id = h.user_id
group by u.user_id;

create trigger tr_prevent_house_reviews
before insert on housing_reviews
for each row
when new.user_id = (select owner_id from housing where list_id = new.listing_id)
begin
select RAISE(ABORT, 'user cannot review on his own property');
end;

create trigger tr_check_event_capacity
before insert on event_registrations
for each row
when (select count(*) from event_registrations where event_id = new.event_id) >=
(select max_members from events where event_id = new.event_id)
begin
select RAISE(ABORT, 'Event has reached its max capacity');
end;
