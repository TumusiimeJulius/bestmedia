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

