-- ========================================
-- 업무관리시스템 Supabase 테이블 설정
-- Supabase SQL Editor에서 실행하세요
-- ========================================

-- ========================================
-- STEP 1: 기존 테이블 삭제 (있으면)
-- ========================================
DROP TABLE IF EXISTS notices CASCADE;
DROP TABLE IF EXISTS processes CASCADE;
DROP TABLE IF EXISTS cs_data CASCADE;
DROP TABLE IF EXISTS buyers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS quotes CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS shipping CASCADE;
DROP TABLE IF EXISTS issues CASCADE;
DROP TABLE IF EXISTS settlements CASCADE;

-- ========================================
-- STEP 2: 테이블 생성 (10개)
-- ========================================

-- 1. 공지/결정사항
CREATE TABLE notices (
  id SERIAL PRIMARY KEY,
  type VARCHAR(20) NOT NULL,
  emoji VARCHAR(10) DEFAULT '📌',
  title VARCHAR(200) NOT NULL,
  content TEXT,
  color VARCHAR(20) DEFAULT 'rose',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. 프로세스현황
CREATE TABLE processes (
  id SERIAL PRIMARY KEY,
  project_id VARCHAR(50) NOT NULL,
  group_id VARCHAR(50) NOT NULL,
  group_name VARCHAR(100),
  task_name VARCHAR(200) NOT NULL,
  assignee VARCHAR(50),
  status VARCHAR(20) DEFAULT 'scheduled',
  memo TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. CS 관리
CREATE TABLE cs_data (
  id SERIAL PRIMARY KEY,
  priority VARCHAR(20) DEFAULT 'medium',
  status VARCHAR(20) DEFAULT 'pending',
  type VARCHAR(50),
  title VARCHAR(200) NOT NULL,
  buyer VARCHAR(100),
  buyer_level VARCHAR(10),
  assignee VARCHAR(50),
  date DATE DEFAULT CURRENT_DATE
);

-- 4. 바이어 관리 (CRM)
CREATE TABLE buyers (
  id SERIAL PRIMARY KEY,
  level VARCHAR(10),
  company VARCHAR(100) NOT NULL,
  country VARCHAR(50),
  contact_name VARCHAR(50),
  email VARCHAR(100),
  phone VARCHAR(50),
  status VARCHAR(20) DEFAULT 'active',
  last_contact DATE,
  next_follow_up DATE,
  tags TEXT[] DEFAULT '{}',
  stage VARCHAR(50) DEFAULT '첫거래',
  is_reorder BOOLEAN DEFAULT false,
  order_count INTEGER DEFAULT 0,
  amount VARCHAR(50) DEFAULT '',
  annual_purchase VARCHAR(50) DEFAULT '',
  cumulative_purchase VARCHAR(50) DEFAULT '',
  assignee VARCHAR(50) DEFAULT '',
  sales_region TEXT[] DEFAULT '{}',
  business_type VARCHAR(50),
  product_categories TEXT[] DEFAULT '{}',
  payment_terms VARCHAR(50),
  source VARCHAR(50),
  notes TEXT
);

-- 5. 상품 관리
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50),
  name VARCHAR(200) NOT NULL,
  category VARCHAR(50),
  price DECIMAL(12,2),
  stock INTEGER DEFAULT 0,
  status VARCHAR(20) DEFAULT 'active'
);

-- 6. 견적 관리
CREATE TABLE quotes (
  id SERIAL PRIMARY KEY,
  quote_number VARCHAR(50),
  buyer VARCHAR(100),
  buyer_level VARCHAR(10),
  product VARCHAR(200),
  amount VARCHAR(50),
  status VARCHAR(20) DEFAULT 'request',
  date DATE DEFAULT CURRENT_DATE
);

-- 7. 주문 관리
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  order_number VARCHAR(50) NOT NULL,
  buyer VARCHAR(100),
  country VARCHAR(10),
  order_date DATE,
  due_date DATE,
  product VARCHAR(200),
  qty INTEGER,
  amount VARCHAR(50),
  assignee VARCHAR(50),
  status VARCHAR(20) DEFAULT '신규',
  note TEXT
);

-- 8. 배송/물류 관리
CREATE TABLE shipping (
  id SERIAL PRIMARY KEY,
  order_id VARCHAR(50),
  buyer VARCHAR(100),
  bl_no VARCHAR(50),
  country VARCHAR(10),
  country_name VARCHAR(50),
  status VARCHAR(20),
  departure DATE,
  eta DATE,
  carrier VARCHAR(50),
  vessel VARCHAR(50),
  route VARCHAR(100),
  assignee VARCHAR(50),
  steps INTEGER[] DEFAULT '{0,0,0,0,0}'
);

-- 9. 이슈/클레임
CREATE TABLE issues (
  id SERIAL PRIMARY KEY,
  issue_number VARCHAR(50),
  priority VARCHAR(20) DEFAULT '보통',
  status VARCHAR(20) DEFAULT '미처리',
  type VARCHAR(50),
  title VARCHAR(200),
  order_id VARCHAR(50),
  buyer VARCHAR(100),
  assignee VARCHAR(50),
  date DATE DEFAULT CURRENT_DATE,
  days INTEGER DEFAULT 0,
  content TEXT
);

-- 10. 정산 관리
CREATE TABLE settlements (
  id SERIAL PRIMARY KEY,
  settlement_number VARCHAR(50),
  order_id VARCHAR(50),
  buyer VARCHAR(100),
  order_amount VARCHAR(50),
  fee VARCHAR(50),
  settlement_amount VARCHAR(50),
  status VARCHAR(20) DEFAULT '대기',
  due_date DATE,
  complete_date DATE,
  method VARCHAR(50),
  bank VARCHAR(50),
  account VARCHAR(50)
);

-- ========================================
-- STEP 3: RLS (Row Level Security) 비활성화
-- 개발 단계에서는 비활성화, 운영 시 활성화 권장
-- ========================================
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE processes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cs_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE buyers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE shipping ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE settlements ENABLE ROW LEVEL SECURITY;

-- 모든 사용자 접근 허용 정책 (개발용)
CREATE POLICY "Allow all" ON notices FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON processes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON cs_data FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON buyers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON quotes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON shipping FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON issues FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON settlements FOR ALL USING (true) WITH CHECK (true);

-- ========================================
-- STEP 4: 샘플 데이터 삽입
-- ========================================

-- 1. 공지사항
INSERT INTO notices (type, emoji, title, content, color) VALUES
('notice', '📌', '2025년 1분기 해외 입점 목표', '알리바바, 아마존 글로벌 입점 완료 목표', 'rose'),
('notice', '💡', '신규 바이어 응대 프로세스', '48시간 내 초기 응대 필수', 'sky'),
('decision', '⭐', '분기별 성과 리뷰 일정', '매 분기 마지막 주 금요일 진행', 'teal'),
('decision', '🎯', '샘플 발송 기준 확정', '거래 가능성 70% 이상 바이어에게만 발송', 'amber');

-- 2. 프로세스현황
INSERT INTO processes (project_id, group_id, group_name, task_name, assignee, status, memo) VALUES
('alibaba', 'group1', '자료 취합', '회사 소개서 영문 번역', '김담당', 'completed', '완료'),
('alibaba', 'group1', '자료 취합', '제품 카탈로그 제작', '이매니저', 'progress', '디자인 진행중'),
('alibaba', 'group2', '자료 검토', '법무 검토', '박팀장', 'request', '법무팀 확인 요청'),
('alibaba', 'group3', '샵 세팅', '스토어 기본 정보 입력', '김담당', 'scheduled', ''),
('extra1', 'group1', '추가업무', '신규 바이어 미팅', '이매니저', 'progress', '다음주 화요일 예정');

-- 3. CS 데이터
INSERT INTO cs_data (priority, status, type, title, buyer, buyer_level, assignee, date) VALUES
('high', 'pending', '배송문의', '배송 지연 문의', 'GlobalTech Inc.', 'A', '김운영', '2025-03-25'),
('medium', 'progress', '제품문의', '제품 스펙 확인 요청', 'EuroTrade GmbH', 'B', '이매니저', '2025-03-24'),
('low', 'completed', '견적문의', '대량 구매 견적 요청', 'AsiaPac Ltd.', 'A', '박담당', '2025-03-23'),
('high', 'pending', '클레임', '제품 불량 클레임', 'UK Imports', 'B', '김운영', '2025-03-22');

-- 4. 바이어
INSERT INTO buyers (level, company, country, contact_name, email, status, last_contact, tags, stage, is_reorder, order_count, amount, assignee) VALUES
('A', 'GlobalTech Inc.', '🇺🇸 미국', 'John Smith', 'john@globaltech.com', 'active', '2025-03-20', ARRAY['대형거래처', '도료류'], '재구매', true, 5, '$150,000', '김운영'),
('B', 'EuroTrade GmbH', '🇩🇪 독일', 'Hans Mueller', 'hans@eurotrade.de', 'active', '2025-03-18', ARRAY['중형거래처', '코팅류'], '거래중', true, 2, '$80,000', '이매니저'),
('A', 'AsiaPac Ltd.', '🇸🇬 싱가포르', 'David Lee', 'david@asiapac.sg', 'negotiation', '2025-03-15', ARRAY['대형거래처', '도료류'], '재구매', true, 3, '$55,000', '김운영'),
('C', 'UK Imports', '🇬🇧 영국', 'James Wilson', 'james@ukimports.co.uk', 'dormant', '2025-02-28', ARRAY['소형거래처', '시트류'], '휴면', false, 1, '$28,000', '박담당');

-- 5. 상품
INSERT INTO products (code, name, category, price, stock, status) VALUES
('WS-001', '워터실드 프리미엄', '방수코팅', 25.00, 500, 'active'),
('WS-002', '워터실드 스탠다드', '방수코팅', 22.00, 800, 'active'),
('HT-001', '하이템프 코팅', '내열코팅', 28.00, 300, 'active'),
('PC-001', '파우더 코팅제', '분체도료', 24.00, 450, 'review'),
('RP-001', '보수용 퍼티', '보수자재', 12.00, 1000, 'active');

-- 6. 견적
INSERT INTO quotes (quote_number, buyer, buyer_level, product, amount, status, date) VALUES
('QT-2025-089', 'GlobalTech Inc.', 'A', '워터실드 프리미엄', '$15,000', 'request', '2025-03-25'),
('QT-2025-088', 'EuroTrade GmbH', 'B', '하이템프 코팅', '$8,400', 'contract', '2025-03-24'),
('QT-2025-087', 'AsiaPac Ltd.', 'A', '워터실드 스탠다드', '$22,000', 'complete', '2025-03-20'),
('QT-2025-086', 'UK Imports', 'B', '파우더 코팅제', '$9,600', 'request', '2025-03-18');

-- 7. 주문
INSERT INTO orders (order_number, buyer, country, order_date, due_date, product, qty, amount, assignee, status, note) VALUES
('ORD-2025-048', 'GlobalTech Inc.', '🇺🇸', '2025-03-25', '2025-04-10', '워터실드 프리미엄', 500, '$12,500', '김운영', '신규', '긴급 주문 요청'),
('ORD-2025-047', 'EuroTrade GmbH', '🇩🇪', '2025-03-24', '2025-04-15', '하이템프 코팅', 300, '$8,400', '이매니저', '신규', ''),
('ORD-2025-046', 'AsiaPac Ltd.', '🇸🇬', '2025-03-23', '2025-04-08', '워터실드 스탠다드', 1000, '$22,000', '박담당', '진행중', '샘플 요청'),
('ORD-2025-045', 'CanadaCorp', '🇨🇦', '2025-03-22', '2025-04-05', '특수 시트 A형', 200, '$6,000', '김운영', '진행중', ''),
('ORD-2025-044', 'AussieTrade', '🇦🇺', '2025-03-20', '2025-04-02', '워터실드 프리미엄', 800, '$20,000', '이매니저', '진행중', '분할 배송 요청'),
('ORD-2025-043', 'UK Imports', '🇬🇧', '2025-03-18', '2025-03-30', '파우더 코팅제', 400, '$9,600', '박담당', '완료', ''),
('ORD-2025-042', 'FranceBuild', '🇫🇷', '2025-03-15', '2025-03-28', '보수용 퍼티', 600, '$7,200', '김운영', '이슈', '색상 불일치 클레임');

-- 8. 배송
INSERT INTO shipping (order_id, buyer, bl_no, country, country_name, status, departure, eta, carrier, vessel, route, assignee, steps) VALUES
('ORD-2025-048', 'GlobalTech Inc.', 'BL-2025-008', '🇺🇸', '미국', '국내운송', '2025-03-26', '2025-04-10', 'CJ대한통운', '-', '인천 → LA', '김운영', '{1,0,0,0,0}'),
('ORD-2025-047', 'EuroTrade GmbH', 'BL-2025-007', '🇩🇪', '독일', '수출통관', '2025-03-25', '2025-04-15', 'MSC', 'MSC ISABELLA', '부산 → 함부르크', '이매니저', '{2,1,0,0,0}'),
('ORD-2025-046', 'AsiaPac Ltd.', 'BL-2025-006', '🇸🇬', '싱가포르', '선적', '2025-03-24', '2025-04-08', 'Evergreen', 'EVER GOLDEN', '부산 → 싱가포르', '박담당', '{2,2,1,0,0}'),
('ORD-2025-045', 'CanadaCorp', 'BL-2025-005', '🇨🇦', '캐나다', '해외운송', '2025-03-22', '2025-04-05', 'FedEx', 'AIR', '인천 → 토론토', '김운영', '{2,2,2,1,0}'),
('ORD-2025-043', 'UK Imports', 'BL-2025-003', '🇬🇧', '영국', '배송완료', '2025-03-18', '2025-03-30', 'MSC', 'MSC ROMA', '부산 → 런던', '박담당', '{2,2,2,2,2}');

-- 9. 이슈
INSERT INTO issues (issue_number, priority, status, type, title, order_id, buyer, assignee, date, days, content) VALUES
('ISS-2025-012', '긴급', '미처리', '품질불량', '색상 불일치', 'ORD-2025-042', 'FranceBuild', '김운영', '2025-03-25', 3, '주문한 색상과 다른 제품 배송됨'),
('ISS-2025-011', '높음', '처리중', '배송지연', '통관 지연', 'ORD-2025-045', 'CanadaCorp', '이매니저', '2025-03-24', 5, '캐나다 세관 서류 문제'),
('ISS-2025-010', '보통', '협의중', '수량부족', '수량 오차', 'ORD-2025-046', 'AsiaPac Ltd.', '박담당', '2025-03-22', 2, '주문 수량보다 5개 부족');

-- 10. 정산
INSERT INTO settlements (settlement_number, order_id, buyer, order_amount, fee, settlement_amount, status, due_date, complete_date, method, bank, account) VALUES
('STL-2025-008', 'ORD-2025-043', 'UK Imports', '$9,600', '-$480', '$9,120', '완료', '2025-03-30', '2025-03-28', 'T/T 송금', '국민은행', '123-456-789012'),
('STL-2025-007', 'ORD-2025-044', 'AussieTrade', '$20,000', '-$1,000', '$19,000', '진행중', '2025-04-05', NULL, 'L/C', '신한은행', '987-654-321098'),
('STL-2025-006', 'ORD-2025-046', 'AsiaPac Ltd.', '$22,000', '-$1,100', '$20,900', '대기', '2025-04-10', NULL, 'T/T 송금', '하나은행', '456-789-012345');

-- ========================================
-- 완료!
-- ========================================
SELECT '10개 테이블 생성 및 샘플 데이터 삽입 완료!' as result;
