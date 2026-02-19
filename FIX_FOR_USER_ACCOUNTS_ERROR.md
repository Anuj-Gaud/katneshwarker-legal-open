# ✅ Fix for "user_accounts does not exist" Error

## Problem

**Error:** `relation "public.user_accounts" does not exist`

**Cause:** You tried to run `PRODUCTION_ORANGE_THEME_COMPLETE.sql` first, but it requires base tables to exist first.

## Solution

Run the files in the CORRECT ORDER:

### Step 1: Run Base Setup FIRST ⭐

**File:** `RUN_THIS_FIRST_COMPLETE_SETUP.sql`

This creates:
- ✅ user_accounts table
- ✅ profiles table  
- ✅ cases table
- ✅ All 15+ base tables
- ✅ All relationships
- ✅ All security policies

**How to run:**
1. Open file: `RUN_THIS_FIRST_COMPLETE_SETUP.sql`
2. Copy all (Ctrl+A, Ctrl+C)
3. Go to Supabase SQL Editor
4. Paste (Ctrl+V)
5. Click "Run" (accept warning if shown)
6. Wait for success!

### Step 2: (Optional) Run Additional Features

**File:** `PRODUCTION_ORANGE_THEME_COMPLETE.sql`

This adds:
- ✅ audit_logs table
- ✅ case_notes table
- ✅ case_reminders table
- ✅ payment_plans table
- ✅ And more advanced features

**Note:** This step is OPTIONAL. The base setup is enough to get started!

## Quick Fix - What to Do Right Now

### Option 1: Use the New Complete File (Recommended)

1. **Open:** `RUN_THIS_FIRST_COMPLETE_SETUP.sql` (I just created this!)
2. **Copy all:** Ctrl+A, Ctrl+C
3. **Go to:** Supabase SQL Editor
4. **Paste:** Ctrl+V
5. **Run:** Click "Run" button
6. **Done!** All base tables created

### Option 2: Run Files in Order

1. First run: `RUN_THIS_FIRST_COMPLETE_SETUP.sql`
2. Then run: `PRODUCTION_ORANGE_THEME_COMPLETE.sql` (optional)

## File Locations

### ⭐ RUN THIS FIRST:
```
D:\katneshwarker.in\Katnaarehwarkar-main\RUN_THIS_FIRST_COMPLETE_SETUP.sql
```

### Run this second (optional):
```
D:\katneshwarker.in\Katnaarehwarkar-main\PRODUCTION_ORANGE_THEME_COMPLETE.sql
```

## What Each File Does

### RUN_THIS_FIRST_COMPLETE_SETUP.sql
Creates ALL essential tables:
- user_accounts (users)
- profiles (Supabase auth)
- cases (legal cases)
- counsel (lawyers)
- appointments (calendar)
- transactions (payments)
- tasks (to-do items)
- attendance (staff tracking)
- expenses (office expenses)
- books (library)
- storage_locations (file storage)
- case_files (documents)
- notifications (alerts)
- And more...

### PRODUCTION_ORANGE_THEME_COMPLETE.sql
Adds advanced features:
- audit_logs (track changes)
- case_notes (detailed notes)
- case_reminders (alerts)
- case_timeline (history)
- payment_plans (installments)
- client_communications (messages)
- Analytics views
- Helper functions

## After Running Successfully

You'll see:
```
✅ Database setup complete!
✅ All tables created successfully
✅ RLS policies enabled
✅ Default data inserted
```

## Next Steps

1. ✅ Run `RUN_THIS_FIRST_COMPLETE_SETUP.sql`
2. ✅ Create admin user (see below)
3. ✅ Restart dev server
4. ✅ Login and use app!

## Create Admin User

After running the setup SQL, create your admin user:

```sql
-- Run this in Supabase SQL Editor
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token,
  email_change, email_change_token_new, recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(), 'authenticated', 'authenticated',
  'admin@example.com', -- ← CHANGE THIS
  crypt('admin123', gen_salt('bf')), -- ← CHANGE THIS
  NOW(),
  '{"provider":"email","providers":["email"],"role":"admin"}',
  '{"name":"Admin User","role":"admin"}',
  NOW(), NOW(), '', '', '', ''
);

INSERT INTO public.profiles (id, email, name, role, is_active, created_at, updated_at)
SELECT id, email, 'Admin User', 'admin', true, NOW(), NOW()
FROM auth.users WHERE email = 'admin@example.com'; -- ← MATCH EMAIL
```

## Summary

**Problem:** Wrong file order
**Solution:** Run `RUN_THIS_FIRST_COMPLETE_SETUP.sql` first
**Time:** 5 minutes
**Result:** All tables created, ready to use!

---

**Status:** ✅ Fixed
**File to use:** RUN_THIS_FIRST_COMPLETE_SETUP.sql
**Action:** Copy and run in Supabase SQL Editor
