import supabase from '../config/supabase.js';
import { getFormattedDateISO, calculateTargetCompletions } from '../utils/dateUtils.js';

// Hitung tingkat penyelesaian habit per bulan
export const getCompletionRates = async (req, res) => {
  const userId = req.user.id;
  const { year, month } = req.query;

  if (!year || !month) {
    return res.status(400).json({ error: 'year and month are required' });
  }

  const numYear = parseInt(year);
  const numMonth = parseInt(month);

  if (isNaN(numYear) || isNaN(numMonth) || numMonth < 1 || numMonth > 12) {
    return res.status(400).json({ error: 'Invalid year or month' });
  }

  // Hitung tanggal awal dan akhir bulan
  const startDate = new Date(numYear, numMonth - 1, 1);
  const endDate = new Date(numYear, numMonth, 0);

  const startDateString = getFormattedDateISO(startDate);
  const endDateString = getFormattedDateISO(endDate);

  try {
    const { data: habits, error: habitsError } = await supabase.from('habits').select('id, name, frequency_type, days_of_week').eq('user_id', userId).eq('is_archived', false);

    if (habitsError) throw habitsError;

    const { data: entries, error: entriesError } = await supabase.from('habit_entries').select('habit_id, entry_date').eq('user_id', userId).gte('entry_date', startDateString).lte('entry_date', endDateString);

    if (entriesError) throw entriesError;

    const completionStats = habits.map((habit) => {
      const target_completions = calculateTargetCompletions(habit, startDate, endDate);
      const actual_completions = entries.filter((entry) => entry.habit_id === habit.id).length;
      const completion_percentage = target_completions > 0 ? (actual_completions / target_completions) * 100 : 0;

      return {
        habit_id: habit.id,
        habit_name: habit.name,
        frequency_type: habit.frequency_type,
        days_of_week: habit.days_of_week,
        target_completions,
        actual_completions,
        completion_percentage: parseFloat(completion_percentage.toFixed(1)),
        period_start: startDateString,
        period_end: endDateString,
      };
    });

    res.json(completionStats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Hitung data untuk pie chart per bulan
export const getPieChartStats = async (req, res) => {
  const userId = req.user.id;
  const { year, month } = req.query;

  if (!year || !month) {
    return res.status(400).json({ error: 'year and month are required' });
  }

  const numYear = parseInt(year);
  const numMonth = parseInt(month);

  if (isNaN(numYear) || isNaN(numMonth) || numMonth < 1 || numMonth > 12) {
    return res.status(400).json({ error: 'Invalid year or month' });
  }

  // Hitung tanggal awal dan akhir bulan
  const startDate = new Date(numYear, numMonth - 1, 1);
  const endDate = new Date(numYear, numMonth, 0);

  const startDateString = getFormattedDateISO(startDate);
  const endDateString = getFormattedDateISO(endDate);

  try {
    const { data: habits, error: habitsError } = await supabase.from('habits').select('id, name').eq('user_id', userId).eq('is_archived', false);

    if (habitsError) throw habitsError;

    const { data: entries, error: entriesError } = await supabase.from('habit_entries').select('habit_id').eq('user_id', userId).gte('entry_date', startDateString).lte('entry_date', endDateString);

    if (entriesError) throw entriesError;

    if (!entries || entries.length === 0) {
      return res.json([]);
    }

    const habitCompletions = {};
    let totalCompletionsAllHabits = 0;

    entries.forEach((entry) => {
      habitCompletions[entry.habit_id] = (habitCompletions[entry.habit_id] || 0) + 1;
      totalCompletionsAllHabits++;
    });

    const pieChartData = habits.map((habit) => {
      const actual_completions = habitCompletions[habit.id] || 0;
      const percentage = totalCompletionsAllHabits > 0 ? (actual_completions / totalCompletionsAllHabits) * 100 : 0;
      return {
        habit_id: habit.id,
        name: habit.name,
        actual_completions,
        percentage_overall_completions: parseFloat(percentage.toFixed(1)),
      };
    });

    res.json(pieChartData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
