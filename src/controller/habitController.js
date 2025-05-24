import supabase from "../config/supabase.js";

export const getAllHabit = async (req, res) => {
    const userId = req.user.id;
    const { data, error } = await supabase
        .from("habits")
        .select("id, name, description, frequency_type, days_of_week, color_hex, created_at")
        .eq("user_id", userId)
    if (error) return res.status(400).json({ error: error.message });
    res.json(data);
}

export const getHabitById = async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const { data, error } = await supabase
        .from("habits")
        .select("id, name, description, frequency_type, days_of_week, color_hex, created_at")
        .eq("id", id)
        .eq("user_id", userId)
        .single();
    if (error || !data) return res.status(404).json({ error: "Habit not found" });
    res.json(data);
};

export const createHabit = async (req, res) => {
    const userId = req.user.id;
    const {
        name,
        description,
        frequency_type,
        days_of_week,
        color_hex
    } = req.body;

    if (!name || !frequency_type) {
        return res.status(400).json({ error: "name and frequency_type are required" });
    }

    if (frequency_type === 'specific_days_of_week') {
        if (!Array.isArray(days_of_week) || days_of_week.length === 0) {
            return res.status(400).json({ error: "days_of_week is required for specific_days_of_week" });
        }
    }

    const habitData = {
        name,
        description,
        frequency_type,
        color_hex: color_hex || "#FFFFFF",
        user_id: userId,
        days_of_week: frequency_type === 'specific_days_of_week' ? days_of_week : null
    };

    const { data, error } = await supabase
        .from("habits")
        .insert([habitData])
        .select("id, name, description, frequency_type, days_of_week, color_hex, created_at")
        .single();

    if (error) return res.status(400).json({ error: error.message });
    res.status(201).json(data);
};

export const updateHabit = async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const { name, description, color_hex, frequency_type, days_of_week } = req.body;
    if (!name || !description || !color_hex || !frequency_type || !days_of_week) return res.status(400).json({ error: "All fields required" });

    const { data, error } = await supabase
        .from("habits")
        .update({ name, description, color_hex, frequency_type, days_of_week })
        .eq("id", id)
        .eq("user_id", userId)
        .select("id, name, description, frequency_type, days_of_week, color_hex, created_at")
        .single();

    if (error || !data) return res.status(404).json({ error: "Habit not found" });
    res.json(data);
}

export const deleteHabit = async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const { data, error } = await supabase
        .from("habits")
        .delete()
        .eq("id", id)
        .eq("user_id", userId)
        .select("id, name, description, created_at")
        .single();

    if (error || !data) return res.status(404).json({ error: "Habit not found" });
    res.json({ message: "Habit deleted successfully", habit: data });
}

export const habitCheckIn = async (req, res) => {
    const userId = req.user.id;
    const { id } = req.params;
    const { date } = req.body;

    if (!date) return res.status(400).json({ error: "Date is required" });

    const { data, error } = await supabase
        .from("habit_entries")
        .insert([{ habit_id: id, user_id: userId, entry_date: date }])
        .select("id, habit_id, user_id, entry_date, status")
        .single();

    if (error) return res.status(400).json({ error: error.message });
    res.status(201).json({ message: "Check-in successful", entry: data });
};

