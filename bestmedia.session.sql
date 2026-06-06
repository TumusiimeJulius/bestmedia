


Claim offer

Good observation.

Authentication is usually not a separate table called "authentication". It is implemented using the users table plus backend logic (JWT, bcrypt, sessions, tokens, etc.). However, for a complete production system, you should add a few authentication-related tables.

1. Users Table (Authentication Foundation)
You already have:

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('client','provider','admin') DEFAULT 'client',
    status ENUM('active','inactive','blocked') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
Notice:

password_hash VARCHAR(255)
You never store the actual password.

Example:

Password entered:
mypassword123

Stored:
$2b$10$7g1vW.....
using bcrypt.

2. Refresh Tokens Table
If you use JWT authentication, users can stay logged in.

CREATE TABLE refresh_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token TEXT NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
3. Password Reset Tokens
For "Forgot Password".

CREATE TABLE password_resets (
    reset_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    reset_token VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
Flow:

Forgot Password
      ↓
Generate Token
      ↓
Email User
      ↓
User Resets Password
4. Email Verification
Ensure users verify their email.

CREATE TABLE email_verifications (
    verification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    verification_token VARCHAR(255) NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    expires_at DATETIME,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
5. Login History
Track logins.

CREATE TABLE login_history (
    login_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    login_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(50),
    device_info TEXT,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
6. Two-Factor Authentication (Optional)
For extra security.

CREATE TABLE two_factor_auth (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    secret_key VARCHAR(255),
    is_enabled BOOLEAN DEFAULT FALSE,

    FOREIGN KEY(user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
Backend Authentication Components
Besides database tables, you'll need:

Packages
npm install bcryptjs
npm install jsonwebtoken
npm install cookie-parser
npm install dotenv
Authentication APIs
POST /api/auth/register

POST /api/auth/login

POST /api/auth/logout

POST /api/auth/forgot-password

POST /api/auth/reset-password

POST /api/auth/refresh-token

GET /api/auth/profile
Recommended Authentication Tables
For your booking system, I'd start with:

users
refresh_tokens
password_resets
email_verifications
login_history
These cover:

Registration

Login

Logout

JWT authentication

Password reset

Email verification

Login tracking

Together with your booking, payment, service, and notification tables, this gives you a professional database design suitable for a real-world session-booking application.


this is what i have 
//Create Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('client','provider','admin') DEFAULT 'client',
    status ENUM('active','inactive','blocked') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
);
//Create Services Table
CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (provider_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
//Create Availability Table
CREATE TABLE availability (
    availability_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,

    day_of_week ENUM(
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
    ),

    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    FOREIGN KEY (provider_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
//Create Payments Table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,

    booking_id INT NOT NULL,

    amount DECIMAL(10,2) NOT NULL,

    payment_method ENUM(
        'MTN_MOMO',
        'AIRTEL_MONEY',
        'CARD'
    ),

    transaction_reference VARCHAR(100) UNIQUE,

    payment_status ENUM(
        'pending',
        'successful',
        'failed'
    ) DEFAULT 'pending',

    paid_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id)
        ON DELETE CASCADE
);
//Create Reviews Table
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,

    booking_id INT NOT NULL,

    rating INT CHECK(rating BETWEEN 1 AND 5),

    comment TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id)
        ON DELETE CASCADE
);
//User Features
//Favorites
CREATE TABLE favorites (
    favorite_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT,
    provider_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE favorites
ADD FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE,
ADD FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE;
//User Addresses
CREATE TABLE user_addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE user_addresses
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Booking Status History
CREATE TABLE booking_status_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    old_status ENUM('pending','confirmed','completed','canceled') NOT NULL,
    new_status ENUM('pending','confirmed','completed','canceled') NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE booking_status_history
ADD FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;
//Session Notes
CREATE TABLE session_notes (
    note_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    provider_id INT NOT NULL,
    note TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE session_notes
ADD FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
ADD FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE);
//Refunds
CREATE TABLE refunds (
    refund_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason TEXT,
    refund_status ENUM('pending','approved','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE refunds
ADD FOREIGN KEY (payment_id) REFERENCES payments(payment_id) ON DELETE CASCADE;
//Invoices
CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE invoices
ADD FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;
//Audit Logs
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE audit_logs
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Communication Features
//Messages
CREATE TABLE messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE messages
ADD FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
ADD FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Notifications
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE notifications
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Reminders
CREATE TABLE reminders (
    reminder_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    remind_at TIMESTAMP NOT NULL,
    is_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE reminders
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Activity Tracking
CREATE TABLE activity_tracking (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    activity_type VARCHAR(100) NOT NULL,
    activity_details TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE activity_tracking
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Refresh Tokens Table
CREATE TABLE refresh_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE refresh_tokens
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Password Reset Tokens Table
CREATE TABLE password_reset_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE password_reset_tokens
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE);
//Email Verification Tokens Table
CREATE TABLE email_verification_tokens (
    token_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE email_verification_tokens
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE);
//Login History
CREATE TABLE login_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent TEXT
);
ALTER TABLE login_history
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Two-Factor Authentication

CREATE TABLE two_factor_auth (
    auth_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    secret VARCHAR(255) NOT NULL,
    is_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE two_factor_auth
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

Your database is becoming quite comprehensive. However, I noticed a few important issues and missing pieces before you move on to the backend.

1. You're Missing the bookings Table
Several tables reference bookings(booking_id):

payments

reviews

booking_status_history

session_notes

invoices

But I don't see the actual bookings table.

You should add:

CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,

    client_id INT NOT NULL,
    service_id INT NOT NULL,

    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,

    status ENUM(
        'pending',
        'paid',
        'confirmed',
        'completed',
        'cancelled'
    ) DEFAULT 'pending',

    notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (client_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (service_id)
        REFERENCES services(service_id)
        ON DELETE CASCADE
);
2. Add Service Categories
This makes filtering easier.

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);
Add to services:

ALTER TABLE services
ADD category_id INT;

ALTER TABLE services
ADD FOREIGN KEY (category_id)
REFERENCES categories(category_id);
Examples:

Business Consulting

Tutoring

Fitness

Career Coaching

3. Provider Profiles
Right now providers only have a name and email.

Add:

CREATE TABLE provider_profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    bio TEXT,
    profile_picture VARCHAR(255),
    specialization VARCHAR(100),
    experience_years INT,
    website VARCHAR(255),

    FOREIGN KEY (provider_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);
4. Payment Callback Logs
Very useful for MTN MoMo integration.

CREATE TABLE payment_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT,
    response_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(payment_id)
    REFERENCES payments(payment_id)
    ON DELETE CASCADE
);
5. Meeting Links
For online sessions.

CREATE TABLE meetings (
    meeting_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    meeting_link VARCHAR(500),
    platform VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(booking_id)
    REFERENCES bookings(booking_id)
    ON DELETE CASCADE
);
6. Coupons / Promo Codes
CREATE TABLE coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE,
    discount_percentage DECIMAL(5,2),
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);
7. Booking Attachments
Clients may need to upload documents before a session.

CREATE TABLE booking_attachments (
    attachment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    file_name VARCHAR(255),
    file_path VARCHAR(255),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id)
    REFERENCES bookings(booking_id)
    ON DELETE CASCADE
);
8. Add Authentication Fields to Users
Instead of creating extra queries later:

ALTER TABLE users
ADD COLUMN email_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN last_login TIMESTAMP NULL,
ADD COLUMN profile_image VARCHAR(255) NULL;
9. Create Indexes
This will make your application much faster.

CREATE INDEX idx_user_email ON users(email);

CREATE INDEX idx_booking_date
ON bookings(booking_date);

CREATE INDEX idx_payment_status
ON payments(payment_status);

CREATE INDEX idx_service_provider
ON services(provider_id);
Current Assessment
You already have approximately 90% of a production-ready database:

✅ Users
✅ Authentication tables
✅ Services
✅ Availability
✅ Bookings (once added)
✅ Payments
✅ Reviews
✅ Messaging
✅ Notifications
✅ Reminders
✅ Refunds
✅ Invoices
✅ Audit logs
✅ Activity tracking
✅ Two-factor authentication

The next major step is not adding more tables. The next step is:

Create the database in MySQL.

Insert test data.

Build the Node.js connection (db.js).

Create authentication APIs:

Register

Login

Logout

Refresh Token

Test with Postman.

Then build the React frontend.

At this point, adding many more tables will give diminishing returns. It's usually better to start building the backend and add new tables only when a real feature requires them.



Pasted text(1).txt
Document
this is now what i have 

This is a very ambitious schema and you've covered most major features. However, before moving to the backend, I would clean it up because there are some design issues that will cause MySQL errors or maintenance problems.

What You've Done Well ✅
You have covered:

Users

Authentication

Services

Availability

Bookings

Payments

Reviews

Favorites

Addresses

Messaging

Notifications

Reminders

Audit Logs

Activity Tracking

Coupons

Refunds

Invoices

Attachments

Provider Profiles

Two-Factor Authentication

This is already enough for a commercial booking platform.

Issues to Fix
1. Duplicate category_id
You have:

ALTER TABLE services
ADD COLUMN category_id INT,
ADD FOREIGN KEY ...
and later:

ALTER TABLE services
ADD COLUMN category_id INT,
ADD FOREIGN KEY ...
Remove one of them.

2. Duplicate Indexes
You created many indexes multiple times.

For example:

CREATE INDEX idx_bookings_client_id ON bookings(client_id);
appears more than once.

CREATE INDEX idx_bookings_provider_id ON bookings(provider_id);
appears more than once.

CREATE INDEX idx_bookings_status ON bookings(status);
appears more than once.

MySQL will throw:

Duplicate key name
Keep only one copy.

3. bookings.category_id Does Not Exist
You created:

CREATE INDEX idx_bookings_category_id
ON bookings(category_id);
But the bookings table has no category_id.

Either:

Remove it
DROP INDEX idx_bookings_category_id ON bookings;
or add:

ALTER TABLE bookings
ADD COLUMN category_id INT;
Usually this field is unnecessary because:

booking
 → service
     → category
already gives you the category.

4. Payment Table Is Becoming Too Large
You have:

payments
plus:

refund_amount
refund_reason
refund_status
refund_notes
refund_transaction_reference
refund_payment_method
...
A cleaner design is:

payments
payment_id
booking_id
amount
status
refunds
refund_id
payment_id
amount
reason
status
created_at
You already have a refunds table.

Most of those refund columns can be removed from payments.

5. Authentication Duplication
You have:

Tables
password_reset_tokens
email_verification_tokens
two_factor_auth
and also inside users:

password_reset_token
email_verification_token
two_factor_secret
Choose one approach.

I recommend:

Keep
password_reset_tokens
email_verification_tokens
two_factor_auth
Remove from users
password_reset_token
password_reset_expires_at
email_verification_token
email_verification_expires_at
two_factor_secret
because the separate tables are more scalable.

6. Missing Booking Constraints
Prevent double-booking.

Example:

ALTER TABLE bookings
ADD CONSTRAINT unique_provider_slot
UNIQUE(
    provider_id,
    booking_date,
    booking_time
);
Without this:

Provider
9:00 AM

Client A books
Client B books
Client C books
All three could occupy the same slot.

7. Add Soft Delete
Instead of deleting users.

ALTER TABLE users
ADD COLUMN deleted_at TIMESTAMP NULL;
This preserves history.

Final Structure I'd Use
users
provider_profiles

services
service_categories
availability

bookings
booking_status_history
booking_attachments

payments
payment_logs
refunds
invoices
coupons

reviews
favorites

messages
notifications
reminders

audit_logs
activity_tracking

refresh_tokens
password_reset_tokens
email_verification_tokens
login_history
two_factor_auth
My Overall Rating
For a university project:

9.5/10

For a startup MVP:

8.5/10

The database is now more than sufficient. I would stop adding tables and start building the backend:

Create the database in MySQL.

Fix the duplicate columns/indexes.

Test table creation.

Build db.js.

Build authentication (register, login, JWT).

Build services API.

Build bookings API.

Build payments API.

Connect React frontend.

At this stage, the backend is the next priority, not additional database design.



Pasted text(2).txt
Document

This has gone far beyond what you need for version 1.

My honest assessment of the latest schema:

What is good
You have covered nearly every feature of a commercial booking system:

Authentication

Authorization

Bookings

Payments

Refunds

Reviews

Notifications

Messaging

Coupons

Provider Profiles

Audit Logs

Attachments

Activity Tracking

Soft Deletes

Archiving

What is becoming a problem
You are starting to over-engineer the database.

For example:

deleted_at
is_deleted
is_archived
on almost every table.

You only need one soft-delete strategy.

I would recommend:

deleted_at TIMESTAMP NULL
That's enough.

Instead of:

is_deleted
deleted_at
is_archived
on every table.

Major Issues I Still See
1. Duplicate category_id
You still have:

ALTER TABLE services
ADD COLUMN category_id INT
twice.

Keep only one.

2. Duplicate indexes
Many indexes appear multiple times:

idx_bookings_client_id
idx_bookings_provider_id
idx_bookings_status
idx_payments_payment_status
MySQL will reject duplicates.

3. Invalid SQL
You have statements like:

ALTER TABLE payments
ADD COLUMN refund_amount DECIMAL(10,2) DEFAULT 0);
Extra ) at the end.

And:

ALTER TABLE payments
ADD COLUMN refund_status ENUM(...) DEFAULT 'pending');
Extra ).

And:

ALTER TABLE payments
//Booking Attachments
which is incomplete SQL.

4. Invalid Index
You created:

CREATE INDEX idx_bookings_category_id
ON bookings(category_id);
but bookings has no category_id.

5. Refund Information Is Duplicated
You have:

refunds table
and also:

refund_amount
refund_reason
refund_status
refund_notes
inside payments.

Choose one design.

I recommend:

payments
refunds
separate tables.

6. Authentication Duplication
You have:

password_reset_tokens table
email_verification_tokens table
two_factor_auth table
AND

password_reset_token
email_verification_token
two_factor_secret
inside users.

Keep the tables.

Remove the duplicate columns from users.

What I Would Do Now
Stop adding tables.

Your next milestone should be:

Create Database
CREATE DATABASE booking_system;
USE booking_system;
Create Clean SQL Script
Organize tables in order:

1. users
2. service_categories
3. provider_profiles
4. services
5. availability
6. bookings
7. payments
8. refunds
9. reviews
10. messages
11. notifications
12. authentication tables
13. logs
Test in MySQL
Import the schema and fix every error until:

SHOW TABLES;
returns all tables successfully.

Then Start Backend
Create:

backend/
│
├── config/
│   └── db.js
│
├── routes/
│   ├── auth.routes.js
│   ├── booking.routes.js
│   ├── payment.routes.js
│
├── controllers/
├── middleware/
├── models/
│
└── app.js
At this point, the database design is no longer the bottleneck. The bottleneck is implementing the backend APIs and testing them with Postman. That's where I'd focus next.



Pasted text(4).txt
Document

Good progress. Looking at the logs you shared, the main problem has been fixed.

What happened?
Initially you had:

TypeError: argument handler must be a function
at:

routes/authRoutes.js:10:8
This error means Express expected something like:

router.post("/register", registerUser);
where registerUser is a function.

But it was receiving:

undefined
or some other non-function value.

This usually happens when:

authController.js
const registerUser = async (req, res) => {
   ...
};

const loginUser = async (req, res) => {
   ...
};

module.exports = {
   registerUser,
   loginUser
};
and then in:

authRoutes.js
const {
   registerUser,
   loginUser
} = require("../controllers/authController");
If you forget the export or misspell a name, Express throws exactly the error you saw.

Current Status
The important part is the end of your log:

Server running on port 5000
This means:

✅ Express started

✅ Routes loaded

✅ No syntax errors

✅ No controller import errors

✅ Nodemon is watching

Test the API
Open Postman.

Test Root Route
GET http://localhost:5000
Expected:

Booking API Running
Test Register
POST http://localhost:5000/api/auth/register
Body → Raw → JSON

{
  "full_name": "John Doe",
  "email": "john@gmail.com",
  "phone": "0771234567",
  "password": "123456"
}
Expected:

{
  "success": true,
  "message": "User registered successfully"
}
If Register Gives Error
Check nodemon terminal.

Common errors:

Database connection failed
ECONNREFUSED
Check:

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=booking_system
Table missing
ER_NO_SUCH_TABLE
Run:

SHOW TABLES;
and confirm:

users
exists.

Test Login
POST http://localhost:5000/api/auth/login
Body:

{
  "email": "john@gmail.com",
  "password": "123456"
}
Expected:

{
  "success": true,
  "token": "eyJhbGc..."
}
Next Backend Step
After register and login work, build:

JWT Middleware
Create:

middleware/
└── authMiddleware.js
This middleware will protect routes such as:

POST /api/bookings
POST /api/payments
GET  /api/profile
so only logged-in users can access them.

Before we move there, run the Register API in Postman and tell me the exact response you get. That will confirm whether the database connection and users table are working correctly.


when i run this GET http://localhost:5000 
it runs

That's a good sign.

When you open:

http://localhost:5000
and you get:

Booking API Running
it means:

✅ Node.js is running

✅ Express server is running

✅ app.js is working

✅ Port 5000 is listening

✅ Route loading is working

Now the next test is not the browser.

You need to test your API endpoints using:

Postman (recommended)

Thunder Client (VS Code extension)

Insomnia

Test Registration
Method:

POST
URL:

http://localhost:5000/api/auth/register
Headers:

Content-Type: application/json
Body → Raw → JSON

{
    "full_name":"John Doe",
    "email":"john@gmail.com",
    "phone":"0771234567",
    "password":"123456"
}
Click Send.

If Successful
You should get something like:

{
    "success": true,
    "message": "User registered successfully"
}
And in MySQL:

SELECT * FROM users;
you should see a new user record.

Then Test Login
Method:

POST
URL:

http://localhost:5000/api/auth/login
Body:

{
    "email":"john@gmail.com",
    "password":"123456"
}
Expected:

{
    "success": true,
    "token": "eyJhbGc..."
}
If you haven't installed Postman yet, you can get it from:

Postman

Or use the Thunder Client extension in VS Code.

Run the Register request and tell me:

The response you get.

Any error shown in the terminal.

Then we'll fix it and move to JWT authentication.


am getting this issue
500
Internal Server Error
d\controllers\authController.js:8:13)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:157:13)
    at Route.dispatch (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:117:3)
    at handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:435:11)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:295:15
    at processParams (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:582:12)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:291:5)
    at router.handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:186:3)
Error: Unknown database 'booking_system'
    at registerUser (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\controllers\authController.js:14:41)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:157:13)
    at Route.dispatch (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:117:3)
    at handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:435:11)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:295:15
    at processParams (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:582:12)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:291:5)
    at router.handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:186:3) {
  code: 'ER_BAD_DB_ERROR',
  errno: 1049,
  sqlState: '42000',
  sqlMessage: "Unknown database 'booking_system'",
  sql: undefined
}
Error: Unknown database 'booking_system'
    at registerUser (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\controllers\authController.js:14:41)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:157:13)
    at Route.dispatch (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:117:3)
    at handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:435:11)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:295:15
    at processParams (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:582:12)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:291:5)
    at router.handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:186:3) {
  code: 'ER_BAD_DB_ERROR',
  errno: 1049,
  sqlState: '42000',
  sqlMessage: "Unknown database 'booking_system'",
  sql: undefined
}
Error: Unknown database 'booking_system'
    at registerUser (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\controllers\authController.js:14:41)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:157:13)
    at Route.dispatch (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:117:3)
    at handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:435:11)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:295:15
    at processParams (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:582:12)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:291:5)
    at router.handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:186:3) {
  code: 'ER_BAD_DB_ERROR',
  errno: 1049,
  sqlState: '42000',
  sqlMessage: "Unknown database 'booking_system'",
  sql: undefined
}
Error: Unknown database 'booking_system'
    at registerUser (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\controllers\authController.js:14:41)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:157:13)
    at Route.dispatch (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:117:3)
    at handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:435:11)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:295:15
    at processParams (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:582:12)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:291:5)
    at router.handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:186:3) {
  code: 'ER_BAD_DB_ERROR',
  errno: 1049,
  sqlState: '42000',
  sqlMessage: "Unknown database 'booking_system'",
  sql: undefined
}
Error: Unknown database 'booking_system'
    at registerUser (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\controllers\authController.js:14:41)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:157:13)
    at Route.dispatch (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:117:3)
    at handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:435:11)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:295:15
    at processParams (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:582:12)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:291:5)
    at router.handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:186:3) {
  code: 'ER_BAD_DB_ERROR',
  errno: 1049,
  sqlState: '42000',
  sqlMessage: "Unknown database 'booking_system'",
  sql: undefined
}
Error: Unknown database 'booking_system'
    at registerUser (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\controllers\authController.js:14:41)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:157:13)
    at Route.dispatch (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\route.js:117:3)
    at handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:435:11)
    at Layer.handleRequest (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\lib\layer.js:152:17)
    at C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:295:15
    at processParams (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:582:12)
    at next (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:291:5)
    at router.handle (C:\Users\juliu\Desktop\bestmedia\booking-system-backend\node_modules\router\index.js:186:3) {
  code: 'ER_BAD_DB_ERROR',
  errno: 1049,
  sqlState: '42000',
  sqlMessage: "Unknown database 'booking_system'",
  sql: undefined
}

Good — this error is actually very clear, and it’s an easy fix.

🚨 Root Problem
Your backend is trying to connect to this database:

Unknown database 'booking_system'
Meaning:

👉 MySQL does NOT have a database called booking_system

✅ FIX (Step by Step)
Step 1: Open MySQL (XAMPP / Workbench / CLI)
Run this:

SHOW DATABASES;
Check if you see:

booking_system
Step 2: If it does NOT exist → Create it
Run:

CREATE DATABASE booking_system;
Then select it:

USE booking_system;
Step 3: Re-run your tables
Paste your schema again (users, services, bookings, etc.)

OR if you saved it in a .sql file, import it.

Step 4: Confirm tables exist
SHOW TABLES;
You should see:

users
services
bookings
payments
...
⚠️ Most likely mistake you made
You wrote in .env:

DB_NAME=booking_system
But:

❌ You never created that database in MySQL

OR

❌ You created it with a different name like:

booking-system

Booking_System

bookingSystem

(MySQL is case-sensitive on Linux setups)

🔥 Quick Fix Summary
Run ONLY these 2 commands:

CREATE DATABASE booking_system;
USE booking_system;
Then restart backend:

npm run dev
👍 After Fix
Try again:

POST http://localhost:5000/api/auth/register
If everything is correct, you will finally get:

{
  "success": true,
  "message": "User registered successfully"
}
🚀 If it still fails
Send me:

your .env file

your config/db.js

I’ll debug it with you step-by-step until it works.


You’ve reached the Free limit for chats with attachments
Upgrade now or wait until 4:41 PM to keep using files, or chat now without files.

New chat

Claim free offer

//Create Users Table
CREATE TABLE users (
user_id INT AUTO_INCREMENT PRIMARY KEY,
full_name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(20) UNIQUE,
password_hash VARCHAR(255) NOT NULL,
role ENUM('client','provider','admin') DEFAULT 'client',
status ENUM('active','inactive','blocked') DEFAULT 'active',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP
);
//Create Services Table
CREATE TABLE services (
service_id INT AUTO_INCREMENT PRIMARY KEY,
provider_id INT NOT NULL,
service_name VARCHAR(100) NOT NULL,
description TEXT,
duration_minutes INT NOT NULL,
price DECIMAL(10,2) NOT NULL,
is_active BOOLEAN DEFAULT TRUE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (provider_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);
//Create Availability Table
CREATE TABLE availability (
availability_id INT AUTO_INCREMENT PRIMARY KEY,
provider_id INT NOT NULL,

day_of_week ENUM(
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
),

start_time TIME NOT NULL,
end_time TIME NOT NULL,

FOREIGN KEY (provider_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);
//Create Payments Table
CREATE TABLE payments (
payment_id INT AUTO_INCREMENT PRIMARY KEY,

booking_id INT NOT NULL,

amount DECIMAL(10,2) NOT NULL,

payment_method ENUM(
    'MTN_MOMO',
    'AIRTEL_MONEY',
    'CARD'
),

transaction_reference VARCHAR(100) UNIQUE,

payment_status ENUM(
    'pending',
    'successful',
    'failed'
) DEFAULT 'pending',

paid_at TIMESTAMP NULL,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (booking_id)
    REFERENCES bookings(booking_id)
    ON DELETE CASCADE
);
//Create Reviews Table
CREATE TABLE reviews (
review_id INT AUTO_INCREMENT PRIMARY KEY,

booking_id INT NOT NULL,

rating INT CHECK(rating BETWEEN 1 AND 5),

comment TEXT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (booking_id)
    REFERENCES bookings(booking_id)
    ON DELETE CASCADE
);
//User Features
//Favorites
CREATE TABLE favorites (
favorite_id INT AUTO_INCREMENT PRIMARY KEY,
client_id INT,
provider_id INT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE favorites
ADD FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE,
ADD FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE;
//User Addresses
CREATE TABLE user_addresses (
address_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
address_line1 VARCHAR(255) NOT NULL,
address_line2 VARCHAR(255),
city VARCHAR(100) NOT NULL,
state VARCHAR(100) NOT NULL,
postal_code VARCHAR(20) NOT NULL,
country VARCHAR(100) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE user_addresses
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Booking Status History
CREATE TABLE booking_status_history (
history_id INT AUTO_INCREMENT PRIMARY KEY,
booking_id INT NOT NULL,
old_status ENUM('pending','confirmed','completed','canceled') NOT NULL,
new_status ENUM('pending','confirmed','completed','canceled') NOT NULL,
changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE booking_status_history
ADD FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;
//Session Notes
CREATE TABLE session_notes (
note_id INT AUTO_INCREMENT PRIMARY KEY,
booking_id INT NOT NULL,
provider_id INT NOT NULL,
note TEXT NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE session_notes
ADD FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
ADD FOREIGN KEY (provider_id) REFERENCES users(user_id) ON DELETE CASCADE);
//Refunds
CREATE TABLE refunds (
refund_id INT AUTO_INCREMENT PRIMARY KEY,
payment_id INT NOT NULL,
amount DECIMAL(10,2) NOT NULL,
reason TEXT,
refund_status ENUM('pending','approved','rejected') DEFAULT 'pending',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE refunds
ADD FOREIGN KEY (payment_id) REFERENCES payments(payment_id) ON DELETE CASCADE;
//Invoices
CREATE TABLE invoices (
invoice_id INT AUTO_INCREMENT PRIMARY KEY,
booking_id INT NOT NULL,
invoice_number VARCHAR(100) UNIQUE NOT NULL,
amount DECIMAL(10,2) NOT NULL,
issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE invoices
ADD FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;
//Audit Logs
CREATE TABLE audit_logs (
log_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
action VARCHAR(255) NOT NULL,
details TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE audit_logs
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Communication Features
//Messages
CREATE TABLE messages (
message_id INT AUTO_INCREMENT PRIMARY KEY,
sender_id INT NOT NULL,
receiver_id INT NOT NULL,
content TEXT NOT NULL,
is_read BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE messages
ADD FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
ADD FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Notifications
CREATE TABLE notifications (
notification_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
content TEXT NOT NULL,
is_read BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE notifications
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Reminders
CREATE TABLE reminders (
reminder_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
content TEXT NOT NULL,
remind_at TIMESTAMP NOT NULL,
is_sent BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE reminders
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Activity Tracking
CREATE TABLE activity_tracking (
activity_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
activity_type VARCHAR(100) NOT NULL,
activity_details TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE activity_tracking
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Refresh Tokens Table
CREATE TABLE refresh_tokens (
token_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
token VARCHAR(255) NOT NULL,
expires_at TIMESTAMP NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE refresh_tokens
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Password Reset Tokens Table
CREATE TABLE password_reset_tokens (
token_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
token VARCHAR(255) NOT NULL,
expires_at TIMESTAMP NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE password_reset_tokens
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE);
//Email Verification Tokens Table
CREATE TABLE email_verification_tokens (
token_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
token VARCHAR(255) NOT NULL,
expires_at TIMESTAMP NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE email_verification_tokens
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE);
//Login History
CREATE TABLE login_history (
history_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ip_address VARCHAR(45),
user_agent TEXT
);
ALTER TABLE login_history
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//Two-Factor Authentication

CREATE TABLE two_factor_auth (
auth_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
secret VARCHAR(255) NOT NULL,
is_enabled BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE two_factor_auth
ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;
//bookings
CREATE TABLE bookings (
booking_id INT AUTO_INCREMENT PRIMARY KEY,
client_id INT NOT NULL,
service_id INT NOT NULL,
provider_id INT NOT NULL,
booking_date DATE NOT NULL,
booking_time TIME NOT NULL,
status ENUM('pending','confirmed','completed','canceled') DEFAULT 'pending',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (client_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE,

FOREIGN KEY (service_id)
    REFERENCES services(service_id)
    ON DELETE CASCADE,

FOREIGN KEY (provider_id)
    REFERENCES users(user_id)
    ON DELETE CASCADE
);
//Service Categories

CREATE TABLE service_categories (
category_id INT AUTO_INCREMENT PRIMARY KEY,
category_name VARCHAR(100) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE services
ADD COLUMN category_id INT,
ADD FOREIGN KEY (category_id) REFERENCES service_categories(category_id) ON DELETE SET NULL;
//Add to services:
ALTER TABLE services
ADD COLUMN category_id INT,
ADD FOREIGN KEY (category_id) REFERENCES service_categories(category_id) ON DELETE SET NULL;
//Provider Profiles
CREATE TABLE provider_profiles (
profile_id INT AUTO_INCREMENT PRIMARY KEY,
provider_id INT NOT NULL,
bio TEXT,
profile_picture VARCHAR(255),
specialization VARCHAR(100),
experience_years INT,
website VARCHAR(255),

FOREIGN KEY (provider_id)
REFERENCES users(user_id)
ON DELETE CASCADE
);
//Payment Callback Logs
CREATE TABLE payment_logs (
log_id INT AUTO_INCREMENT PRIMARY KEY,
payment_id INT,
response_data JSON,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY(payment_id)
REFERENCES payments(payment_id)
ON DELETE CASCADE
);
//Meeting Links
CREATE TABLE meetings (
meeting_id INT AUTO_INCREMENT PRIMARY KEY,
booking_id INT NOT NULL,
meeting_link VARCHAR(500),
platform VARCHAR(50),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY(booking_id)
REFERENCES bookings(booking_id)
ON DELETE CASCADE
);
//Coupons / Promo Codes
CREATE TABLE coupons (
coupon_id INT AUTO_INCREMENT PRIMARY KEY,
code VARCHAR(50) UNIQUE NOT NULL,
description TEXT,
discount_type ENUM('percentage','fixed') NOT NULL,
discount_value DECIMAL(10,2) NOT NULL,
valid_from DATE NOT NULL,
valid_to DATE NOT NULL,
usage_limit INT,
times_used INT DEFAULT 0,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE bookings
ADD COLUMN coupon_id INT,
ADD FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) ON DELETE SET NULL;
//add coupon_id to payments
ALTER TABLE payments
ADD COLUMN coupon_id INT,
ADD FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) ON DELETE SET NULL;
//Add discount_amount to payments
ALTER TABLE payments
ADD COLUMN discount_amount DECIMAL(10,2) DEFAULT 0;
//Add total_amount to payments
ALTER TABLE payments
ADD COLUMN total_amount DECIMAL(10,2) NOT NULL;
//Add final_amount to payments
ALTER TABLE payments
ADD COLUMN final_amount DECIMAL(10,2) NOT NULL;
//Add applied_coupon_code to payments
ALTER TABLE payments
ADD COLUMN applied_coupon_code VARCHAR(50);
//Add is_refunded to payments
ALTER TABLE payments
ADD COLUMN is_refunded BOOLEAN DEFAULT FALSE;
//Add refund_amount to payments
ALTER TABLE payments
ADD COLUMN refund_amount DECIMAL(10,2) DEFAULT 0);
//Add refund_reason to payments
ALTER TABLE payments
ADD COLUMN refund_reason TEXT;
//Add refund_status to payments
ALTER TABLE payments
ADD COLUMN refund_status ENUM('pending','approved','rejected') DEFAULT 'pending');
//Add refunded_at to payments
ALTER TABLE payments
ADD COLUMN refunded_at TIMESTAMP NULL;
//Add refund_transaction_reference to payments
ALTER TABLE payments
ADD COLUMN refund_transaction_reference VARCHAR(100) UNIQUE;
//Add refund_payment_method to payments
ALTER TABLE payments
ADD COLUMN refund_payment_method ENUM('MTN_MOMO','AIRTEL_MONEY','CARD');
//Add refund_notes to payments
ALTER TABLE payments
ADD COLUMN refund_notes TEXT;
//Add is_coupon_applied to payments
ALTER TABLE payments
ADD COLUMN is_coupon_applied BOOLEAN DEFAULT FALSE;
//Add coupon_discount_amount to payments
ALTER TABLE payments
ADD COLUMN coupon_discount_amount DECIMAL(10,2) DEFAULT 0);
//Add coupon_code to payments
ALTER TABLE payments
ADD COLUMN coupon_code VARCHAR(50);
//Add original_amount to payments
ALTER TABLE payments
ADD COLUMN original_amount DECIMAL(10,2) NOT NULL;
//Add final_amount_after_refund to payments
ALTER TABLE payments
ADD COLUMN final_amount_after_refund DECIMAL(10,2) NOT NULL);
//Add is_partial_refund to payments
ALTER TABLE payments
//Booking Attachments
CREATE TABLE booking_attachments (
attachment_id INT AUTO_INCREMENT PRIMARY KEY,
booking_id INT NOT NULL,
file_path VARCHAR(255) NOT NULL,
file_type VARCHAR(50),
uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (booking_id)
REFERENCES bookings(booking_id)
ON DELETE CASCADE
);
//Add attachment_count to bookings
ALTER TABLE bookings
ADD COLUMN attachment_count INT DEFAULT 0;

//Add Authentication Fields to Users
ALTER TABLE users
ADD COLUMN last_login TIMESTAMP NULL,
ADD COLUMN is_email_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN email_verification_token VARCHAR(255),
ADD COLUMN email_verification_expires_at TIMESTAMP NULL,
ADD COLUMN password_reset_token VARCHAR(255),
ADD COLUMN password_reset_expires_at TIMESTAMP NULL,
ADD COLUMN two_factor_secret VARCHAR(255),
ADD COLUMN is_two_factor_enabled BOOLEAN DEFAULT FALSE;
//Create Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_services_provider_id ON services(provider_id);
CREATE INDEX idx_bookings_client_id ON bookings(client_id);
CREATE INDEX idx_bookings_provider_id ON bookings(provider_id);
CREATE INDEX idx_payments_booking_id ON payments(booking_id);
CREATE INDEX idx_reviews_booking_id ON reviews(booking_id);
CREATE INDEX idx_favorites_client_id ON favorites(client_id);
CREATE INDEX idx_favorites_provider_id ON favorites(provider_id);
CREATE INDEX idx_user_addresses_user_id ON user_addresses(user_id);
CREATE INDEX idx_booking_status_history_booking_id ON booking_status_history(booking_id);
CREATE INDEX idx_session_notes_booking_id ON session_notes(booking_id);
CREATE INDEX idx_session_notes_provider_id ON session_notes(provider_id);
CREATE INDEX idx_refunds_payment_id ON refunds(payment_id);
CREATE INDEX idx_invoices_booking_id ON invoices(booking_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_reminders_user_id ON reminders(user_id);
CREATE INDEX idx_activity_tracking_user_id ON activity_tracking(user_id);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX idx_login_history_user_id ON login_history(user_id);
CREATE INDEX idx_two_factor_auth_user_id ON two_factor_auth(user_id);
CREATE INDEX idx_bookings_service_id ON bookings(service_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_service_categories_category_name ON service_categories(category_name);
CREATE INDEX idx_provider_profiles_provider_id ON provider_profiles(provider_id);
CREATE INDEX idx_payment_logs_payment_id ON payment_logs(payment_id);
CREATE INDEX idx_meetings_booking_id ON meetings(booking_id);
CREATE INDEX idx_coupons_code ON coupons(code);
CREATE INDEX idx_bookings_coupon_id ON bookings(coupon_id);
CREATE INDEX idx_payments_coupon_id ON payments(coupon_id);
CREATE INDEX idx_payments_payment_status ON payments(payment_status);
CREATE INDEX idx_payments_refund_status ON payments(refund_status);
CREATE INDEX idx_payments_is_refunded ON payments(is_refunded);
CREATE INDEX idx_payments_refund_payment_method ON payments(refund_payment_method);
CREATE INDEX idx_payments_refund_status ON payments(refund_status);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_bookings_booking_time ON bookings(booking_time);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_client_id ON bookings(client_id);
CREATE INDEX idx_bookings_provider_id ON bookings(provider_id);
CREATE INDEX idx_bookings_service_id ON bookings(service_id);
CREATE INDEX idx_bookings_coupon_id ON bookings(coupon_id);
CREATE INDEX idx_bookings_category_id ON bookings(category_id);
CREATE INDEX idx_bookings_attachment_count ON bookings(attachment_count);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_is_email_verified ON users(is_email_verified);
CREATE INDEX idx_users_is_two_factor_enabled ON users(is_two_factor_enabled);
CREATE INDEX idx_services_is_active ON services(is_active);
CREATE INDEX idx_services_category_id ON services(category_id);
CREATE INDEX idx_availability_provider_id ON availability(provider_id);
CREATE INDEX idx_availability_day_of_week ON availability(day_of_week);
CREATE INDEX idx_availability_start_time ON availability(start_time);
CREATE INDEX idx_availability_end_time ON availability(end_time);
CREATE INDEX idx_payments_payment_method ON payments(payment_method);
CREATE INDEX idx_payments_payment_status ON payments(payment_status);
CREATE INDEX idx_payments_refund_status ON payments(refund_status);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
CREATE INDEX idx_favorites_created_at ON favorites(created_at);
CREATE INDEX idx_user_addresses_city ON user_addresses(city);
CREATE INDEX idx_user_addresses_state ON user_addresses(state);
CREATE INDEX idx_user_addresses_postal_code ON user_addresses(postal_code);
CREATE INDEX idx_user_addresses_country ON user_addresses(country);
CREATE INDEX idx_booking_status_history_changed_at ON booking_status_history(changed_at);
CREATE INDEX idx_session_notes_created_at ON session_notes(created_at);
CREATE INDEX idx_refunds_created_at ON refunds(created_at);
CREATE INDEX idx_invoices_issued_at ON invoices(issued_at);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_reminders_remind_at ON reminders(remind_at);
CREATE INDEX idx_activity_tracking_created_at ON activity_tracking(created_at);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
CREATE INDEX idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);
CREATE INDEX idx_email_verification_tokens_expires_at ON email_verification_tokens(expires_at);
CREATE INDEX idx_login_history_login_time ON login_history(login_time);
CREATE INDEX idx_two_factor_auth_is_enabled ON two_factor_auth(is_enabled);
CREATE INDEX idx_booking_attachments_booking_id ON booking_attachments(booking_id);
CREATE INDEX idx_booking_attachments_file_type ON booking_attachments(file_type);
ALTER TABLE bookings
ADD CONSTRAINT unique_provider_slot
UNIQUE(
provider_id,
booking_date,
booking_time
);
ALTER TABLE users
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
ALTER TABLE services
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_services_deleted_at ON services(deleted_at);
ALTER TABLE bookings
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_bookings_deleted_at ON bookings(deleted_at);
ALTER TABLE payments
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_payments_deleted_at ON payments(deleted_at);
ALTER TABLE reviews
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_reviews_deleted_at ON reviews(deleted_at);
ALTER TABLE favorites
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_favorites_deleted_at ON favorites(deleted_at);
ALTER TABLE user_addresses
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_user_addresses_deleted_at ON user_addresses(deleted_at);
ALTER TABLE booking_status_history
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_booking_status_history_deleted_at ON booking_status_history(deleted_at);
ALTER TABLE session_notes
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_session_notes_deleted_at ON session_notes(deleted_at);
ALTER TABLE refunds
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_refunds_deleted_at ON refunds(deleted_at);
ALTER TABLE invoices
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_invoices_deleted_at ON invoices(deleted_at);
ALTER TABLE audit_logs
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_audit_logs_deleted_at ON audit_logs(deleted_at);
ALTER TABLE messages
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_messages_deleted_at ON messages(deleted_at);
ALTER TABLE notifications
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_notifications_deleted_at ON notifications(deleted_at);
ALTER TABLE reminders
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_reminders_deleted_at ON reminders(deleted_at);
ALTER TABLE activity_tracking
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_activity_tracking_deleted_at ON activity_tracking(deleted_at);
ALTER TABLE refresh_tokens
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_refresh_tokens_deleted_at ON refresh_tokens(deleted_at);
ALTER TABLE password_reset_tokens
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_password_reset_tokens_deleted_at ON password_reset_tokens(deleted_at);
ALTER TABLE email_verification_tokens
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_email_verification_tokens_deleted_at ON email_verification_tokens(deleted_at);
ALTER TABLE login_history
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_login_history_deleted_at ON login_history(deleted_at);
ALTER TABLE two_factor_auth
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_two_factor_auth_deleted_at ON two_factor_auth(deleted_at);
ALTER TABLE service_categories
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_service_categories_deleted_at ON service_categories(deleted_at);
ALTER TABLE provider_profiles
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_provider_profiles_deleted_at ON provider_profiles(deleted_at);
ALTER TABLE payment_logs
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_payment_logs_deleted_at ON payment_logs(deleted_at);
ALTER TABLE meetings
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_meetings_deleted_at ON meetings(deleted_at);
ALTER TABLE coupons
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_coupons_deleted_at ON coupons(deleted_at);
//Add is_deleted to users
ALTER TABLE users
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_users_is_deleted ON users(is_deleted);
//Add is_deleted to services
ALTER TABLE services
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_services_is_deleted ON services(is_deleted);
//Add is_deleted to bookings
ALTER TABLE bookings
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_bookings_is_deleted ON bookings(is_deleted);
//Add is_deleted to payments
ALTER TABLE payments
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_payments_is_deleted ON payments(is_deleted);
//Add is_deleted to reviews
ALTER TABLE reviews
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_reviews_is_deleted ON reviews(is_deleted);
//Add is_deleted to favorites
ALTER TABLE favorites
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_favorites_is_deleted ON favorites(is_deleted);
//Add is_deleted to user_addresses
ALTER TABLE user_addresses
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_user_addresses_is_deleted ON user_addresses(is_deleted);
//Add is_deleted to booking_status_history
ALTER TABLE booking_status_history
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_booking_status_history_is_deleted ON booking_status_history(is_deleted);
//Add is_deleted to session_notes
ALTER TABLE session_notes
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_session_notes_is_deleted ON session_notes(is_deleted);
//Add is_deleted to refunds
ALTER TABLE refunds
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_refunds_is_deleted ON refunds(is_deleted);
//Add is_deleted to invoices
ALTER TABLE invoices
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_invoices_is_deleted ON invoices(is_deleted);
ALTER TABLE audit_logs
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_audit_logs_is_deleted ON audit_logs(is_deleted);
ALTER TABLE messages
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_messages_is_deleted ON messages(is_deleted);
ALTER TABLE notifications
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_notifications_is_deleted ON notifications(is_deleted);
ALTER TABLE reminders
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_reminders_is_deleted ON reminders(is_deleted);
ALTER TABLE activity_tracking
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_activity_tracking_is_deleted ON activity_tracking(is_deleted);
ALTER TABLE refresh_tokens
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_refresh_tokens_is_deleted ON refresh_tokens(is_deleted);
ALTER TABLE password_reset_tokens
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_password_reset_tokens_is_deleted ON password_reset_tokens(is_deleted);
ALTER TABLE email_verification_tokens
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_email_verification_tokens_is_deleted ON email_verification_tokens(is_deleted);
ALTER TABLE login_history
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_login_history_is_deleted ON login_history(is_deleted);
ALTER TABLE two_factor_auth
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_two_factor_auth_is_deleted ON two_factor_auth(is_deleted);
ALTER TABLE service_categories
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_service_categories_is_deleted ON service_categories(is_deleted);
ALTER TABLE provider_profiles
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_provider_profiles_is_deleted ON provider_profiles(is_deleted);
ALTER TABLE payment_logs
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_payment_logs_is_deleted ON payment_logs(is_deleted);
ALTER TABLE meetings
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_meetings_is_deleted ON meetings(is_deleted);
ALTER TABLE coupons
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_coupons_is_deleted ON coupons(is_deleted);
//Add is_archived to users
ALTER TABLE users
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_users_is_archived ON users(is_archived);
//Add is_archived to services
ALTER TABLE services
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_services_is_archived ON services(is_archived);
//Add is_archived to bookings
ALTER TABLE bookings
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_bookings_is_archived ON bookings(is_archived);
//Add is_archived to payments
ALTER TABLE payments
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_payments_is_archived ON payments(is_archived);
//Add is_archived to reviews
ALTER TABLE reviews
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_reviews_is_archived ON reviews(is_archived);
//Add is_archived to favorites
ALTER TABLE favorites
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_favorites_is_archived ON favorites(is_archived);
ALTER TABLE user_addresses
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_user_addresses_is_archived ON user_addresses(is_archived);
ALTER TABLE booking_status_history
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_booking_status_history_is_archived ON booking_status_history(is_archived);
ALTER TABLE session_notes
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_session_notes_is_archived ON session_notes(is_archived);
ALTER TABLE refunds
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_refunds_is_archived ON refunds(is_archived);
ALTER TABLE invoices
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_invoices_is_archived ON invoices(is_archived);
ALTER TABLE audit_logs
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_audit_logs_is_archived ON audit_logs(is_archived);
ALTER TABLE messages
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_messages_is_archived ON messages(is_archived);
ALTER TABLE notifications
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_notifications_is_archived ON notifications(is_archived);
ALTER TABLE reminders
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_reminders_is_archived ON reminders(is_archived);
ALTER TABLE activity_tracking
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_activity_tracking_is_archived ON activity_tracking(is_archived);
ALTER TABLE refresh_tokens
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_refresh_tokens_is_archived ON refresh_tokens(is_archived);
ALTER TABLE password_reset_tokens
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_password_reset_tokens_is_archived ON password_reset_tokens(is_archived);
ALTER TABLE email_verification_tokens
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_email_verification_tokens_is_archived ON email_verification_tokens(is_archived);
ALTER TABLE login_history
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_login_history_is_archived ON login_history(is_archived);
ALTER TABLE two_factor_auth
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_two_factor_auth_is_archived ON two_factor_auth(is_archived);
ALTER TABLE service_categories
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_service_categories_is_archived ON service_categories(is_archived);
ALTER TABLE provider_profiles
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_provider_profiles_is_archived ON provider_profiles(is_archived);
ALTER TABLE payment_logs
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_payment_logs_is_archived ON payment_logs(is_archived);
ALTER TABLE meetings
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_meetings_is_archived ON meetings(is_archived);
ALTER TABLE coupons
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_coupons_is_archived ON coupons(is_archived);
//Add is_archived to booking_attachments
ALTER TABLE booking_attachments
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_booking_attachments_is_archived ON booking_attachments(is_archived);
//Add is_deleted to booking_attachments
ALTER TABLE booking_attachments
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_booking_attachments_is_deleted ON booking_attachments(is_deleted);
//Add deleted_at to booking_attachments
ALTER TABLE booking_attachments
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_booking_attachments_deleted_at ON booking_attachments(deleted_at);
//Add is_deleted to meetings
ALTER TABLE meetings
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_meetings_is_deleted ON meetings(is_deleted);
//Add deleted_at to meetings
ALTER TABLE meetings
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_meetings_deleted_at ON meetings(deleted_at);
//Add is_archived to meetings
ALTER TABLE meetings
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_meetings_is_archived ON meetings(is_archived);
//Add is_deleted to coupons
ALTER TABLE coupons
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_coupons_is_deleted ON coupons(is_deleted);
//Add deleted_at to coupons
ALTER TABLE coupons
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_coupons_deleted_at ON coupons(deleted_at);
//Add is_archived to coupons
ALTER TABLE coupons
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_coupons_is_archived ON coupons(is_archived);
//Add is_deleted to provider_profiles
ALTER TABLE provider_profiles
ADD COLUMN is_deleted BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_provider_profiles_is_deleted ON provider_profiles(is_deleted);
//Add deleted_at to provider_profiles
ALTER TABLE provider_profiles
ADD COLUMN deleted_at TIMESTAMP NULL;
CREATE INDEX idx_provider_profiles_deleted_at ON provider_profiles(deleted_at);
//Add is_archived to provider_profiles
ALTER TABLE provider_profiles
ADD COLUMN is_archived BOOLEAN DEFAULT FALSE;
CREATE INDEX idx_provider_profiles_is_archived ON provider_profiles(is_archived);
//Add refund_payment_method to payments
ALTER TABLE payments




Close
ADD COLUMN refund_payment_method ENUM('MTN_MOMO','AIRTEL_MONEY','CARD');
CREATE INDEX idx_payments_refund_payment_method ON payments(refund_payment_method);