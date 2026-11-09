-- 1. "job_proofs" adında bir bucket yoksa oluştur ve public (herkese açık) yap
INSERT INTO storage.buckets (id, name, public)
VALUES ('job_proofs', 'job_proofs', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Eski kuralları (varsa) çakışma olmaması için sil
DROP POLICY IF EXISTS "Public Access for job_proofs" ON storage.objects;
DROP POLICY IF EXISTS "Auth Users Upload to job_proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can edit their own proofs" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own proofs" ON storage.objects;

-- 3. Herkesin bu bucket'taki fotoğrafları okuyabilmesi için kural
CREATE POLICY "Public Access for job_proofs"
ON storage.objects FOR SELECT
USING (bucket_id = 'job_proofs');

-- 4. Sadece giriş yapmış kullanıcıların (Tasker'ların) fotoğraf YÜKLEYEBİLMESİ için kural
CREATE POLICY "Auth Users Upload to job_proofs"
ON storage.objects FOR INSERT 
TO authenticated
WITH CHECK (bucket_id = 'job_proofs');

-- 5. Opsiyonel: Kullanıcıların sadece KENDİ yükledikleri fotoğrafları silip güncelleyebilmesi için
CREATE POLICY "Users can update their own proofs"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'job_proofs' AND auth.uid() = owner);

CREATE POLICY "Users can delete their own proofs"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'job_proofs' AND auth.uid() = owner);
