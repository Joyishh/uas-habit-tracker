import supabase from "../config/supabase.js";

export const registerDeviceToken = async (req, res) => {
  const userId = req.user.id;
  const { fcm_token, device_info } = req.body;

  if (!fcm_token) {
    return res.status(400).json({ error: "fcm_token is required" });
  }

  // Upsert: jika token sudah ada untuk user, update device_info
  const { data, error } = await supabase
    .from("user_devices")
    .upsert([
      { user_id: userId, fcm_token, device_info }
    ], { onConflict: ["user_id", "fcm_token"] })
    .select();

  if (error) return res.status(400).json({ error: error.message });
  res.json({ message: "Device token registered", data });
};
