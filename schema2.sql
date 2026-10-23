-- ============================================
-- 2단계 추가: 접속로그 / 매장로그 테이블
-- Supabase > SQL Editor 에 붙여넣고 Run (Run without RLS)
-- ============================================

-- 접속 로그 (누가 언제 로그인했는지)
create table if not exists access_logs (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  staff_key  text,
  staff_name text,
  device     text          -- 접속 기기 정보 (브라우저 문자열)
);
create index if not exists access_logs_created_idx on access_logs (created_at);

-- 매장 로그 (관리자 작업 기록: 삭제, 설정 변경, 회원 비활성화 등)
create table if not exists shop_logs (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  staff_key  text,
  staff_name text,
  action     text not null,   -- 예: 기록삭제, 설정변경, 회원비활성화
  detail     text             -- 상세 내용
);
create index if not exists shop_logs_created_idx on shop_logs (created_at);
