import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import supabase from './src/config/supabase.js';

import userRoute from './src/routes/userRoute.js';
import authRoute from './src/routes/authRoute.js';
import habitRoute from './src/routes/habitRoute.js';

dotenv.config();
const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());
app.use(cors());

app.get('/', (req, res) => {
    res.json({ message: 'API is running' });
});

// routes
app.use('/users', userRoute);
app.use('/auth', authRoute);
app.use('/habit', habitRoute);

(async () => {
    try {
        const { error } = await supabase.from('users').select('*').limit(1);
        if (error) {
            console.error('Supabase connection failed:', error.message);
        } else {
            console.log('Supabase connection successful.');
        }
    } catch (err) {
        console.error('Supabase connection failed:', err.message);
    }
})();

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});