# FIXWELL secure database setup

This project uses a separate Supabase project for FIXWELL SERVICES INDIA. Do not reuse the Neon project or credentials for SIGNALX PRO.

## Free-tier note
Supabase Free currently includes a 500 MB database and 2 active free projects, but projects with low database activity for 7 days may be paused. Free projects do not include automatic database backups. Keep regular exports and do not treat the free tier as a production SLA.

## Owner setup
1. Sign in to Supabase and create a NEW project named `fixwell-services-india`.
2. Choose the Free plan and a region reasonably close to India (for example, Singapore if offered).
3. Open SQL Editor, paste and run `supabase/schema.sql`.
4. In Authentication, create the owner user manually. Do not enable public sign-up for this private admin dashboard.
5. From Project Settings / API, copy the Project URL and the publishable (anon) key.
6. Give the Project URL and publishable key to the developer for browser configuration. These two values are intended for the frontend when Row Level Security is correctly enabled.
7. NEVER share the `service_role` / secret key, database password, login password, or OTP in chat or browser code.

## Security model
- Each record is scoped to the authenticated owner using `owner_id`.
- Row Level Security is enabled on every business table.
- Public/anonymous users receive no table access.
- Quotation status is only an internal approval record. Sending a quotation requires a separate owner-approved action.
- Payment status must be verified by the owner against the bank/payment provider.

## Current status
The existing Render URL is still the static dashboard. This schema is prepared but is not connected until the owner creates the Supabase project and supplies its Project URL and publishable key. Do not enter real customer or financial data in the current local-only dashboard yet.
