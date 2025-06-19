-- tampilkan kinerja semua staff dalam periode tertentu

CREATE INDEX idx_respon_tanggal ON respon_permohonan(tanggal_respon);
CREATE INDEX idx_tanggapan_tanggal ON tanggapan_pengaduan(tanggal_tanggapan);
CREATE INDEX idx_surat_respon ON surat(respon_permohonan_id_respon);
CREATE INDEX idx_permohonan_id ON permohonan_surat(id_permohonan);
CREATE INDEX idx_pengaduan_id ON pengaduan(id_pengaduan);

CREATE OR REPLACE FUNCTION evaluasi_kinerja_staff(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    nama_staff VARCHAR,
    jumlah_permohonan_dilayani BIGINT,
    jumlah_surat_dicetak BIGINT,
    rata_rata_hari_pelayanan NUMERIC,
    jumlah_tanggapan_dilayani BIGINT,
    rata_rata_hari_tanggapan NUMERIC,
    skor NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH 
    data_pelayanan AS (
        SELECT 
            st.id_staff,
            AVG(rp.tanggal_respon - ps.tanggal_pengajuan)::NUMERIC AS avg_hari_pelayanan,
            COUNT(rp.id_respon) AS total_permohonan,
            COUNT(srt.id_surat) AS total_surat_dicetak
        FROM staff st
        JOIN respon_permohonan rp ON rp.staff_id_staff = st.id_staff
        JOIN permohonan_surat ps ON rp.permohonan_surat_id_permohonan = ps.id_permohonan
        LEFT JOIN surat srt ON srt.respon_permohonan_id_respon = rp.id_respon
        WHERE rp.tanggal_respon BETWEEN start_date AND end_date
        GROUP BY st.id_staff
    ),
    data_tanggapan AS (
        SELECT 
            st.id_staff,
            AVG(tp.tanggal_tanggapan - pg.tanggal_pengaduan)::NUMERIC AS avg_hari_tanggapan,
            COUNT(tp.id_tanggapan) AS total_tanggapan
        FROM staff st
        JOIN tanggapan_pengaduan tp ON tp.staff_id_staff = st.id_staff
        JOIN pengaduan pg ON tp.pengaduan_id_pengaduan = pg.id_pengaduan
        WHERE tp.tanggal_tanggapan BETWEEN start_date AND end_date
        GROUP BY st.id_staff
    ),
    skor_dasar AS (
        SELECT 
            st.id_staff,
            w.nama AS nama_staff,
            COALESCE(p.total_permohonan, 0) AS jumlah_permohonan_dilayani,
            COALESCE(p.total_surat_dicetak, 0) AS jumlah_surat_dicetak,
            ROUND(COALESCE(p.avg_hari_pelayanan, 0), 1) AS rata_rata_hari_pelayanan,
            COALESCE(t.total_tanggapan, 0) AS jumlah_tanggapan_dilayani,
            ROUND(COALESCE(t.avg_hari_tanggapan, 0), 1) AS rata_rata_hari_tanggapan,
            (
                0.5 / (COALESCE(p.avg_hari_pelayanan, 0) + 1) +
                0.5 / (COALESCE(t.avg_hari_tanggapan, 0) + 1)
            ) AS skor_mentah
        FROM staff st
        JOIN warga w ON st.warga_nik = w.nik
        LEFT JOIN data_pelayanan p ON p.id_staff = st.id_staff
        LEFT JOIN data_tanggapan t ON t.id_staff = st.id_staff
    ),
    minmax AS (
        SELECT 
            MIN(skor_mentah) AS skor_min,
            MAX(skor_mentah) AS skor_max
        FROM skor_dasar
    )
    SELECT 
        s.nama_staff,
        s.jumlah_permohonan_dilayani,
        s.jumlah_surat_dicetak,
        s.rata_rata_hari_pelayanan,
        s.jumlah_tanggapan_dilayani,
        s.rata_rata_hari_tanggapan,
        ROUND(
            CASE 
                WHEN m.skor_max = m.skor_min THEN 1
                ELSE 0.5 + ((s.skor_mentah - m.skor_min) / (m.skor_max - m.skor_min)) * 0.5
            END,
            2
        ) AS skor
    FROM skor_dasar s, minmax m
    ORDER BY skor DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM evaluasi_kinerja_staff('2025-01-01', '2025-01-31');
DROP FUNCTION IF EXISTS evaluasi_kinerja_staff;

