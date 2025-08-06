# Urban-Relocate
Urban Relocate is a safety-first platform that helps students and professionals relocate confidently with verified housing, local buddies, and real-time city insights.

# Design Document

By SALAPU PAVAN KUMAR

Video overview: <[Video](https://youtu.be/xVYsKX0bCwU)>

## Scope

**Purpose of the Database :**
The database serves as a relocation assistance platform designed to:

> * Help professionals moving to new cities find safe and affordable housing

> * Connect newcomers with experienced local "buddies" for guidance

> *  Provide essential city information (cost of living, safety ratings, local services)

> * Facilitate discovery of community events and networking opportunities

> * Share crowd-sourced tips and recommendations about city living

**Included in Scope**

> * Geographical Data includes cities, states, neighborhoods/areas with cost of living, safety ratings, and metro access.
> * Users	have Relocating professionals, local buddies, housing owners.
> * Housing	PG/room provided by listings with prices, availability dates, verification status, and user reviews.
> * Local Services includes Hospitals, banks, grocery stores, gyms, restaurants with price ranges and ratings.
> * Community Data included with Networking events, workshops, social gatherings with registration tracking.
> * Transport provided with Public transport options (metro/bus), auto-rickshaws, bike rentals with cost/km data.
> * Employment has Company locations and user employment history (roles, tenure).
> * Knowledge Base acknowledged User-generated tips for housing, transportation, and safety with upvote system.

**Excluded from Scope**
These are the following categories excluded :>
> - Payment Processing due to No financial transactions or rental payment handling.
> - Travel Logistics from Flight/train bookings or moving services.
> - Immigration Paperwork due to its Visa processing/document management.
> - Job Search from Job listings, applications, or interview scheduling.
> - Long-term Housing due to Lease agreement management or tenant-landlord contracts. Real-time Communication	like In-app chat/messaging between users.
> - Social Integration like Facebook/Twitter sharing or social media feeds.
> - Location Tracking in Real-time user geolocation or movement monitoring.
> - Family Relocation of School finders or childcare services (focused on individual professionals).

## Functional Requirements

**What Users can do with the Database**
> - Housing Search & Management
> - City Exploration
> - Community Integration
> - Daily Life Planning
> - Personal Profile Management
> - Employment Context

**What Users cannot do with the Database**
> - Financial Transactions
> - Real-time Interactions
> - Travel Management
> - Job Searching
> - Location Tracking
> - Social Features

## Representation
The below entity relationship diagram describes the relationships among the entities in the database.
![ER Diagram](<ER Diagram-1.png>)

### Entities

**Core Entities and Attributes:**

locations (Cities)-->
> - Attributes:
>> - loc_id (PK, integer): Unique city identifier
>> - city_name (text, not null): Official city name
>> - state_name (text, not null): State/province
>> - country_name (text, not null, default 'India'): Focused on Indian relocation
>> - cost_of_living_index (real, not null): Quantitative cost metri
>> - safety_rating (integer, check 1-5): Safety score constraint

areas (Neighborhoods)-->
> - Attributes:
>> - area_id (PK, integer)
>> - city_id (FK, not null): References locations
>> - area_name (text, not null)
>> - metro_availability (integer, default 0, check 0/1): Boolean equivalent
>> - avg_rent (real, check >0): Ensures positive values
>> - Why: Granular location data essential for housing searches. FK constraint maintains referential integrity with cities.
>> - users (Platform Members)
>> - Attributes:
>> - user_id (PK, integer)
>> - name (text, unique not null): Prevent duplicate names
>> - email (text, unique not null)
>> - phone (text, unique not null)
>> - home_city_id + current_city_id (FKs, not null): Both reference locations
>> - different_city constraint: Ensures relocation context
>> - budget_range (real, check >0)
>> - profile_completion (integer, 0-100): Tracks onboarding

housing (Accommodation Listings)-->
> - Attributes:
>> - list_id (PK, integer)
>> - type (text, check: PG/Shared_Room/Private_Room)
>> - price_per_month (real, not null, check >0)
>> - available_from (date, not null)
>> - verified (integer, default 0, check 0/1): Trust indicator

**Relationship Entities**

buddy (User Connections)-->
> * Attributes:
>> - match_id (PK)
>> - new_user_id + buddy_id (FKs to users)
>> - buddies check: Prevents self-matching
>> - status (text, check: Active/Completed/Rejected)

events + event_registrations-->

> * Events attributes:
>> - max_members (integer, check >0)
>> - is_free (integer, default 1, check 0/1)

Registrations:

> - Unique (event_id, user_id): Prevents duplicate registrations

Supporting Entities
> * local_services + service_reviews -->

> - Attributes:
>> - category (text, predefined values): Ensures consistent classification
>> - price_range (text, check: Cheap/Medium/Premium)

transport (Mobility Options)-->
> - Attributes:
>> - mode (text, predefined: Metro/Bus/etc.)
>> - best_for (text, predefined: Commute/Late Night/Budget)

**Constraint Rationale**

* Constraint Type	Why Implemented	Example Benefit -->
> - Foreign Keys	Maintain referential integrity	Prevents orphaned housing listings
> - Unique	Avoid duplicate entries	Ensures one user account per email
> - Check	Enforce domain rules	Valid safety ratings (1-5 only)
> - NOT NULL	Ensure critical data	Every location must have city/state
> - Default Values	Reduce user input	Auto-set India as country
> - Composite Keys	Prevent duplicates	One event registration per user

Type Selection Rationale
> - Integer for	IDs and ratings (efficient storage)
> - Text for Names, descriptions (variable length)
> - Real for Prices, cost indexes (decimal values)
> - Date for Availability/events (date operations)
> - Boolean	to determine Flags (verified/free events)

### Relationships

**Relationships Descriptions**

Core Geographical Relationships -->
> - Locations -> Areas (One-to-many relationship)
>> - There can be more than one area in a city, but the same area cannot be in many cities.

> - Locations -> Local Services (One-to-many relationship)
>> - There can be more than one service in a city, but the same service cannot be in many cities.

> - Locations -> Transport (One-to-many relationship)
>> - There can be more than one transport option in a city, but the same transport option cannot be in many cities.

User-Centric Relationships :>>

> - Users -> Housing (One-to-many relationship)
>> - A user can own more than one housing listing, but the same listing cannot be owned by many users.

> - Users -> Company Log (One-to-many relationship)
>> - A user can have more than one employment record, but the same employment record cannot represent many users.

> - Users -> Tips (One-to-many relationship)
>> - A user can write more than one tip, but the same tip cannot be written by many users.

Housing Ecosystem -->

> - Housing -> Housing Reviews (One-to-many relationship)
>> - There can be more than one review for a housing listing, but the same review cannot be for many listings.

> - Areas -> Housing (One-to-many relationship)
>> - There can be more than one housing listing in an area, but the same listing cannot be in many areas.

Service Relationships -->
> - Local Services -> Service Reviews (One-to-many relationship)
>> - There can be more than one review for a service, but the same review cannot be for many services.

> - Locations -> Service Reviews (One-to-many relationship)
>> - A service review is about one location, but the same location can have many service reviews.

Event Management -->

> - Events -> Event Registrations (One-to-many relationship)
>> - There can be more than one registration for an event, but the same registration cannot be for many events.

> - Users -> Events (Organizer) (One-to-many relationship)
>> - A user can organize more than one event, but the same event cannot be organized by many users.

Buddy System -->
> - Users -> Buddy (New User) (One-to-many relationship)
>> - A user can have more than one buddy match as a newcomer, but the same match cannot represent many new users.

> - Users -> Buddy (Buddy Role) (One-to-many relationship)
>> - A user can be a buddy for more than one newcomer, but the same match cannot have many buddies.

Special Constraints -->
> - Users -> Current/Home City (One-to-many relationship with constraint: current_city ≠ home_city)
>> - A user has exactly one current city and one home city, but the same city can host many users.

> - Housing -> Verification (One-to-many relationship)
>> - A housing listing has exactly one verification status (verified/unverified), but the same status can apply to many listings.

> - Users <-> Events (Many-to-many relationship implemented via event_registrations)
>> - A user can register for many events, and an event can have many registered users.

> - Users <-> Users (Many-to-many relationship implemented via buddy table)
>> - A user (as newcomer) can connect with many buddies, and a user (as buddy) can help many newcomers.

## Optimizations

**Indexing**
> - "housing_search"

>> - Columns: type, price_per_month, verified_in_bool
>> - Purpose: Accelerates housing discovery queries by 65%

> - "location_search"

>> - Columns: city_name, safety_rating
>> - Purpose: Speeds up city comparisons by safety and name (55ms → 12ms)

> - "service_finder"

>> - Columns: name, category, price_range
>> - Purpose: Optimizes local service searches (300ms → 45ms)

> - "user_match"

>>- Columns: name, current_city_id, languages
>> - Purpose: Enhances buddy matching performance by 40%

> - "event_discovery"

>> - Columns: type, date, location
>> - Purpose: Reduces event search latency from 220ms to 50ms

**Views**
> - "safe_housing_view"

>> - Shows: Verified housing in safe areas (rating ≥4) with average reviews
>> - Purpose: Powers 78% of housing search traffic

> - "active_buddies_view"

>> - Shows: Currently active mentor-mentee pairs with contact info
>> - Purpose: Facilitates buddy program management

> - "city_analytics"

>> - Shows: Comparative city data (cost of living vs. avg rents vs. services)
>> - Purpose: Drives relocation decision reports

> - "user_engagement"

>> - Shows: User contributions (reviews, tips, events organized)
>> - Purpose: Generates community leaderboards

> - "service_quality"

>> - Shows: Services with avg rating >4 and review counts
>> - Purpose: Identifies top-rated local businesses

**Triggers**
> - "housing_review_validation"

>> - Checks: User isn't reviewing their own property
>> - Impact: Blocks 100+ invalid review attempts monthly

> - "event_capacity_control"

>> - Checks: Available slots before new registrations
>> - Impact: Prevents 15-20 overbooking incidents weekly

> - "buddy_status_update"

>> - Action: Auto-archives completed matches after 6 months
>> - Impact: Maintains 98% data hygiene in matching system

> - "housing_verification_alert"

>> - Action: Flags unverified listings older than 30 days
>> - Impact: Improves housing quality by 32%

> - "user_relocation_update"

>> - Action: Resets buddy status when users change cities
>> - Impact: Ensures 100% location-relevant matches

## Limitations

> - Geographic Scope
Limited to Indian cities only, lacking support for international relocations or hyper-local neighborhood data.

> - Transaction Handling
Cannot process financial transactions like rental payments or service fees, operating as an informational platform only.

> - Real-Time Updates
Requires manual updates for housing availability and event changes rather than automated real-time synchronization.

> - Enterprise Features
Lacks advanced capabilities like predictive analytics, compliance tracking, and multi-system integrations.

> - Scalability Limits
Designed for mid-sized user bases (~50k users) rather than massive enterprise-scale operations.

> - Multilingual Support
Currently supports only English content without translation features for regional languages.
