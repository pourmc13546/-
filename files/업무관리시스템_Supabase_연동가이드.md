# 업무관리시스템 Supabase 연동 가이드

## 📌 프로젝트 개요

- **프로젝트명**: 업무관리시스템 (해외입점사업)
- **최종 HTML 파일**: `업무관리시스템_통합_완성_공지_프로세스.html`
- **총 라인수**: 약 6,000줄

---

## 🔑 Supabase 연동 정보

| 항목 | 값 |
|-----|---|
| **Project URL** | `https://cljtioixqjlqvmafthzj.supabase.co` |
| **Publishable Key** | `sb_publishable_g-SWH4ngK7WC9xhe7B9h3g_Y_6fr2vy` |
| **프로젝트명** | netformrnd |
| **Organization** | chaeone0122's Org |

---

## 📦 생성할 테이블 (10개)

| 테이블명 | 용도 | 메뉴 위치 |
|---------|------|----------|
| `notices` | 공지/결정사항 | 메인 > 공지/결정사항 |
| `processes` | 프로세스현황 | 메인 > 프로세스현황 |
| `cs_data` | CS 관리 | 운영관리 > CS관리 |
| `buyers` | 바이어 관리 | 운영관리 > 바이어관리 |
| `products` | 상품 관리 | 운영관리 > 상품관리 |
| `quotes` | 견적 관리 | 운영관리 > 견적관리 |
| `orders` | 주문 관리 | 확장/거래관리 > 주문관리 |
| `shipping` | 배송/물류 관리 | 확장/거래관리 > 배송/물류관리 |
| `issues` | 이슈/클레임 | 확장/거래관리 > 이슈/클레임 |
| `settlements` | 정산 관리 | 확장/거래관리 > 정산관리 |

---

## 🗄️ SQL: 테이블 생성

Supabase SQL Editor에서 실행할 코드:

```sql
-- ========================================
-- 🗑️ 기존 테이블 전부 삭제
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
-- 📦 테이블 생성
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

-- 4. 바이어 관리
CREATE TABLE buyers (
  id SERIAL PRIMARY KEY,
  level VARCHAR(10),
  company VARCHAR(100) NOT NULL,
  country VARCHAR(50),
  contact_name VARCHAR(50),
  email VARCHAR(100),
  status VARCHAR(20) DEFAULT 'active',
  last_contact DATE
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
-- ✅ 완료!
-- ========================================
SELECT '🎉 10개 테이블 생성 완료!' as result;
```

---

## 💾 SQL: 샘플 데이터 삽입

테이블 생성 후 실행:

```sql
-- ========================================
-- 📝 샘플 데이터 삽입
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
INSERT INTO buyers (level, company, country, contact_name, email, status, last_contact) VALUES
('A', 'GlobalTech Inc.', '🇺🇸 미국', 'John Smith', 'john@globaltech.com', 'active', '2025-03-20'),
('B', 'EuroTrade GmbH', '🇩🇪 독일', 'Hans Mueller', 'hans@eurotrade.de', 'active', '2025-03-18'),
('A', 'AsiaPac Ltd.', '🇸🇬 싱가포르', 'David Lee', 'david@asiapac.sg', 'negotiation', '2025-03-15'),
('C', 'UK Imports', '🇬🇧 영국', 'James Wilson', 'james@ukimports.co.uk', 'dormant', '2025-02-28');

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
-- ✅ 샘플 데이터 삽입 완료!
-- ========================================
SELECT '🎉 샘플 데이터 삽입 완료!' as result;
```

---

## 🔗 HTML에 Supabase 연동하기

HTML 파일의 `</body>` 태그 바로 위에 아래 코드 추가:

```html
<!-- Supabase 연동 -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  // Supabase 설정
  const SUPABASE_URL = 'https://cljtioixqjlqvmafthzj.supabase.co';
  const SUPABASE_KEY = 'sb_publishable_g-SWH4ngK7WC9xhe7B9h3g_Y_6fr2vy';
  
  const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

  // ========================================
  // 데이터 조회 함수들
  // ========================================
  
  // 공지사항 조회
  async function fetchNotices() {
    const { data, error } = await supabaseClient
      .from('notices')
      .select('*')
      .order('created_at', { ascending: false });
    if (error) console.error('Error:', error);
    return data;
  }

  // 주문 조회
  async function fetchOrders() {
    const { data, error } = await supabaseClient
      .from('orders')
      .select('*')
      .order('order_date', { ascending: false });
    if (error) console.error('Error:', error);
    return data;
  }

  // 배송 조회
  async function fetchShipping() {
    const { data, error } = await supabaseClient
      .from('shipping')
      .select('*');
    if (error) console.error('Error:', error);
    return data;
  }

  // 이슈 조회
  async function fetchIssues() {
    const { data, error } = await supabaseClient
      .from('issues')
      .select('*')
      .order('date', { ascending: false });
    if (error) console.error('Error:', error);
    return data;
  }

  // 정산 조회
  async function fetchSettlements() {
    const { data, error } = await supabaseClient
      .from('settlements')
      .select('*');
    if (error) console.error('Error:', error);
    return data;
  }

  // ========================================
  // 데이터 추가 함수들
  // ========================================
  
  // 공지사항 추가
  async function addNotice(notice) {
    const { data, error } = await supabaseClient
      .from('notices')
      .insert([notice])
      .select();
    if (error) console.error('Error:', error);
    return data;
  }

  // 주문 추가
  async function addOrder(order) {
    const { data, error } = await supabaseClient
      .from('orders')
      .insert([order])
      .select();
    if (error) console.error('Error:', error);
    return data;
  }

  // ========================================
  // 데이터 수정 함수들
  // ========================================
  
  // 공지사항 수정
  async function updateNotice(id, updates) {
    const { data, error } = await supabaseClient
      .from('notices')
      .update(updates)
      .eq('id', id)
      .select();
    if (error) console.error('Error:', error);
    return data;
  }

  // 주문 수정
  async function updateOrder(id, updates) {
    const { data, error } = await supabaseClient
      .from('orders')
      .update(updates)
      .eq('id', id)
      .select();
    if (error) console.error('Error:', error);
    return data;
  }

  // ========================================
  // 데이터 삭제 함수들
  // ========================================
  
  // 공지사항 삭제
  async function deleteNotice(id) {
    const { error } = await supabaseClient
      .from('notices')
      .delete()
      .eq('id', id);
    if (error) console.error('Error:', error);
    return !error;
  }

  // 주문 삭제
  async function deleteOrder(id) {
    const { error } = await supabaseClient
      .from('orders')
      .delete()
      .eq('id', id);
    if (error) console.error('Error:', error);
    return !error;
  }

  console.log('✅ Supabase 연동 완료!');
</script>
```

---

## 📋 작업 순서 요약

1. **Supabase SQL Editor 접속**
2. **테이블 생성 SQL 실행** (위의 테이블 생성 코드)
3. **샘플 데이터 삽입 SQL 실행** (위의 샘플 데이터 코드)
4. **HTML 파일에 Supabase 연동 코드 추가**
5. **테스트**

---

## 📁 파일 목록

| 파일명 | 설명 |
|-------|------|
| `업무관리시스템_통합_완성_공지_프로세스.html` | 최종 HTML 파일 |
| `업무관리시스템_Supabase_연동가이드.md` | 이 가이드 문서 |

---

## ⚠️ 주의사항

- URL과 Key는 **한 번 설정하면 계속 사용 가능**
- Publishable Key는 공개해도 안전함
- **Secret Key는 절대 공개하면 안 됨!**
- 테이블 구조 변경 시 SQL 재실행 필요

---

*작성일: 2026-01-22*
