-- =====================================================
-- CREATE AUTHENTICATION FUNCTION
-- This function is needed for login to work
-- =====================================================

-- Function to authenticate users
CREATE OR REPLACE FUNCTION public.authenticate_userid_password(
  p_username TEXT,
  p_password TEXT
)
RETURNS TABLE (
  id UUID,
  username VARCHAR,
  name VARCHAR,
  email VARCHAR,
  role VARCHAR,
  is_active BOOLEAN,
  avatar TEXT
) AS $$
DECLARE
  v_user_id UUID;
  v_password_hash VARCHAR;
BEGIN
  -- Try to find user by username or email
  SELECT ua.id, ua.password_hash INTO v_user_id, v_password_hash
  FROM public.user_accounts ua
  WHERE (ua.username = p_username OR ua.email = p_username)
    AND ua.is_active = true;

  -- Check if user exists
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Invalid username or password';
  END IF;

  -- Verify password
  IF v_password_hash = crypt(p_password, v_password_hash) THEN
    -- Password is correct, return user data
    RETURN QUERY
    SELECT 
      ua.id,
      ua.username,
      ua.name,
      ua.email,
      ua.role,
      ua.is_active,
      ua.avatar
    FROM public.user_accounts ua
    WHERE ua.id = v_user_id;
  ELSE
    -- Password is incorrect
    RAISE EXCEPTION 'Invalid username or password';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.authenticate_userid_password(TEXT, TEXT) TO anon, authenticated;

-- =====================================================
-- CREATE USER ACCOUNT FOR TESTING
-- =====================================================

-- Insert a user account that matches your Supabase auth user
INSERT INTO public.user_accounts (
  id,
  username,
  password_hash,
  name,
  email,
  role,
  is_active
)
SELECT 
  id,
  'admin',
  crypt('Anuj@2005', gen_salt('bf')),
  'Admin User',
  email,
  'admin',
  true
FROM auth.users 
WHERE email = 'gaudasanuj35@gmail.com'
ON CONFLICT (email) DO UPDATE SET
  password_hash = crypt('Anuj@2005', gen_salt('bf')),
  role = 'admin',
  is_active = true;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Authentication function created!';
  RAISE NOTICE '✅ User account synced!';
  RAISE NOTICE '';
  RAISE NOTICE 'You can now login with:';
  RAISE NOTICE 'Email: gaudasanuj35@gmail.com';
  RAISE NOTICE 'Password: Anuj@2005';
END $$;
