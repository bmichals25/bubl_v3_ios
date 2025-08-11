alter table public.tasks enable row level security;

-- Policy: allow all operations to authenticated (anon key also counts when no auth is used).
-- Adjust as needed for your security model. For a single-key app, we rely on anon key scope.
create policy "Allow read to anon"
  on public.tasks for select
  to anon
  using (true);

create policy "Allow insert to anon"
  on public.tasks for insert
  to anon
  with check (true);

create policy "Allow update to anon"
  on public.tasks for update
  to anon
  using (true)
  with check (true);

create policy "Allow delete to anon"
  on public.tasks for delete
  to anon
  using (true);