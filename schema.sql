```sql
-- Enable extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- Users table (maps to Supabase auth.users)
create table if not exists users (
  id uuid not null primary key default gen_random_uuid(),
  email text not null unique,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Coaches profile table
create table if not exists coaches (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  bio text,
  expertise text[],
  website_url text,
  social_links jsonb,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint fk_user foreign key(user_id) references auth.users(id)
);

-- Courses table
create table if not exists courses (
  id uuid not null primary key default gen_random_uuid(),
  coach_id uuid not null references coaches(id) on delete cascade,
  title text not null,
  slug text not null unique,
  description text,
  price numeric(10, 2) not null,
  duration_hours integer,
  cover_image_url text,
  is_published boolean not null default false,
  published_at timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Modules table
create table if not exists modules (
  id uuid not null primary key default gen_random_uuid(),
  course_id uuid not null references courses(id) on delete cascade,
  title text not null,
  description text,
  order_position integer not null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Lessons table
create table if not exists lessons (
  id uuid not null primary key default gen_random_uuid(),
  module_id uuid not null references modules(id) on delete cascade,
  title text not null,
  description text,
  video_url text,
  duration_minutes integer,
  order_position integer not null,
  is_free_preview boolean not null default false,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

-- Enrollments table
create table if not exists enrollments (
  id uuid not null primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  course_id uuid not null references courses(id) on delete cascade,
  purchased_at timestamp with time zone not null default now(),
  payment_amount numeric(10, 2) not null,
  payment_method text,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  unique(user_id, course_id)
);

-- Progress tracking
create table if not exists progress (
  id uuid not null primary key default gen_random_uuid(),
  enrollment_id uuid not null references enrollments(id) on delete cascade,
  lesson_id uuid not null references lessons(id) on delete cascade,
  is_completed boolean not null default false,
  completed_at timestamp with time zone,
  last_accessed_at timestamp with time zone not null default now(),
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  unique(enrollment_id, lesson_id)
);

-- Create indexes
create index idx_courses_coach_id on courses(coach_id);
create index idx_modules_course_id on modules(course_id);
create index idx_lessons_module_id on lessons(module_id);
create index idx_enrollments_user_id on enrollments(user_id);
create index idx_enrollments_course_id on enrollments(course_id);
create index idx_progress_enrollment_id on progress(enrollment_id);

-- Timestamp triggers
create or replace function update_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger update_users_timestamp
before update on users
for each row execute function update_timestamp();

create trigger update_coaches_timestamp
before update on coaches
for each row execute function update_timestamp();

create trigger update_courses_timestamp
before update on courses
for each row execute function update_timestamp();

create trigger update_modules_timestamp
before update on modules
for each row execute function update_timestamp();

create trigger update_lessons_timestamp
before update on lessons
for each row execute function update_timestamp();

create trigger update_enrollments_timestamp
before update on enrollments
for each row execute function update_timestamp();

create trigger update_progress_timestamp
before update on progress
for each row execute function update_timestamp();

-- Enable Row Level Security
alter table coaches enable row level security;
alter table courses enable row level security;
alter table modules enable row level security;
alter table lessons enable row level security;
alter table enrollments enable row level security;
alter table progress enable row level security;

-- RLS Policies
-- Coaches can only manage their own profile
create policy "Coaches can manage their own profile" 
on coaches for all using (user_id = auth.uid());

-- Coaches can manage their own courses
create policy "Coaches can manage their own courses"
on courses for all using (coach_id in (select id from coaches where user_id = auth.uid()));

-- Coaches can manage modules for their courses
create policy "Coaches can manage modules for their courses"
on modules for all using (course_id in (select id from courses where coach_id in (select id from coaches where user_id = auth.uid())));

-- Coaches can manage lessons for their modules
create policy "Coaches can manage lessons for their modules"
on lessons for all using (module_id in (select id from modules where course_id in (select id from courses where coach_id in (select id from coaches where user_id = auth.uid()))));

-- Users can only see their own enrollments
create policy "Users can manage their own enrollments"
on enrollments for all using (user_id = auth.uid());

-- Users can only see progress for their enrollments
create policy "Users can manage their own progress"
on progress for all using (enrollment_id in (select id from enrollments where user_id = auth.uid()));

-- Public read access for published courses
create policy "Public can view published courses"
on courses for select using (is_published = true);

-- Seed data (example coach and course)
insert into users (id, email, full_name, created_at, updated_at)
values ('11111111-1111-1111-1111-111111111111', 'coach@example.com', 'Example Coach', now(), now());

insert into coaches (id, user_id, bio, expertise, created_at, updated_at)
values ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 
        'Professional coach with 10+ years experience', 
        array['Leadership', 'Productivity'], now(), now());

insert into courses (id, coach_id, title, slug, description, price, is_published, published_at, created_at, updated_at)
values ('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 
        'Mastering Leadership', 'mastering-leadership', 
        'Become an effective leader in your organization', 199.00, true, now(), now(), now());
```