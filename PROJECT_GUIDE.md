# PROJE TANIMI
Proje Adı: "HyerTR" (Geçici Ad)
Amaç: Türkiye pazarı için "On-Demand Staffing" (Anlık İşgücü) uygulaması. Hyer ve Bionluk karışımı.
Hedef Kitle:
1. Tasker (Çalışan): Garson, komi, depo görevlisi, temizlikçi vb.
2. Business (İşveren): Restoranlar, oteller, marketler.

# TEKNOLOJİ STACK'İ
- Frontend: Flutter (Latest Stable).
- State Management: Riverpod (Code Generation ile).
- Navigation: GoRouter.
- Backend: Supabase (PostgreSQL, Auth, Realtime).
- Maps: Google Maps Flutter.
- Design System: Material 3.

# KODLAMA KURALLARI
- "Feature-First" klasör yapısı kullan (features/auth, features/jobs vb.).
- Her servis ve repository için Interface (abstract class) tanımla.
- UI kodlarını logic'ten ayır (Controller/Service katmanları).
- Değişken ve Fonksiyon isimleri: İngilizce (örn: `fetchJobs`).
- Yorum satırları ve UI Metinleri: Türkçe.