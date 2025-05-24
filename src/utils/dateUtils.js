// Format tanggal menjadi ISO string (YYYY-MM-DD)
export const getFormattedDateISO = (date) => date.toISOString().split('T')[0];

// Hitung rentang tanggal berdasarkan periode
export const getDateRange = (period, date_start, date_end) => {
    const today = new Date();
    let startDate, endDate;

    if (date_start && date_end) {
        startDate = new Date(date_start);
        endDate = new Date(date_end);
    } else if (period === 'weekly') {
        startDate = new Date(today.setDate(today.getDate() - today.getDay() + (today.getDay() === 0 ? -6 : 1))); // Monday
        endDate = new Date(startDate);
        endDate.setDate(startDate.getDate() + 6); // Sunday
    } else if (period === 'monthly') {
        startDate = new Date(today.getFullYear(), today.getMonth(), 1);
        endDate = new Date(today.getFullYear(), today.getMonth() + 1, 0);
    } else if (period === 'last_7_days') {
        endDate = new Date();
        startDate = new Date();
        startDate.setDate(endDate.getDate() - 6);
    } else if (period === 'last_30_days') {
        endDate = new Date();
        startDate = new Date();
        startDate.setDate(endDate.getDate() - 29);
    } else {
        throw new Error("Invalid period or date range");
    }

    return { startDate, endDate };
};

// Hitung target penyelesaian habit berdasarkan frekuensi dan rentang tanggal
export const calculateTargetCompletions = (habit, startDate, endDate) => {
    let target = 0;
    let currentDate = new Date(startDate);
    const end = new Date(endDate);

    while (currentDate <= end) {
        if (habit.frequency_type === 'daily') {
            target++;
        } else if (habit.frequency_type === 'specific_days_of_week' && habit.days_of_week) {
            const currentDayOfWeek = currentDate.getDay(); // 0 (Sun) - 6 (Sat)
            if (habit.days_of_week.includes(currentDayOfWeek)) {
                target++;
            }
        }
        currentDate.setDate(currentDate.getDate() + 1);
    }
    return target;
};