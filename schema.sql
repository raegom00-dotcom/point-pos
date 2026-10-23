-- ============================================
-- 오락실 회원 포인트 정산앱 (UPOS 대체) - 1단계 DB
-- Supabase 대시보드 > SQL Editor 에 붙여넣고 RUN
-- ============================================

-- 직원/관리자 키 (로그인용 6자리 코드)
create table if not exists staff_keys (
  key        text primary key,
  name       text not null,
  role       text not null default 'staff' check (role in ('admin','staff')),
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

-- 회원
create table if not exists members (
  id         bigint generated always as identity primary key,
  name       text not null,          -- 닉네임
  phone      text not null,          -- 숫자만 저장 (010xxxxxxxx)
  memo       text,
  active     boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists members_phone_idx on members (phone);

-- 적립/차감/서비스 기록
create table if not exists transactions (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  staff_key  text references staff_keys(key),
  member_id  bigint not null references members(id),
  machine_no int not null default 0,  -- 100번 같은 매장 규칙 번호도 그대로 입력
  type       text not null check (type in ('적립','차감','서비스')),
  amount     int  not null check (amount > 0),
  memo       text,
  deleted_at timestamptz             -- 관리자가 삭제하면 여기에 시각 기록 (실제 삭제 안 함)
);
create index if not exists tx_created_idx on transactions (created_at);
create index if not exists tx_member_idx  on transactions (member_id);

-- 설정 (한 줄만 사용)
create table if not exists settings (
  id          int primary key default 1,
  cutoff_hour int not null default 7,   -- 하루 마감 기준 시각 (오전 7시)
  shop_name   text default '우리매장'
);
insert into settings (id, cutoff_hour) values (1, 7) on conflict (id) do nothing;

-- 회원별 누적 포인트 (적립+서비스-차감)
create or replace view member_balances as
select m.id, m.name, m.phone, m.memo, m.active, m.created_at,
       coalesce(sum(case when t.type in ('적립','서비스') then t.amount
                         when t.type = '차감' then -t.amount end), 0) as balance,
       max(t.created_at) as last_visit
from members m
left join transactions t on t.member_id = m.id and t.deleted_at is null
group by m.id;

-- 기록 보기 편한 뷰 (회원명/전화번호 붙여서)
create or replace view transaction_view as
select t.id, t.created_at, t.staff_key, s.name as staff_name,
       t.member_id, m.name as member_name, m.phone,
       t.machine_no, t.type, t.amount, t.memo, t.deleted_at
from transactions t
join members m on m.id = t.member_id
left join staff_keys s on s.key = t.staff_key;

-- 최초 관리자 키 (로그인 후 꼭 바꾸세요)
insert into staff_keys (key, name, role) values ('ADMIN1', '관리자', 'admin')
on conflict (key) do nothing;
