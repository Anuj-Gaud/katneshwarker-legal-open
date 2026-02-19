-- =====================================================
-- COMPLETE DATABASE SETUP - RUN THIS FIRST
-- Legal Case Management System
-- This creates ALL tables in the correct order
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- 1. USER ACCOUNTS TABLE (Must be first!)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.user_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('admin', 'user', 'vipin')),
  is_active BOOLEAN DEFAULT true,
  avatar TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.user_accounts ENABLE ROW LEVEL SECURITY;

-- Policies for user_accounts
CREATE POLICY "Users can view all accounts" ON public.user_accounts FOR SELECT USING (true);
CREATE POLICY "Admins can insert accounts" ON public.user_accounts FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.user_accounts WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can update accounts" ON public.user_accounts FOR UPDATE USING (
  EXISTS (SELECT 1 FROM public.user_accounts WHERE id = auth.uid() AND role = 'admin')
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_accounts_username ON public.user_accounts(username);
CREATE INDEX IF NOT EXISTS idx_user_accounts_email ON public.user_accounts(email);
CREATE INDEX IF NOT EXISTS idx_user_accounts_role ON public.user_accounts(role);

-- =====================================================
-- 2. PROFILES TABLE (For Supabase Auth Integration)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('admin', 'user', 'vipin')),
  is_active BOOLEAN DEFAULT true,
  avatar TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view all profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- =====================================================
-- 3. COURTS AND CASE TYPES
-- =====================================================

CREATE TABLE IF NOT EXISTS public.courts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.case_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.districts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.courts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.case_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.districts ENABLE ROW LEVEL SECURITY;

-- Policies (allow all authenticated users to read)
CREATE POLICY "Anyone can view courts" ON public.courts FOR SELECT USING (true);
CREATE POLICY "Anyone can view case_types" ON public.case_types FOR SELECT USING (true);
CREATE POLICY "Anyone can view districts" ON public.districts FOR SELECT USING (true);

-- Insert default data
INSERT INTO public.courts (name) VALUES 
  ('Supreme Court'),
  ('High Court'),
  ('District Court'),
  ('Sessions Court'),
  ('Magistrate Court')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.case_types (name) VALUES 
  ('Civil'),
  ('Criminal'),
  ('Family'),
  ('Corporate'),
  ('Tax'),
  ('Property'),
  ('Labour')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.districts (name) VALUES 
  ('Mumbai'),
  ('Delhi'),
  ('Bangalore'),
  ('Chennai'),
  ('Kolkata')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 4. CASES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.cases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  -- Client Information
  client_name VARCHAR(255) NOT NULL,
  client_email VARCHAR(255),
  client_mobile VARCHAR(20),
  client_alternate_no VARCHAR(20),
  -- Case Identification
  file_no VARCHAR(100) NOT NULL,
  stamp_no VARCHAR(100),
  parties_name TEXT,
  -- Case Details
  case_type VARCHAR(100),
  court VARCHAR(255),
  district VARCHAR(255),
  stage VARCHAR(100),
  status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'pending', 'closed', 'disposed')),
  -- Dates
  filing_date DATE,
  next_date DATE,
  last_date DATE,
  -- Financial
  total_fees DECIMAL(12,2) DEFAULT 0,
  fees_received DECIMAL(12,2) DEFAULT 0,
  fees_pending DECIMAL(12,2) DEFAULT 0,
  -- Additional Info
  remarks TEXT,
  case_summary TEXT,
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES public.user_accounts(id)
);

-- Enable RLS
ALTER TABLE public.cases ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view cases" ON public.cases FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert cases" ON public.cases FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can update cases" ON public.cases FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_cases_client_name ON public.cases(client_name);
CREATE INDEX IF NOT EXISTS idx_cases_file_no ON public.cases(file_no);
CREATE INDEX IF NOT EXISTS idx_cases_status ON public.cases(status);
CREATE INDEX IF NOT EXISTS idx_cases_next_date ON public.cases(next_date);

-- =====================================================
-- 5. COUNSEL TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.counsel (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  mobile VARCHAR(20),
  specialization VARCHAR(255),
  bar_registration VARCHAR(100),
  address TEXT,
  notes TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.counsel ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view counsel" ON public.counsel FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage counsel" ON public.counsel FOR ALL USING (auth.uid() IS NOT NULL);

-- =====================================================
-- 6. APPOINTMENTS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  time TIME NOT NULL,
  case_id UUID REFERENCES public.cases(id) ON DELETE SET NULL,
  location VARCHAR(255),
  status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view appointments" ON public.appointments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage appointments" ON public.appointments FOR ALL USING (auth.uid() IS NOT NULL);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_appointments_date ON public.appointments(date);
CREATE INDEX IF NOT EXISTS idx_appointments_case_id ON public.appointments(case_id);

-- =====================================================
-- 7. TRANSACTIONS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID REFERENCES public.cases(id) ON DELETE CASCADE,
  amount DECIMAL(12,2) NOT NULL,
  transaction_type VARCHAR(50) CHECK (transaction_type IN ('received', 'pending', 'expense')),
  payment_mode VARCHAR(50) CHECK (payment_mode IN ('cash', 'cheque', 'online', 'upi', 'card')),
  transaction_date DATE NOT NULL,
  description TEXT,
  receipt_no VARCHAR(100),
  status VARCHAR(50) DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view transactions" ON public.transactions FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage transactions" ON public.transactions FOR ALL USING (auth.uid() IS NOT NULL);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_transactions_case_id ON public.transactions(case_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON public.transactions(transaction_date);

-- =====================================================
-- 8. TASKS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  case_id UUID REFERENCES public.cases(id) ON DELETE SET NULL,
  assigned_to UUID REFERENCES public.user_accounts(id),
  priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  deadline DATE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view tasks" ON public.tasks FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage tasks" ON public.tasks FOR ALL USING (auth.uid() IS NOT NULL);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON public.tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON public.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_deadline ON public.tasks(deadline);

-- =====================================================
-- 9. ATTENDANCE TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.attendance (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.user_accounts(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  check_in TIME,
  check_out TIME,
  status VARCHAR(20) DEFAULT 'present' CHECK (status IN ('present', 'absent', 'half_day', 'leave')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- Enable RLS
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view attendance" ON public.attendance FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage attendance" ON public.attendance FOR ALL USING (auth.uid() IS NOT NULL);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_attendance_user_id ON public.attendance(user_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON public.attendance(date);

-- =====================================================
-- 10. EXPENSES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category VARCHAR(100) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  description TEXT,
  expense_date DATE NOT NULL,
  month VARCHAR(7) NOT NULL, -- Format: YYYY-MM
  payment_mode VARCHAR(50),
  receipt_no VARCHAR(100),
  created_by UUID REFERENCES public.user_accounts(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view expenses" ON public.expenses FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage expenses" ON public.expenses FOR ALL USING (auth.uid() IS NOT NULL);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_expenses_month ON public.expenses(month);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON public.expenses(expense_date);

-- =====================================================
-- 11. LIBRARY TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS public.library_locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  created_by UUID REFERENCES public.user_accounts(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.books (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  number VARCHAR(100),
  location VARCHAR(255),
  location_id UUID REFERENCES public.library_locations(id) ON DELETE SET NULL,
  added_by VARCHAR(255),
  added_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.library_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  author VARCHAR(255),
  isbn VARCHAR(50),
  category VARCHAR(100),
  location_id UUID REFERENCES public.library_locations(id) ON DELETE SET NULL,
  status VARCHAR(50) DEFAULT 'available',
  added_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.library_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.library_items ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view library data" ON public.library_locations FOR SELECT USING (true);
CREATE POLICY "Anyone can view books" ON public.books FOR SELECT USING (true);
CREATE POLICY "Anyone can view library items" ON public.library_items FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage library" ON public.library_locations FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can manage books" ON public.books FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can manage library items" ON public.library_items FOR ALL USING (auth.uid() IS NOT NULL);

-- =====================================================
-- 12. STORAGE TABLES
-- =====================================================

CREATE TABLE IF NOT EXISTS public.storage_locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  created_by UUID REFERENCES public.user_accounts(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.storage_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  item_name VARCHAR(255) NOT NULL,
  description TEXT,
  location_id UUID REFERENCES public.storage_locations(id) ON DELETE SET NULL,
  case_id UUID REFERENCES public.cases(id) ON DELETE SET NULL,
  added_by UUID REFERENCES public.user_accounts(id),
  added_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.sofa_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID REFERENCES public.cases(id) ON DELETE CASCADE,
  compartment VARCHAR(10) CHECK (compartment IN ('C1', 'C2')),
  added_by VARCHAR(255),
  added_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.storage_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.storage_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sofa_items ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view storage" ON public.storage_locations FOR SELECT USING (true);
CREATE POLICY "Anyone can view storage items" ON public.storage_items FOR SELECT USING (true);
CREATE POLICY "Anyone can view sofa items" ON public.sofa_items FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage storage" ON public.storage_locations FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can manage storage items" ON public.storage_items FOR ALL USING (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated users can manage sofa items" ON public.sofa_items FOR ALL USING (auth.uid() IS NOT NULL);

-- =====================================================
-- 13. CASE FILES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.case_files (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  case_id UUID REFERENCES public.cases(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  file_type VARCHAR(100),
  file_size BIGINT,
  uploaded_by UUID REFERENCES public.user_accounts(id),
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.case_files ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Anyone can view case files" ON public.case_files FOR SELECT USING (true);
CREATE POLICY "Authenticated users can manage case files" ON public.case_files FOR ALL USING (auth.uid() IS NOT NULL);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_case_files_case_id ON public.case_files(case_id);

-- =====================================================
-- 14. NOTIFICATIONS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.user_accounts(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_by UUID REFERENCES public.user_accounts(id),
  created_by_name VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can view their notifications" ON public.notifications FOR SELECT USING (
  user_id = auth.uid() OR user_id IS NULL
);
CREATE POLICY "Authenticated users can create notifications" ON public.notifications FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Users can update their notifications" ON public.notifications FOR UPDATE USING (user_id = auth.uid());

-- Indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);

-- =====================================================
-- 15. HELPER FUNCTION FOR UPDATED_AT
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to tables with updated_at
CREATE TRIGGER update_user_accounts_updated_at BEFORE UPDATE ON public.user_accounts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cases_updated_at BEFORE UPDATE ON public.cases
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_counsel_updated_at BEFORE UPDATE ON public.counsel
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON public.appointments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON public.tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 16. GRANT PERMISSIONS
-- =====================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- =====================================================
-- SETUP COMPLETE!
-- =====================================================

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Database setup complete!';
  RAISE NOTICE '✅ All tables created successfully';
  RAISE NOTICE '✅ RLS policies enabled';
  RAISE NOTICE '✅ Default data inserted';
  RAISE NOTICE '';
  RAISE NOTICE 'Next steps:';
  RAISE NOTICE '1. Create your admin user';
  RAISE NOTICE '2. Restart your development server';
  RAISE NOTICE '3. Login and start using the app!';
END $$;
