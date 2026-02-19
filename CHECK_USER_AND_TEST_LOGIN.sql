-- =====================================================
-- DIAGNOSTIC: Check User Account and Test Login
-- Run this to see what's wrong
-- =====================================================

-- 1. Check if user exists in user_accounts table
SELECT 
  id,
  username,
  email,
  name,
  role,
  is_active,
  created_at
FROM public.user_accounts
WHERE email = 'gaudasanuj35@gmail.com' OR username = 'gaudasanuj35';

-- 2. Check if user exists in auth.users table
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at
FROM auth.users
WHERE email = 'gaudasanuj35@gmail.com';

-- 3. Check if authenticate_user function exists
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public' 
  AND routine_name = 'authenticate_user';

-- 4. Test the authentication function directly
SELECT * FROM public.authenticate_user('gaudasanuj35@gmail.com', 'Anuj@2005');

-- 5. If above fails, let's create a simple test user
-- Delete any existing test user first
DELETE FROM public.user_accounts WHERE username = 'testuser';

-- Create a simple test user
INSERT INTO public.user_accounts (
  username,
  password_hash,
  name,
  email,
  role,
  is_active
) VALUES (
  'testuser',
  crypt('test123', gen_salt('bf')),
  'Test User',
  'test@test.com',
  'admin',
  true
);

-- Test with the test user
SELECT * FROM public.authenticate_user('testuser', 'test123');

-- =====================================================
-- If you see results above, the function works!
-- Now let's fix your actual user account
-- =====================================================

-- Delete any duplicate accounts
DELETE FROM public.user_accounts 
WHERE email = 'gaudasanuj35@gmail.com';

-- Create your account fresh
INSERT INTO public.user_accounts (
  username,
  password_hash,
  name,
  email,
  role,
  is_active
) VALUES (
  'gaudasanuj35',
  crypt('Anuj@2005', gen_salt('bf')),
  'Anuj Gauda',
  'gaudasanuj35@gmail.com',
  'admin',
  true
);

-- Verify it was created
SELECT 
  id,
  username,
  email,
  name,
  role,
  is_active
FROM public.user_accounts
WHERE email = 'gaudasanuj35@gmail.com';

-- Test login again
SELECT * FROM public.authenticate_user('gaudasanuj35@gmail.com', 'Anuj@2005');

-- Also test with username
SELECT * FROM public.authenticate_user('gaudasanuj35', 'Anuj@2005');

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Diagnostic complete!';
  RAISE NOTICE '';
  RAISE NOTICE 'Check the results above:';
  RAISE NOTICE '1. User account should exist';
  RAISE NOTICE '2. Function should exist';
  RAISE NOTICE '3. Test login should return success=true';
  RAISE NOTICE '';
  RAISE NOTICE 'Try logging in with:';
  RAISE NOTICE 'Username: gaudasanuj35@gmail.com';
  RAISE NOTICE 'Password: Anuj@2005';
  RAISE NOTICE '';
  RAISE NOTICE 'OR';
  RAISE NOTICE 'Username: gaudasanuj35';
  RAISE NOTICE 'Password: Anuj@2005';
END $$;
