# 🏛️ Katneshwarkar Legal Case Management System

A modern, full-featured legal case management dashboard built with React, TypeScript, and Supabase. Designed specifically for law firms and legal professionals to manage cases, clients, appointments, finances, and more.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![React](https://img.shields.io/badge/React-18.3.1-61dafb.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.3.0-3178c6.svg)
![Supabase](https://img.shields.io/badge/Supabase-2.86.0-3ecf8e.svg)

## ✨ Features

### 📋 Case Management
- Create, edit, and track legal cases
- Detailed case information with client details
- Case status tracking (Active, Pending, Closed, Disposed)
- File attachments and document management
- Case timeline and history
- Advanced search and filtering

### 👥 Client Management
- Comprehensive client profiles
- Contact information management
- Client communication history
- Multiple cases per client

### 📅 Appointments & Calendar
- Schedule and manage appointments
- Calendar view with date-based events
- Appointment reminders
- Court date tracking

### 💰 Financial Management
- Transaction tracking (Received, Pending, Expenses)
- Payment mode tracking (Cash, Cheque, Online, UPI, Card)
- Fee management per case
- Financial reports and analytics
- Expense tracking by category

### 👨‍⚖️ Counsel Management
- Manage external counsel/lawyers
- Counsel specialization tracking
- Case assignments to counsel
- Contact information and bar registration

### 📚 Library Management
- Book and resource tracking
- Location-based organization
- Search and categorization
- ISBN and author tracking

### 📦 Storage Management
- Physical file storage tracking
- Location-based organization
- Case-linked storage items
- Sofa compartment management (C1, C2)

### 📊 Admin Panel
- User management (Create, Edit, Delete users)
- Role-based access control (Admin, User, Vipin)
- System settings
- Courts and case types management
- District management

### 🔔 Notifications
- Real-time notifications
- Task reminders
- Case updates
- System alerts

### ✅ Task Management
- Create and assign tasks
- Priority levels (Low, Medium, High, Urgent)
- Deadline tracking
- Status management (Pending, In Progress, Completed)

### 📈 Attendance Tracking
- Daily attendance records
- Check-in/check-out times
- Leave management
- Attendance reports

## 🚀 Tech Stack

### Frontend
- **React 18.3.1** - UI library
- **TypeScript 5.3.0** - Type safety
- **Vite 5.0** - Build tool and dev server
- **React Router 6.20** - Navigation
- **Tailwind CSS 3.3** - Styling
- **Framer Motion 10.16** - Animations
- **Lucide React** - Icons

### Backend & Database
- **Supabase** - Backend as a Service
  - PostgreSQL database
  - Authentication
  - Real-time subscriptions
  - Row Level Security (RLS)
  - Storage

### Form & Validation
- **React Hook Form 7.48** - Form management
- **Zod 3.22** - Schema validation
- **@hookform/resolvers** - Form validation integration

### Additional Libraries
- **date-fns 2.30** - Date manipulation
- **axios 1.6** - HTTP client
- **fast-check 3.14** - Property-based testing

## 📦 Installation

### Prerequisites
- Node.js 16+ and npm
- Supabase account
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/Anuj-Gaud/katneshwarker-legal-open.git
cd katneshwarker-legal-open
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Environment Setup

Create a `.env` file in the root directory:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

Get these values from your Supabase project:
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to Settings → API
4. Copy the Project URL and anon/public key

### 4. Database Setup

Run the complete database setup SQL:

1. Open Supabase SQL Editor
2. Copy the content from `RUN_THIS_FIRST_COMPLETE_SETUP.sql`
3. Paste and execute in SQL Editor
4. Wait for success message

This creates:
- 15+ database tables
- Row Level Security policies
- Helper functions
- Default data (courts, case types, districts)

### 5. Create Admin User

Run this SQL in Supabase SQL Editor (replace email and password):

```sql
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token,
  email_change, email_change_token_new, recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(), 'authenticated', 'authenticated',
  'admin@example.com',
  crypt('your_password', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"],"role":"admin"}',
  '{"name":"Admin User","role":"admin"}',
  NOW(), NOW(), '', '', '', ''
);

INSERT INTO public.profiles (id, email, name, role, is_active, created_at, updated_at)
SELECT id, email, 'Admin User', 'admin', true, NOW(), NOW()
FROM auth.users WHERE email = 'admin@example.com';
```

### 6. Run Development Server

```bash
npm run dev
```

The app will open at `http://localhost:3000`

## 🏗️ Build for Production

```bash
npm run build
```

The production build will be in the `dist/` directory.

## 🚀 Deployment

### Deploy to Vercel

1. Push your code to GitHub
2. Import project in [Vercel](https://vercel.com)
3. Add environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Deploy!

### Deploy to Netlify

1. Push your code to GitHub
2. Import project in [Netlify](https://netlify.com)
3. Build settings:
   - Build command: `npm run build`
   - Publish directory: `dist`
4. Add environment variables
5. Deploy!

## 📁 Project Structure

```
katneshwarker-legal-open/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── AdminRoute.tsx
│   │   ├── ProtectedRoute.tsx
│   │   ├── ErrorBoundary.tsx
│   │   ├── Header.tsx
│   │   ├── Sidebar.tsx
│   │   └── ...
│   ├── contexts/            # React Context providers
│   │   ├── AuthContext.tsx
│   │   ├── DataContext.tsx
│   │   └── ThemeContext.tsx
│   ├── pages/               # Page components
│   │   ├── DashboardPage.tsx
│   │   ├── CasesPage.tsx
│   │   ├── AppointmentsPage.tsx
│   │   ├── FinancePage.tsx
│   │   └── ...
│   ├── lib/                 # Utility libraries
│   │   ├── supabase.ts      # Supabase client & helpers
│   │   ├── userManagement.ts
│   │   └── fileStorage.ts
│   ├── types/               # TypeScript type definitions
│   ├── utils/               # Utility functions
│   ├── App.tsx              # Main app component
│   ├── main.tsx             # Entry point
│   └── index.css            # Global styles
├── supabase/
│   ├── migrations/          # Database migration files
│   └── functions/           # Edge functions
├── public/                  # Static assets
├── .env.example             # Environment variables template
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.js
```

## 🎨 Theme

The application uses a modern orange theme with:
- Primary: Orange (#f97316)
- Secondary: Amber (#fbbf24)
- Accent: Light Orange (#fb923c)
- Dark backgrounds with high contrast
- Smooth animations and transitions

## 🔐 Authentication

**Note:** Authentication is currently bypassed for easier development and demo purposes. The app loads directly to the dashboard without requiring login.

To re-enable authentication:
1. Open `src/components/ProtectedRoute.tsx`
2. Uncomment the authentication code
3. Do the same for `src/components/AdminRoute.tsx`

## 👥 User Roles

- **Admin** - Full access to all features including user management
- **User** - Standard access to cases, appointments, and daily operations
- **Vipin** - Custom role with specific permissions

## 📊 Database Schema

The application uses 15+ tables:
- `user_accounts` - User authentication and profiles
- `profiles` - Extended user information
- `cases` - Legal case records
- `counsel` - External lawyers/counsel
- `appointments` - Calendar appointments
- `transactions` - Financial transactions
- `tasks` - Task management
- `attendance` - Staff attendance
- `expenses` - Office expenses
- `books` - Library books
- `library_locations` - Library storage locations
- `storage_locations` - Physical file storage
- `sofa_items` - Sofa compartment items
- `case_files` - Case document attachments
- `notifications` - System notifications

## 🧪 Testing

```bash
npm run test
```

The project includes property-based tests using fast-check for:
- Authentication flows
- Case management
- Form validation
- Data consistency
- And more...

## 📝 Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build
npm run lint         # Run ESLint
npm run format       # Format code with Prettier
npm run test         # Run tests
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Anuj Gauda**
- GitHub: [@Anuj-Gaud](https://github.com/Anuj-Gaud)
- Email: gaudasanuj35@gmail.com

## 🙏 Acknowledgments

- Built with [React](https://react.dev)
- Powered by [Supabase](https://supabase.com)
- Styled with [Tailwind CSS](https://tailwindcss.com)
- Icons from [Lucide](https://lucide.dev)

## 📞 Support

For support, email gaudasanuj35@gmail.com or open an issue on GitHub.

## 🗺️ Roadmap

- [ ] Mobile responsive design improvements
- [ ] PDF report generation
- [ ] Email notifications
- [ ] Document templates
- [ ] Advanced analytics dashboard
- [ ] Multi-language support
- [ ] Dark/Light theme toggle
- [ ] Export data to Excel/CSV
- [ ] Integration with court e-filing systems
- [ ] Mobile app (React Native)

## 📸 Screenshots

### Dashboard
![Dashboard](https://via.placeholder.com/800x400?text=Dashboard+Screenshot)

### Case Management
![Cases](https://via.placeholder.com/800x400?text=Cases+Screenshot)

### Appointments
![Appointments](https://via.placeholder.com/800x400?text=Appointments+Screenshot)

---

Made with ❤️ for legal professionals
