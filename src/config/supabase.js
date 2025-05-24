import dotenv from 'dotenv';
dotenv.config();
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
    console.error("SUPABASE_URL dan SUPABASE_ANON_KEY harus diatur di .env");
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

export default supabase;