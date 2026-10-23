-- ============================================
-- 3차 추가: 직원 비밀번호, 카운터 번호 설정
-- Supabase > SQL Editor 에 붙여넣고 Run (Run without RLS)
-- ============================================

-- 직원 키에 비밀번호 칸 추가 (비어 있으면 키만으로 로그인됨)
alter table staff_keys add column if not exists password text;

-- 매장 설정에 카운터 번호 추가 (예: 100, 1000 / 비어 있으면 안 씀)
alter table settings add column if not exists counter_no int;
