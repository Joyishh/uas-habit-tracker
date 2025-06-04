import cron from "node-cron";
import supabase from "../config/supabase.js";
import admin from "../config/firebaseAdmin.js";
import dayjs from "dayjs";

// Atur jadwal: setiap menit untuk pengujian
cron.schedule("0 9,15,21 * * *", async () => {
  console.log("[CRON] Mengecek unfinished habits dan mengirim notifikasi...");
  const { data: users, error: userError } = await supabase.from("users").select("id");
  if (userError) {
    console.error("Gagal mengambil users:", userError.message);
    return;
  }
  for (const user of users) {
    const { data: devices, error: deviceError } = await supabase
      .from("user_devices")
      .select("fcm_token")
      .eq("user_id", user.id);
    if (deviceError || !devices || devices.length === 0) continue;

    // Ambil semua habit user
    const { data: habits, error: habitError } = await supabase
      .from("habits")
      .select("*")
      .eq("user_id", user.id);
    if (habitError || !habits || habits.length === 0) continue;

    const today = dayjs().format("YYYY-MM-DD");
    const dayOfWeek = dayjs().day(); // 0 = Minggu, 1 = Senin, dst
    const unfinishedHabits = [];
    for (const habit of habits) {
      let shouldDoToday = false;
      if (habit.frequency_type === "daily") {
        shouldDoToday = true;
      } else if (habit.frequency_type === "specific_days_of_week" && Array.isArray(habit.days_of_week)) {
        shouldDoToday = habit.days_of_week.includes(dayOfWeek);
      }
      // Tambahkan logika lain jika ada frequency_type lain
      if (!shouldDoToday) continue;

      // Cek apakah sudah check-in hari ini
      const { data: entry } = await supabase
        .from("habit_entries")
        .select("id")
        .eq("habit_id", habit.id)
        .eq("user_id", user.id)
        .eq("entry_date", today)
        .maybeSingle();
      if (!entry) {
        unfinishedHabits.push(habit);
      }
    }
    if (unfinishedHabits.length === 0) continue;

    for (const device of devices) {
      try {
        await admin.messaging().send({
          token: device.fcm_token,
          notification: {
            title: "Habit Reminder",
            body: "Ada habit yang belum selesai hari ini!",
          },
          data: { type: "habit_reminder" },
        });
        console.log(`[CRON] Notifikasi dikirim ke user ${user.id}`);
      } catch (err) {
        console.error(`[CRON] Gagal kirim notifikasi ke user ${user.id}:`, err.message);
      }
    }
  }
},{
    timezone: "Asia/Jakarta"
});
