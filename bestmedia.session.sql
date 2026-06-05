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

