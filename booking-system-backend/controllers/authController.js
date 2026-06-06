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

module.exports = {
    registerUser,
    loginUser
};