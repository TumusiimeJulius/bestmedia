const db = require("../config/db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const registerUser = async (req, res) => {
    try {

        const {
            full_name,
            email,
            phone,
            password,
            role = 'client'
        } = req.body;

        const allowedRoles = ['client', 'provider', 'admin'];
        if (!allowedRoles.includes(role)) {
            return res.status(400).json({
                message: 'Invalid role selected'
            });
        }

        const [existingUser] = await db.query(
            'SELECT * FROM users WHERE email = ? OR phone = ?',
            [email, phone]
        );

        if (existingUser.length > 0) {
            const conflict = existingUser[0].email === email ? 'Email' : 'Phone';
            return res.status(400).json({
                message: `${conflict} already exists`
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        await db.query(
            `INSERT INTO users
            (full_name, email, phone, password_hash, role)
            VALUES (?, ?, ?, ?, ?)`,
            [
                full_name,
                email,
                phone,
                hashedPassword,
                role
            ]
        );

        res.status(201).json({
            success: true,
            message: 'User registered successfully'
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: error.message || 'Server Error'
        });
    }
};
// login function
const loginUser = async (req, res) => {

    try {

        const {
            email,
            password
        } = req.body;

        const [users] = await db.query(
            "SELECT * FROM users WHERE email=?",
            [email]
        );

        if (users.length === 0) {
            return res.status(404).json({
                message: "User not found"
            });
        }

        const user = users[0];

        const isMatch =
            await bcrypt.compare(
                password,
                user.password_hash
            );

        if (!isMatch) {
            return res.status(401).json({
                message: "Invalid credentials"
            });
        }

        const token = jwt.sign(
            {
                user_id: user.user_id,
                role: user.role
            },
            process.env.JWT_SECRET,
            {
                expiresIn: "1d"
            }
        );

        res.status(200).json({
            success: true,
            token
        });

    } catch (error) {

        console.log(error);

        res.status(500).json({
            message: "Server Error"
        });
    }
};
// forgot password: generate code, save to password_reset_tokens, send email
const nodemailer = require('nodemailer');

async function sendResetEmail(toEmail, code) {
    const host = process.env.SMTP_HOST;
    const port = process.env.SMTP_PORT;
    const user = process.env.SMTP_USER;
    const pass = process.env.SMTP_PASS;
    const from = process.env.EMAIL_FROM || user;

    if (!host || !port || !user || !pass) {
        throw new Error('Email service is not configured. Add SMTP settings to the backend .env file.');
    }

    const transporter = nodemailer.createTransport({
        host,
        port: Number(port),
        secure: Number(port) === 465, // true for 465, false for other ports
        auth: {
            user,
            pass,
        },
    });

    const info = await transporter.sendMail({
        from,
        to: toEmail,
        subject: 'Your password reset code',
        text: `Your password reset code is: ${code}. It expires in 15 minutes.`,
    });

    return info;
}

const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ message: 'Email is required' });

        const [users] = await db.query('SELECT user_id, email FROM users WHERE email = ?', [email]);
        if (users.length === 0) return res.status(404).json({ message: 'User not found' });

        const user = users[0];
        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

        await db.query(
            `INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)`,
            [user.user_id, code, expiresAt]
        );

        try {
            await sendResetEmail(user.email, code);
        } catch (emailError) {
            await db.query(
                'DELETE FROM password_reset_tokens WHERE user_id = ? AND token = ?',
                [user.user_id, code]
            );
            throw emailError;
        }

        res.json({ message: 'Reset code sent to email' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: error.message || 'Unable to process reset request' });
    }
};

const verifyResetCode = async (req, res) => {
    try {
        const { email, code } = req.body;
        if (!email || !code) return res.status(400).json({ message: 'Email and code are required' });

        const [users] = await db.query('SELECT user_id FROM users WHERE email = ?', [email]);
        if (users.length === 0) return res.status(404).json({ message: 'User not found' });
        const user = users[0];

        const [tokens] = await db.query(
            'SELECT * FROM password_reset_tokens WHERE user_id = ? AND token = ? AND expires_at > NOW()',
            [user.user_id, code]
        );

        if (tokens.length === 0) return res.status(400).json({ message: 'Invalid or expired code' });

        res.json({ message: 'Code verified' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: error.message || 'Unable to verify code' });
    }
};

const resetPassword = async (req, res) => {
    try {
        const { email, code, new_password } = req.body;
        if (!email || !code || !new_password) return res.status(400).json({ message: 'Email, code and new password are required' });

        const [users] = await db.query('SELECT user_id FROM users WHERE email = ?', [email]);
        if (users.length === 0) return res.status(404).json({ message: 'User not found' });
        const user = users[0];

        const [tokens] = await db.query(
            'SELECT * FROM password_reset_tokens WHERE user_id = ? AND token = ? AND expires_at > NOW()',
            [user.user_id, code]
        );

        if (tokens.length === 0) return res.status(400).json({ message: 'Invalid or expired code' });

        const hashed = await bcrypt.hash(new_password, 10);
        await db.query('UPDATE users SET password_hash = ? WHERE user_id = ?', [hashed, user.user_id]);

        // remove used tokens
        await db.query('DELETE FROM password_reset_tokens WHERE user_id = ?', [user.user_id]);

        res.json({ message: 'Password updated successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: error.message || 'Unable to reset password' });
    }
};

module.exports = {
        registerUser,
        loginUser,
        forgotPassword,
        verifyResetCode,
        resetPassword,
};
