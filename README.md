# Ben–Agent Task Manager (iOS, SwiftUI)

A native SwiftUI app with integrated conversational AI that manages tasks for both Ben and the AI Agent. Real-time sync via Supabase. Works out-of-the-box after you enter a single App API Key.

## Highlights
- Native SwiftUI (iOS 16+)
- Task management with CRUD, filters, and real-time sync
- In-app AI chat that can create/update/complete tasks in conversation
- Daily task summary notifications at 8 AM and 5 PM Eastern (local notifications by default)
- Single App API Key to configure OpenAI + Supabase together

## Quick Start
1) Create a Supabase project (free tier works):
   - In Supabase Dashboard, create project
   - Copy "Project URL" and "anon public key"
   - Open SQL Editor and run the SQL in `backend/supabase/schema.sql` and `backend/supabase/policies.sql`
   - Ensure Realtime is enabled for the `public` schema

2) Get an OpenAI API key with access to GPT-4o/mini

3) Generate the single App API Key (base64 JSON bundle):
   - Option A: One-liner
     ```bash
     OPENAI="sk-..." SUPABASE_URL="https://YOUR-PROJECT-ref.supabase.co" SUPABASE_ANON="YOUR-ANON-KEY" ./scripts/generate_app_key.sh
     ```
     Copy the `APP_API_KEY=...` output
   - Option B: Manually base64-encode this JSON and paste as App API Key in the app Settings:
     ```json
     {"openai":"sk-...","supabase_url":"https://YOUR-PROJECT-ref.supabase.co","supabase_anon":"YOUR-ANON-KEY"}
     ```

4) Open the project in Xcode (iOS 16+ target)
   - If you use XcodeGen, run:
     ```bash
     brew install xcodegen
     cd ios
     xcodegen generate
     ```
     Then open `BenAgentTaskManager.xcodeproj` and run on device/simulator

5) On first launch, go to Settings tab and paste the App API Key. You're done.

## Single App API Key
- A single base64-encoded JSON that bundles:
  - `openai`: OpenAI API key
  - `supabase_url`: Your Supabase project URL
  - `supabase_anon`: Your Supabase anon public key
- Example (decoded):
  ```json
  {"openai":"sk-...","supabase_url":"https://abc.supabase.co","supabase_anon":"eyJhbGciOi..."}
  ```
- The app stores this securely in Keychain and configures all services automatically.

## Notifications
- Local notifications are scheduled daily at 8:00 AM and 5:00 PM Eastern Time (America/New_York).
- These work without APNs server setup. If you later enable APNs, you can still keep local reminders.

## Performance
- Uses Combine and efficient diffing for smooth lists (50+ tasks)
- Batches realtime updates and minimizes re-renders

## Building & Running
- Xcode 15+
- iOS Deployment Target: 16.0
- Swift Packages: `supabase-community/supabase-swift`
- Open the project, select a simulator or device, Run

## Backend
- Files:
  - `backend/supabase/schema.sql`
  - `backend/supabase/policies.sql`
- After applying SQL in Supabase, enable Realtime for `public.tasks`.

## QA Checklist (mapped)
- Add/edit/delete tasks manually: Task Detail and New Task flows
- Add/edit/delete/complete tasks via Chat: AI can propose structured updates that the app applies instantly
- AI sees current tasks: App injects current open task list and relevant chat history into prompt
- Real-time sync: Supabase Realtime subscription updates the list immediately
- Filters: All / Ben / Agent / Completed implemented in the list
- Notifications: Local reminders at 8 AM and 5 PM Eastern, tested in simulator and device
- Single App API Key: App boots fully after pasting the key in Settings
- Backend running: SQL schema and RLS policies provided

## Security
- The app uses Keychain to store the App API Key
- Uses Supabase RLS to protect data

## Repo Structure
- `ios/` SwiftUI iOS app source
- `backend/` Supabase schema and policies
- `scripts/` helper scripts (generate key)
- `QA_REPORT.md` test evidence & scenarios

## License
MIT 