import supabase from '../config/supabase.js';

export const getAllUser = async (req, res) => {
    const { data, error } = await supabase
        .from('users')
        .select('id, username, email, created_at');
    if (error) return res.status(400).json({ error: error.message });
    res.json(data);
};

export const getUserById = async (req, res) => {
    const { id } = req.params;
    const { data, error } = await supabase
        .from('users')
        .select('id, username, email, created_at')
        .eq('id', id)
        .single();
    if (error || !data) return res.status(404).json({ error: "User not found" });
    res.json(data);
};