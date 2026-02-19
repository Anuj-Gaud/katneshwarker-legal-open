-- =====================================================
-- CREATE ALL AUTHENTICATION & USER MANAGEMENT FUNCTIONS
-- Run this in Supabase SQL Editor
-- =====================================================

-- 1. AUTHENTICATE USER FUNCTION
CREATE OR REPLACE FUNCTION public.authenticate_user(
  p_username TEXT,
  p_password TEXT
)
RETURNS TABLE (
  success BOOLEAN,
  user_id UUID,
  username VARCHAR,
  name VARCHAR,
  email VARCHAR,
  role VARCHAR,
  is_active BOOLEAN,
  error_message TEXT
) AS $$
DECLARE
  v_user RECORD;
BEGIN
  -- Try to find user by username or email
  SELECT * INTO v_user
  FROM public.user_accounts
  WHERE (user_accounts.username = p_username OR user_accounts.email = p_username)
    AND user_accounts.is_active = true;

  -- Check if user exists
  IF v_user.id IS NULL THEN
    RETURN QUERY SELECT false, NULL::UUID, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::BOOLEAN, 'Invalid username or password'::TEXT;
    RETURN;
  END IF;

  -- Verify password
  IF v_user.password_hash = crypt(p_password, v_user.password_hash) THEN
    -- Password is correct, return user data
    RETURN QUERY SELECT 
      true,
      v_user.id,
      v_user.username,
      v_user.name,
      v_user.email,
      v_user.role,
      v_user.is_active,
      NULL::TEXT;
  ELSE
    -- Password is incorrect
    RETURN QUERY SELECT false, NULL::UUID, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::BOOLEAN, 'Invalid username or password'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. GET ALL USERS FUNCTION
CREATE OR REPLACE FUNCTION public.get_all_users()
RETURNS SETOF public.user_accounts AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM public.user_accounts
  WHERE is_active = true
  ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. CREATE USER ACCOUNT FUNCTION
CREATE OR REPLACE FUNCTION public.create_user_account(
  p_name TEXT,
  p_email TEXT,
  p_username TEXT,
  p_password TEXT,
  p_role TEXT,
  p_created_by UUID
)
RETURNS TABLE (
  success BOOLEAN,
  user_id UUID,
  error_message TEXT
) AS $$
DECLARE
  v_new_user_id UUID;
BEGIN
  -- Check if username already exists
  IF EXISTS (SELECT 1 FROM public.user_accounts WHERE username = p_username) THEN
    RETURN QUERY SELECT false, NULL::UUID, 'Username already exists'::TEXT;
    RETURN;
  END IF;

  -- Check if email already exists
  IF EXISTS (SELECT 1 FROM public.user_accounts WHERE email = p_email) THEN
    RETURN QUERY SELECT false, NULL::UUID, 'Email already exists'::TEXT;
    RETURN;
  END IF;

  -- Create new user
  INSERT INTO public.user_accounts (
    username,
    password_hash,
    name,
    email,
    role,
    is_active,
    created_by
  ) VALUES (
    p_username,
    crypt(p_password, gen_salt('bf')),
    p_name,
    p_email,
    p_role,
    true,
    p_created_by
  ) RETURNING id INTO v_new_user_id;

  RETURN QUERY SELECT true, v_new_user_id, NULL::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. UPDATE USER ROLE FUNCTION
CREATE OR REPLACE FUNCTION public.update_user_role(
  p_user_id UUID,
  p_new_role TEXT,
  p_updated_by UUID
)
RETURNS TABLE (
  success BOOLEAN,
  error_message TEXT
) AS $$
BEGIN
  -- Update user role
  UPDATE public.user_accounts
  SET role = p_new_role, updated_at = NOW()
  WHERE id = p_user_id;

  IF FOUND THEN
    RETURN QUERY SELECT true, NULL::TEXT;
  ELSE
    RETURN QUERY SELECT false, 'User not found'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. TOGGLE USER STATUS FUNCTION
CREATE OR REPLACE FUNCTION public.toggle_user_status(
  p_user_id UUID,
  p_updated_by UUID
)
RETURNS TABLE (
  success BOOLEAN,
  new_status BOOLEAN,
  error_message TEXT
) AS $$
DECLARE
  v_new_status BOOLEAN;
BEGIN
  -- Toggle user status
  UPDATE public.user_accounts
  SET is_active = NOT is_active, updated_at = NOW()
  WHERE id = p_user_id
  RETURNING is_active INTO v_new_status;

  IF FOUND THEN
    RETURN QUERY SELECT true, v_new_status, NULL::TEXT;
  ELSE
    RETURN QUERY SELECT false, NULL::BOOLEAN, 'User not found'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. DELETE USER ACCOUNT FUNCTION (Soft delete)
CREATE OR REPLACE FUNCTION public.delete_user_account(
  p_user_id UUID,
  p_deleted_by UUID
)
RETURNS TABLE (
  success BOOLEAN,
  error_message TEXT
) AS $$
BEGIN
  -- Soft delete by setting is_active to false
  UPDATE public.user_accounts
  SET is_active = false, updated_at = NOW()
  WHERE id = p_user_id;

  IF FOUND THEN
    RETURN QUERY SELECT true, NULL::TEXT;
  ELSE
    RETURN QUERY SELECT false, 'User not found'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.authenticate_user(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_all_users() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_user_account(TEXT, TEXT, TEXT, TEXT, TEXT, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.update_user_role(UUID, TEXT, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.toggle_user_status(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.delete_user_account(UUID, UUID) TO anon, authenticated;

-- =====================================================
-- SYNC USER ACCOUNT WITH AUTH.USERS
-- =====================================================

-- Create or update user account for your admin user
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

-- Also ensure username is unique
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
  'gaudasanuj35',
  crypt('Anuj@2005', gen_salt('bf')),
  'Admin User',
  email,
  'admin',
  true
FROM auth.users 
WHERE email = 'gaudasanuj35@gmail.com'
ON CONFLICT (username) DO UPDATE SET
  password_hash = crypt('Anuj@2005', gen_salt('bf')),
  role = 'admin',
  is_active = true;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ All authentication functions created!';
  RAISE NOTICE '✅ User account synced!';
  RAISE NOTICE '';
  RAISE NOTICE 'You can now login with:';
  RAISE NOTICE 'Username: gaudasanuj35@gmail.com (or gaudasanuj35)';
  RAISE NOTICE 'Password: Anuj@2005';
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Refresh your browser and try logging in!';
END $$;
