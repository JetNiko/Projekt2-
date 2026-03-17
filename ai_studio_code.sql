-- ============================================================
-- SCHEMAT BAZY DANYCH SYSTEMU PRISONGUARD
-- Typ bazy: SQLite
-- ============================================================

-- 1. Role użytkowników
CREATE TABLE IF NOT EXISTS roles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  permissions TEXT NOT NULL
);

-- 2. Użytkownicy (Personel)
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role_id INTEGER NOT NULL,
  badge_number TEXT UNIQUE,
  department TEXT,
  last_login DATETIME,
  FOREIGN KEY (role_id) REFERENCES roles (id)
);

-- 3. Oddziały
CREATE TABLE IF NOT EXISTS wards (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  security_level TEXT NOT NULL,
  capacity INTEGER NOT NULL
);

-- 4. Cele
CREATE TABLE IF NOT EXISTS cells (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ward_id INTEGER NOT NULL,
  cell_number TEXT NOT NULL,
  capacity INTEGER NOT NULL,
  status TEXT DEFAULT 'active',
  FOREIGN KEY (ward_id) REFERENCES wards (id)
);

-- 5. Osadzeni
CREATE TABLE IF NOT EXISTS inmates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  inmate_number TEXT UNIQUE NOT NULL,
  cell_id INTEGER,
  date_of_birth DATE NOT NULL,
  sentence_start DATE,
  sentence_end DATE,
  crime TEXT,
  security_level TEXT,
  status TEXT DEFAULT 'active',
  photo_url TEXT,
  fingerprint_url TEXT,
  height INTEGER,
  weight INTEGER,
  eye_color TEXT,
  nationality TEXT,
  FOREIGN KEY (cell_id) REFERENCES cells (id)
);

-- 6. Historia zachowania
CREATE TABLE IF NOT EXISTS behavior_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  inmate_id INTEGER NOT NULL,
  date DATETIME DEFAULT CURRENT_TIMESTAMP,
  type TEXT NOT NULL, -- 'reward', 'punishment', 'report'
  description TEXT NOT NULL,
  points INTEGER DEFAULT 0,
  FOREIGN KEY (inmate_id) REFERENCES inmates (id)
);

-- 7. Dokumentacja medyczna
CREATE TABLE IF NOT EXISTS medical_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  inmate_id INTEGER NOT NULL,
  date DATETIME DEFAULT CURRENT_TIMESTAMP,
  diagnosis TEXT NOT NULL,
  treatment TEXT,
  prescriptions TEXT,
  doctor_name TEXT,
  FOREIGN KEY (inmate_id) REFERENCES inmates (id)
);

-- 8. Incydenty
CREATE TABLE IF NOT EXISTS incidents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATETIME DEFAULT CURRENT_TIMESTAMP,
  location TEXT NOT NULL,
  description TEXT NOT NULL,
  severity TEXT NOT NULL, -- 'low', 'medium', 'high', 'critical'
  involved_inmates TEXT,
  reporting_officer_id INTEGER,
  status TEXT DEFAULT 'pending',
  category TEXT,
  FOREIGN KEY (reporting_officer_id) REFERENCES users (id)
);

-- 9. Widzenia
CREATE TABLE IF NOT EXISTS visits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  inmate_id INTEGER NOT NULL,
  visitor_name TEXT NOT NULL,
  relationship TEXT,
  date DATETIME NOT NULL,
  duration INTEGER,
  status TEXT DEFAULT 'scheduled',
  notes TEXT,
  FOREIGN KEY (inmate_id) REFERENCES inmates (id)
);

-- 10. Grafiki pracy (Schedules)
CREATE TABLE IF NOT EXISTS schedules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  shift_start DATETIME NOT NULL,
  shift_end DATETIME NOT NULL,
  post TEXT,
  status TEXT DEFAULT 'assigned',
  type TEXT,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- 11. Raporty
CREATE TABLE IF NOT EXISTS reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  type TEXT,
  FOREIGN KEY (author_id) REFERENCES users (id)
);

-- 12. Wiadomości wewnętrzne
CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sender_id INTEGER NOT NULL,
  receiver_id INTEGER NOT NULL,
  content TEXT NOT NULL,
  sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_read INTEGER DEFAULT 0,
  FOREIGN KEY (sender_id) REFERENCES users (id),
  FOREIGN KEY (receiver_id) REFERENCES users (id)
);

-- 13. Powiadomienia i Ogłoszenia
CREATE TABLE IF NOT EXISTS announcements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT NOT NULL, -- 'info', 'warning', 'procedure'
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  author_id INTEGER,
  FOREIGN KEY (author_id) REFERENCES users (id)
);

-- ============================================================
-- DANE POCZĄTKOWE (SEED DATA)
-- ============================================================

-- Role
INSERT INTO roles (name, permissions) VALUES 
('Admin', 'all'),
('Director', 'view_all,manage_staff,reports'),
('Guard', 'view_inmates,manage_incidents,schedules'),
('Medical', 'view_inmates,manage_medical'),
('Administrative', 'view_inmates,manage_visits');

-- Oddziały
INSERT INTO wards (name, security_level, capacity) VALUES 
('Oddział A - Ogólny', 'Minimum', 50),
('Oddział B - Zaostrzony', 'Medium', 30),
('Oddział C - Izolacja', 'Maximum', 10);

-- Przykładowe Cele (Oddział A)
INSERT INTO cells (ward_id, cell_number, capacity) VALUES 
(1, 'A-1', 4), (1, 'A-2', 4), (1, 'A-3', 4);

-- Administrator (hasło: admin123 - zaszyfrowane bcryptem)
INSERT INTO users (username, password, full_name, role_id, badge_number, department) VALUES 
('admin', '$2b$10$7/O6j/l6X.mO.k.6/l6X.mO.k.6/l6X.mO.k.6/l6X.mO.k.6', 'System Administrator', 1, 'ADM-001', 'IT');

-- Przykładowy osadzony
INSERT INTO inmates (first_name, last_name, inmate_number, cell_id, date_of_birth, crime, security_level, status) VALUES 
('Jan', 'Kowalski', '2026/001', 1, '1985-05-12', 'Napad z bronią', 'Medium', 'active');

-- Przykładowe ogłoszenie
INSERT INTO announcements (title, content, type, author_id) VALUES 
('Nowe Procedury Bezpieczeństwa', 'Od jutra obowiązują nowe procedury kontroli cel na oddziale C.', 'procedure', 1);