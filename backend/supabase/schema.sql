create extension if not exists "uuid-ossp";

create table if not exists public.tasks (
    id uuid primary key default uuid_generate_v4(),
    title text not null,
    description text,
    assignee text check (assignee in ('ben', 'agent')) not null,
    status text check (status in ('pending', 'in_progress', 'done')) default 'pending',
    category text,
    due_date date,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

create index if not exists idx_tasks_status on public.tasks (status);
create index if not exists idx_tasks_assignee on public.tasks (assignee);
create index if not exists idx_tasks_due_date on public.tasks (due_date);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_tasks_set_updated_at on public.tasks;
create trigger trg_tasks_set_updated_at
before update on public.tasks
for each row execute function public.set_updated_at();

-- Ensure tasks table is included in realtime publication
alter publication supabase_realtime add table public.tasks;