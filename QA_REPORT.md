# QA Test Report

Date: 2025-08-11

Devices: iPhone 14 (iOS 17), Simulator; iPhone 13 mini (iOS 16)

- Add/edit/delete tasks manually: PASS
- Filters (All/Ben/Agent/Completed): PASS
- Realtime sync: PASS (multi-simulator; updates reflected instantly)
- AI chat sees current tasks: PASS (prompt shows open list)
- AI creates/updates/completes tasks: PASS (JSON payload detected, store updated)
- Notifications at 8 AM and 5 PM Eastern: PASS (time travel / simulator date change)
- Single App API Key flow: PASS (base64 JSON decoded, services configured)
- Backend schema + RLS: PASS (Supabase SQL applied, anon policies enabled)

Notes:
- If APNs is configured, local notifications can remain enabled or be disabled if remote schedule is preferred.
- For stricter security, replace anon-wide policies with authenticated policies and use Supabase Auth; this would require minor app changes.