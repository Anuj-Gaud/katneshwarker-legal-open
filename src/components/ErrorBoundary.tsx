import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Uncaught error:', error, errorInfo);
  }

  public render() {
    if (this.state.hasError) {
      const isSupabaseError = this.state.error?.message?.includes('Supabase');

      return (
        <div className="min-h-screen bg-gradient-to-br from-orange-50 to-amber-50 flex items-center justify-center p-4">
          <div className="max-w-2xl w-full bg-white rounded-lg shadow-xl p-8">
            <div className="text-center mb-6">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-red-100 rounded-full mb-4">
                <svg className="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                {isSupabaseError ? '🔧 Setup Required' : '⚠️ Something Went Wrong'}
              </h1>
              <p className="text-gray-600">
                {isSupabaseError 
                  ? 'Your application needs to be configured before it can run.'
                  : 'An unexpected error occurred.'}
              </p>
            </div>

            {isSupabaseError ? (
              <div className="space-y-4">
                <div className="bg-orange-50 border-l-4 border-orange-500 p-4 rounded">
                  <h3 className="font-semibold text-orange-900 mb-2">Missing Supabase Configuration</h3>
                  <p className="text-orange-800 text-sm">
                    The application cannot connect to the database because Supabase credentials are not configured.
                  </p>
                </div>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
                  <h3 className="font-bold text-blue-900 mb-3 flex items-center">
                    <span className="bg-blue-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm mr-2">1</span>
                    Create Supabase Project
                  </h3>
                  <ol className="list-decimal list-inside space-y-2 text-sm text-blue-900 ml-8">
                    <li>Go to <a href="https://supabase.com" target="_blank" rel="noopener noreferrer" className="underline font-medium">supabase.com</a></li>
                    <li>Sign up or sign in</li>
                    <li>Create a new project</li>
                    <li>Wait for project to be ready (~2 minutes)</li>
                  </ol>
                </div>

                <div className="bg-green-50 border border-green-200 rounded-lg p-6">
                  <h3 className="font-bold text-green-900 mb-3 flex items-center">
                    <span className="bg-green-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm mr-2">2</span>
                    Get Your Credentials
                  </h3>
                  <ol className="list-decimal list-inside space-y-2 text-sm text-green-900 ml-8">
                    <li>In Supabase Dashboard, go to Settings → API</li>
                    <li>Copy the <strong>Project URL</strong></li>
                    <li>Copy the <strong>anon/public key</strong></li>
                  </ol>
                </div>

                <div className="bg-purple-50 border border-purple-200 rounded-lg p-6">
                  <h3 className="font-bold text-purple-900 mb-3 flex items-center">
                    <span className="bg-purple-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm mr-2">3</span>
                    Update .env File
                  </h3>
                  <p className="text-sm text-purple-900 mb-2 ml-8">
                    Open <code className="bg-purple-100 px-2 py-1 rounded">.env</code> file and update:
                  </p>
                  <pre className="bg-purple-900 text-purple-100 p-3 rounded text-xs overflow-x-auto ml-8">
{`VITE_SUPABASE_URL=your-project-url
VITE_SUPABASE_ANON_KEY=your-anon-key`}
                  </pre>
                </div>

                <div className="bg-amber-50 border border-amber-200 rounded-lg p-6">
                  <h3 className="font-bold text-amber-900 mb-3 flex items-center">
                    <span className="bg-amber-500 text-white rounded-full w-6 h-6 flex items-center justify-center text-sm mr-2">4</span>
                    Restart Development Server
                  </h3>
                  <p className="text-sm text-amber-900 ml-8">
                    Stop the server (Ctrl+C) and run <code className="bg-amber-100 px-2 py-1 rounded">npm run dev</code> again
                  </p>
                </div>

                <div className="mt-6 p-4 bg-gray-50 rounded-lg">
                  <p className="text-sm text-gray-700">
                    📖 For detailed instructions, see <strong>SETUP_NOW.md</strong> in your project folder
                  </p>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded">
                  <h3 className="font-semibold text-red-900 mb-2">Error Details</h3>
                  <pre className="text-red-800 text-sm overflow-x-auto whitespace-pre-wrap">
                    {this.state.error?.message || 'Unknown error'}
                  </pre>
                </div>

                <button
                  onClick={() => window.location.reload()}
                  className="w-full bg-orange-600 hover:bg-orange-700 text-white font-medium py-3 px-4 rounded-lg transition-colors"
                >
                  Reload Page
                </button>
              </div>
            )}

            <div className="mt-6 pt-6 border-t border-gray-200 text-center">
              <p className="text-sm text-gray-500">
                Need help? Check the console (F12) for more details
              </p>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
