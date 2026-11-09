-- ==========================================
-- MIGRATION: Add proof_url & completed_at to applications
-- ==========================================
-- Bu scripti Supabase SQL Editor'de çalıştırın.

-- 1. applications tablosuna yeni kolonlar ekle
ALTER TABLE public.applications
ADD COLUMN IF NOT EXISTS proof_url TEXT,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

-- 2. Tasker'ların kendi application'larını güncelleyebilmesi için RLS
-- (İşi tamamla akışı: status -> 'completed', proof_url, completed_at)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE policyname = 'Taskers can update own applications'
    AND tablename = 'applications'
  ) THEN
    CREATE POLICY "Taskers can update own applications"
    ON public.applications FOR UPDATE
    USING (auth.uid() = tasker_id);
  END IF;
END
$$;

-- 3. Storage bucket için RLS policy (opsiyonel güvenlik)
-- Not: 'job_proofs' bucket'ını Supabase Dashboard > Storage'dan manuel oluşturmanız gerekiyor.
-- Bucket ayarları: Public = true (veya false + policy ile)

-- Eğer bucket PRIVATE ise, authenticated kullanıcıların upload yapabilmesi için:
-- (Public bucket kullanıyorsanız bu adımı atlayabilirsiniz)

-- INSERT policy: Authenticated kullanıcılar upload yapabilir
-- CREATE POLICY "Authenticated users can upload proofs"
-- ON storage.objects FOR INSERT
-- TO authenticated
-- WITH CHECK (bucket_id = 'job_proofs');

-- SELECT policy: Herkes okuyabilir
-- CREATE POLICY "Anyone can view proofs"
-- ON storage.objects FOR SELECT
-- USING (bucket_id = 'job_proofs');
