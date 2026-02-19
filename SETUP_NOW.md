# 🚨 BLANK SCREEN FIX - Setup Instructions

## Why You're Seeing a Blank Screen

Your application is trying to connect to Supabase (the database), but the connection credentials are missing. The app throws an error and stops loading.

---

## ✅ SOLUTION - 3 Steps to Fix

### Step 1: Create a Supabase Project (5 minutes)

1. Go to https://supabase.com
2. Click "Start your project" or "Sign In"
3. Create a new project:
   - Project Name: `katneshwarkar-office` (or any name)
   - Database Password: Create a strong password (SAVE THIS!)
   - Region: Choose closest to you
4. Wait 2-3 minutes for project to be created

### Step 2: Get Your Credentials (2 minutes)

1. In your Supabase project dashboard
2. Click on "Settings" (gear icon) in the left sidebar
3. Click on "API" under Project Settings
4. You'll see:
   - **Project URL** (looks like: https://xxxxx.supabase.co)
   - **anon public** key (long string starting with "eyJ...")
5. Keep this page open!

### Step 3: Update Your .env File (1 minute)

1. Open the file: `Katnaarehwarkar-main/.env`
2. Replace the placeholder values:

```env
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

3. Save the file

---

## 🗄️ Step 4: Setup Database (5 minutes)

1. In Supabase Dashboard, click "SQL Editor" in left sidebar
2. Click "New Query"
3. Open the file: `PRODUCTION_ORANGE_THEME_COMPLETE.sql`
4. Copy ALL the content
5. Paste into Supabase SQL Editor
6. Click "Run" button
7. Wait for "Success" message

---

## 🚀 Step 5: Start the Application

Run these commands in your terminal:

```bash
cd Katnaarehwarkar-main
npm run dev
```

The app should now open in your browser at http://localhost:3000

---

## 🔐 Step 6: Create Your First User

Since the database is fresh, you need to create an admin user:

1. In Supabase Dashboard, go to "SQL Editor"
2. Run this command (replace with your details):

```sql
-- Create admin user
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@example.com', -- CHANGE THIS
  crypt('admin123', gen_salt('bf')), -- CHANGE THIS PASSWORD
  NOW(),
  '{"provider":"email","providers":["email"],"role":"admin"}',
  '{"name":"Admin User","role":"admin"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);

-- Create profile for the user
INSERT INTO public.profiles (id, email, name, role, created_at, updated_at)
SELECT 
  id,
  email,
  'Admin User', -- CHANGE THIS
  'admin',
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'admin@example.com'; -- MATCH THE EMAIL ABOVE
```

3. Now you can login with:
   - Email: admin@example.com (or what you set)
   - Password: admin123 (or what you set)

---

## ✅ Verification Checklist

- [ ] Supabase project created
- [ ] .env file updated with real credentials
- [ ] Database setup SQL executed successfully
- [ ] npm run dev started without errors
- [ ] Browser shows login page (not blank screen)
- [ ] Admin user created
- [ ] Can login successfully

---

## 🐛 Still Having Issues?

### Issue: "Missing Supabase environment variables"
**Fix:** Make sure .env file has correct values and restart dev server

### Issue: "Failed to fetch" or network errors
**Fix:** Check your Supabase URL is correct and project is active

### Issue: "Invalid login credentials"
**Fix:** Make sure you created the admin user in Step 6

### Issue: Blank screen with no errors
**Fix:** 
1. Open browser console (F12)
2. Check for errors
3. Clear browser cache (Ctrl+Shift+Delete)
4. Hard refresh (Ctrl+Shift+R)

### Issue: npm vulnerabilities
**Fix:** These are dev dependencies and won't affect the app. You can ignore them for now.

---

## 📞 Quick Reference

### Your .env file should look like:
```env
VITE_SUPABASE_URL=https://abcdefgh.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODk1NjU2NzAsImV4cCI6MjAwNTE0MTY3MH0.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Commands to run:
```bash
# Install dependencies (if not done)
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

---

## 🎉 Success!

Once you complete these steps, you should see:
1. Login page (not blank screen)
2. Ability to login with your admin credentials
3. Dashboard with orange theme
4. All features working

---

**Total Time: ~15 minutes**
**Difficulty: Easy**
**Next: Login and explore your application!**
