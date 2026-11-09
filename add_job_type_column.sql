-- ==========================================
-- MIGRATION: Add job_type column to jobs table
-- ==========================================
-- Bu scripti Supabase SQL Editor'de çalıştırın.
-- Mevcut kayıtlar otomatik olarak 'paid' değerini alacaktır.

-- 1. jobs tablosuna job_type kolonu ekle
ALTER TABLE public.jobs
ADD COLUMN IF NOT EXISTS job_type TEXT NOT NULL DEFAULT 'paid';

-- 2. available_jobs View'ını güncelle (job_type kolonunu dahil et)
-- NOT: CREATE OR REPLACE VIEW kolon sırasını değiştirmeye izin vermez.
-- Bu yüzden önce DROP edip sonra tekrar oluşturuyoruz.
DROP VIEW IF EXISTS public.available_jobs;

CREATE VIEW public.available_jobs AS
SELECT
  j.id,
  j.business_id,
  j.title,
  j.description,
  j.hourly_rate,
  j.job_type,
  j.address_text,
  j.start_time,
  j.end_time,
  j.status,
  j.created_at,
  -- PostGIS kolonundan enlem ve boylamı ayıkla
  st_y(j.location::geometry) as lat,
  st_x(j.location::geometry) as lng,
  -- Profil bilgileri
  p.full_name as business_name,
  p.avatar_url as business_avatar
FROM public.jobs j
JOIN public.profiles p ON j.business_id = p.id;
