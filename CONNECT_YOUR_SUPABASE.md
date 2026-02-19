# 🔗 Connect Your Own Supabase Project

## Quick 3-Step Process (5 minutes)

### Step 1: Get Your Credentials from Supabase Dashboard

#### 1.1 Open Your Supabase Project
```
Go to: https://supabase.com/dashboard
→ Sign in to your account
→ Click on your project
```

#### 1.2 Navigate to API Settings
```
In left sidebar:
→ Click "Settings" (⚙️ gear icon)
→ Click "API" under Project Settings
```

#### 1.3 Copy Your Credentials

You'll see a page with these sections:

**Project URL**
```
Example: https://abcdefghijklmnop.supabase.co
         ↑ Copy this entire URL
```

**Project API keys**
```
anon public: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBh...
             ↑ Click the copy icon to copy this key
```

---

### Step 2: Update Your .env File

#### 2.1 Open the .env File
The file is already open in your editor: `Katnaarehwarkar-main/.env`

#### 2.2 Replace the Placeholder Values

**Before (current):**
```env
VITE_SUPABASE_URL=PASTE_YOUR_PROJECT_URL_HERE
VITE_SUPABASE_ANON_KEY=PASTE_YOUR_ANON_KEY_HERE
```

**After (with your credentials):**
```env
VITE_SUPABASE_URL=https://abcdefghijklmnop.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY4OTU2NTY3MCwiZXhwIjoyMDA1MTQxNjcwfQ.xxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### 2.3 Save the File
Press `Ctrl+S` (Windows) or `Cmd+S` (Mac)

---

### Step 3: Restart Development Server

#### 3.1 Stop Current Server
In your terminal, press:
```
Ctrl+C
```

#### 3.2 Start Server Again
```bash
npm run dev
```

#### 3.3 Verify Connection
- Browser should open at http://localhost:3000
- You should see the login page (not the setup error page)
- If you see the setup error, check your credentials

---

## 🗄️ Step 4: Setup Your Database (5 minutes)

Your Supabase project needs the database schema for this application.

### Option A: Use Complete Setup SQL (Recommended)

1. **Open Supabase SQL Editor**
   ```
   In your Supabase Dashboard:
   → Click "SQL Editor" in left sidebar
   → Click "New Query"
   ```

2. **Copy the SQL Script**
   ```
   Open file: PRODUCTION_ORANGE_THEME_COMPLETE.sql
   → Select all (Ctrl+A)
   → Copy (Ctrl+C)
   ```

3. **Run the Script**
   ```
   In Supabase SQL Editor:
   → Paste the SQL (Ctrl+V)
   → Click "Run" button (or press Ctrl+Enter)
   → Wait for "Success" message
   ```

### Option B: Use Migration Files (Advanced)

If you prefer to run migrations individually:

```bash
# In your terminal
cd Katnaarehwarkar-main/supabase/migrations

# Then run each migration file in Supabase SQL Editor in order:
# 001_add_user_accounts.sql
# 002_populate_courts_and_case_types.sql
# ... and so on
```

---

## 👤 Step 5: Create Your Admin User (2 minutes)

### Option A: Using Supabase Auth UI (Easiest)

1. **Enable Email Auth**
   ```
   Supabase Dashboard → Authentication → Providers
   → Make sure "Email" is enabled
   ```

2. **Create User via Dashboard**
   ```
   Supabase Dashboard → Authentication → Users
   → Click "Add user" → "Create new user"
   → Enter email and password
   → Click "Create user"
   ```

3. **Make User Admin**
   ```
   Supabase Dashboard → SQL Editor → New Query
   → Paste this SQL (replace the email):
   ```
   ```sql
   -- Update user role to admin
   UPDATE public.profiles 
   SET role = 'admin' 
   WHERE email = 'your-email@example.com';
   ```

### Option B: Using SQL (Complete)

Run this in Supabase SQL Editor:

```sql
-- Create admin user with auth
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
  'admin@yourcompany.com', -- ← CHANGE THIS
  crypt('YourSecurePassword123', gen_salt('bf')), -- ← CHANGE THIS
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

-- Create profile for the admin user
INSERT INTO public.profiles (id, email, name, role, is_active, created_at, updated_at)
SELECT 
  id,
  email,
  'Admin User', -- ← CHANGE THIS
  'admin',
  true,
  NOW(),
  NOW()
FROM auth.users
WHERE email = 'admin@yourcompany.com'; -- ← MATCH EMAIL ABOVE
```

---

## ✅ Verification Checklist

After completing all steps, verify:

- [ ] .env file has your actual Supabase URL (not placeholder)
- [ ] .env file has your actual anon key (not placeholder)
- [ ] Dev server restarted successfully
- [ ] Browser shows login page (not setup error)
- [ ] Database tables created (check in Supabase Table Editor)
- [ ] Admin user created (check in Authentication → Users)
- [ ] Can login with admin credentials
- [ ] Dashboard loads after login

---

## 🐛 Troubleshooting

### Issue: Still seeing "Setup Required" error page

**Cause:** .env file still has placeholder values

**Fix:**
1. Open `.env` file
2. Make sure values don't contain "PASTE_YOUR" or "your-project-id"
3. Values should be actual URLs and keys from your Supabase project
4. Save file and restart server

### Issue: "Invalid API key" or "Project not found"

**Cause:** Wrong credentials or typo

**Fix:**
1. Go back to Supabase Dashboard → Settings → API
2. Copy credentials again (use copy button to avoid typos)
3. Paste into .env file
4. Make sure no extra spaces or line breaks
5. Save and restart

### Issue: Login page shows but can't login

**Cause:** Database not set up or no admin user

**Fix:**
1. Check Supabase → Table Editor → See if tables exist
2. If no tables, run the SQL setup script (Step 4)
3. Create admin user (Step 5)
4. Try login again

### Issue: "relation does not exist" errors

**Cause:** Database schema not created

**Fix:**
1. Run the complete SQL setup script
2. Check Supabase → SQL Editor for error messages
3. Make sure script completed successfully

### Issue: Can login but see errors on dashboard

**Cause:** Missing data or incomplete setup

**Fix:**
1. Check browser console (F12) for specific errors
2. Verify all database tables were created
3. Check Supabase logs for errors

---

## 📊 What Gets Created in Your Supabase

When you run the setup SQL, these will be created:

### Tables (25+)
- `profiles` - User profiles
- `cases` - Legal cases
- `appointments` - Calendar appointments
- `counsel` - Lawyers/counsel
- `transactions` - Financial transactions
- `tasks` - Task management
- `attendance` - Attendance tracking
- `expenses` - Expense tracking
- `books` - Library books
- `library_locations` - Library storage
- `storage_locations` - File storage
- `sofa_items` - Sofa compartment items
- `case_files` - Case documents
- `notifications` - User notifications
- And more...

### Views (5+)
- `case_performance_metrics`
- `pending_reminders`
- `case_timeline_with_details`
- `payment_plan_status`
- `communication_summary`

### Functions (4+)
- `get_case_summary()`
- `get_upcoming_reminders()`
- `calculate_case_age()`
- `get_case_statistics()`

### Security
- Row Level Security (RLS) policies
- User authentication
- Role-based access control

---

## 🎯 Quick Reference

### Your .env File Format
```env
VITE_SUPABASE_URL=https://[your-project-ref].supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.[long-string]
```

### Where to Find Things in Supabase

| What You Need | Where to Find It |
|---------------|------------------|
| Project URL | Settings → API → Project URL |
| Anon Key | Settings → API → Project API keys → anon public |
| View Tables | Table Editor (left sidebar) |
| Run SQL | SQL Editor (left sidebar) |
| View Users | Authentication → Users |
| Check Logs | Logs (left sidebar) |

### Commands

```bash
# Stop server
Ctrl+C

# Start server
npm run dev

# Build for production
npm run build
```

---

## 🎉 Success!

Once you complete these steps:

1. ✅ Your app connects to YOUR Supabase project
2. ✅ All your data is in YOUR database
3. ✅ You have full control over everything
4. ✅ You can login and use the application

---

## 📞 Need Help?

### Common Questions

**Q: Do I need a paid Supabase plan?**
A: No! The free tier is sufficient for development and small deployments.

**Q: Can I use an existing Supabase project?**
A: Yes! Just make sure to run the setup SQL to create the required tables.

**Q: Will this delete my existing data?**
A: No! The SQL script only creates new tables. Existing data is safe.

**Q: Can I change the credentials later?**
A: Yes! Just update the .env file and restart the server.

**Q: Is my data secure?**
A: Yes! Supabase uses PostgreSQL with Row Level Security (RLS) enabled.

---

**Total Time:** ~10-15 minutes
**Difficulty:** Easy
**Result:** Your app connected to YOUR Supabase project!

**Let's do this! 🚀**
