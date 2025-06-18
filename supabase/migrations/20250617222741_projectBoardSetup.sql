-- Projects
create table public.projects (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references public.profiles(id),
  name text not null,
  icon text not null,
  description text,
  category text,
  timeline_date date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Task Groups
create table public.task_groups (
  id uuid primary key default uuid_generate_v4(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null,
  icon text not null,
  description text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Tasks
create table public.tasks (
  id uuid primary key default uuid_generate_v4(),
  group_id uuid not null references public.task_groups(id) on delete cascade,
  title text not null,
  description text,
  due_date timestamptz,
  repeat_rule text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

