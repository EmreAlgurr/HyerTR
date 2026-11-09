-- ══════════════════════════════════════════════════════════════
-- Migration: Add 'reviewing' status to applications table
-- Run this in Supabase SQL Editor
-- ══════════════════════════════════════════════════════════════

-- Eğer status sütunu üzerinde bir CHECK constraint varsa, 
-- 'reviewing' değerini de kabul etmesi gerekir.
-- Önce mevcut constraint'i bul ve kaldır, sonra yenisini ekle.

-- 1. Mevcut CHECK constraint'i kaldır (varsa)
-- NOT: constraint_name veritabanına göre farklı olabilir.
-- Aşağıdaki sorgu ile mevcut constraint adını bulabilirsiniz:
-- 
-- SELECT constraint_name 
-- FROM information_schema.check_constraints 
-- WHERE constraint_name LIKE '%applications%status%';

-- Constraint adını öğrendikten sonra:
-- ALTER TABLE applications DROP CONSTRAINT IF EXISTS applications_status_check;

-- 2. Yeni constraint ekle ('reviewing' dahil)
-- ALTER TABLE applications ADD CONSTRAINT applications_status_check
--   CHECK (status IN ('pending', 'approved', 'rejected', 'reviewing', 'completed'));

-- ══════════════════════════════════════════════════════════════
-- Eğer status sütunu zaten TEXT tipinde ve CHECK constraint yoksa,
-- bu migration'a gerek yok. Supabase varsayılan olarak 
-- text sütunlarında constraint koymaz.
-- ══════════════════════════════════════════════════════════════

-- Aşağıdaki sorgu ile mevcut durumu kontrol edin:
SELECT 
  tc.constraint_name,
  cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc 
  ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name = 'applications'
  AND tc.constraint_type = 'CHECK';
