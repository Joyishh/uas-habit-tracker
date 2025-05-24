import supabase from '../config/supabase.js';
import argon2 from 'argon2';
import jwt from 'jsonwebtoken';

export const registerUser = async (req, res) => {
    const { username, email, password } = req.body;
    if (!username || !email || !password) return res.status(400).json({ error: "All fields required" });

    const hash = await argon2.hash(password);
    const { data, error } = await supabase
        .from('users')
        .insert([{ username, email, password_hash: hash }])
        .select('id, username, email')
        .single();

    if (error) return res.status(400).json({ error: error.message });
    res.status(201).json({ message: "Account Created" , user: data });
};

export const loginUser = async (req, res) => {
    const { email, password } = req.body;
    const { data: user, error } = await supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .single();

    if (error || !user) return res.status(401).json({ error: "Invalid credentials" });
    const valid = await argon2.verify(user.password_hash, password);
    if (!valid) return res.status(401).json({ error: "Invalid credentials" });

    const token = jwt.sign({ id: user.id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1d' });
    res.json({ message: "Login succesfully", token, user: { id: user.id, username: user.username, email: user.email } });
};

export const logoutUser = async (req, res) => {
    res.json({ message: "Logout successful" });
}
