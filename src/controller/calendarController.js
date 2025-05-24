import supabase from '../config/supabase.js';
import { getFormattedDateISO, calculateTargetCompletions } from '../utils/dateUtils.js'; // Asumsi calculateTargetCompletions bisa dipakai untuk cek 'due'

export const monthOverview = async (req, res) => {
  const userId = req.user.id;
  const { year, month } = req.query;

  if (!year || !month) {
    return res.status(400).json({ error: 'Year and month are required query parameters.' });
  }

  const numYear = parseInt(year);
  const numMonth = parseInt(month);

  if (isNaN(numYear) || isNaN(numMonth) || numMonth < 1 || numMonth > 12) {
    return res.status(400).json({ error: 'Invalid year or month format.' });
  }

  try {
    const { data: habits, error: habitsError } = await supabase.from('habits').select('id, name, color_hex, frequency_type, days_of_week').eq('user_id', userId).eq('is_archived', false);

    if (habitsError) throw habitsError;
    if (!habits) {
      return res.json({ year: numYear, month: numMonth, days_with_habits: [] });
    }

    const days_with_habits = [];
    const daysInMonth = new Date(numYear, numMonth, 0).getDate();

    for (let day = 1; day <= daysInMonth; day++) {
      const currentDate = new Date(numYear, numMonth - 1, day);
      const scheduled_habits_preview = [];

      for (const habit of habits) {
        let isDueToday = false;
        if (habit.frequency_type === 'daily') {
          isDueToday = true;
        } else if (habit.frequency_type === 'specific_days_of_week' && habit.days_of_week) {
          const currentDayOfWeek = currentDate.getDay();
          if (habit.days_of_week.includes(currentDayOfWeek)) {
            isDueToday = true;
          }
        }

        if (isDueToday) {
          scheduled_habits_preview.push({
            id: habit.id,
            name: habit.name,
            color_hex: habit.color_hex,
          });
        }
      }

      if (scheduled_habits_preview.length > 0) {
        days_with_habits.push({
          date: getFormattedDateISO(currentDate),
          scheduled_habits_preview,
        });
      }
    }

    res.json({ year: numYear, month: numMonth, days_with_habits });
  } catch (error) {
    console.error('Error in monthOverview:', error);
    res.status(500).json({ error: error.message });
  }
};

export const dayDetails = async (req, res) => {
  const userId = req.user.id;
  const { date } = req.query;

  if (!date) {
    return res.status(400).json({ error: 'Date query parameter is required.' });
  }

  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    return res.status(400).json({ error: 'Invalid date format. Use YYYY-MM-DD.' });
  }

  const selectedDateObject = new Date(date);
  if (isNaN(selectedDateObject.getTime())) {
    return res.status(400).json({ error: 'Invalid date value.' });
  }

  try {
    const { data: allUserHabits, error: habitsError } = await supabase.from('habits').select('id, name, description, color_hex, frequency_type, days_of_week').eq('user_id', userId).eq('is_archived', false);

    if (habitsError) throw habitsError;
    if (!allUserHabits) {
      return res.json({ selected_date: date, scheduled_habits_details: [] });
    }

    const scheduled_habits_for_day = [];
    for (const habit of allUserHabits) {
      let isDueToday = false;
      if (habit.frequency_type === 'daily') {
        isDueToday = true;
      } else if (habit.frequency_type === 'specific_days_of_week' && habit.days_of_week) {
        const parts = date.split('-');
        const localSelectedDate = new Date(parts[0], parts[1] - 1, parts[2]);
        const currentDayOfWeek = localSelectedDate.getDay();

        if (habit.days_of_week.includes(currentDayOfWeek)) {
          isDueToday = true;
        }
      }
      if (isDueToday) {
        scheduled_habits_for_day.push(habit);
      }
    }

    if (scheduled_habits_for_day.length === 0) {
      return res.json({ selected_date: date, scheduled_habits_details: [] });
    }

    const scheduledHabitIds = scheduled_habits_for_day.map((h) => h.id);

    const { data: entries, error: entriesError } = await supabase.from('habit_entries').select('habit_id, id').eq('user_id', userId).eq('entry_date', date).in('habit_id', scheduledHabitIds);

    if (entriesError) throw entriesError;

    const entriesMap = new Map();
    if (entries) {
      entries.forEach((entry) => {
        entriesMap.set(entry.habit_id, entry.id);
      });
    }

    const scheduled_habits_details = scheduled_habits_for_day.map((habit) => ({
      habit_id: habit.id,
      name: habit.name,
      description: habit.description,
      color_hex: habit.color_hex,
      is_checked_in: entriesMap.has(habit.id),
      entry_id: entriesMap.get(habit.id) || null,
    }));

    res.json({ selected_date: date, scheduled_habits_details });
  } catch (error) {
    console.error('Error in dayDetails:', error);
    res.status(500).json({ error: error.message });
  }
};
