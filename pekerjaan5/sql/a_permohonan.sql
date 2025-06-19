-- 1
-- hitung jumlah permohonan berdasarkan status dalam periode tertentu
CREATE OR REPLACE FUNCTION distribusi_status_permohonan(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    status VARCHAR,
    jumlah BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ps.status,
        COUNT(*) AS jumlah
    FROM permohonan_surat ps
    WHERE ps.tanggal_pengajuan BETWEEN start_date AND end_date
    GROUP BY ps.status
    ORDER BY jumlah DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM distribusi_status_permohonan('2025-01-01', '2025-01-31');
DROP FUNCTION IF EXISTS distribusi_status_permohonan;

-- 2
-- tampilkan semua permohonan berdasar status
-- (menunggu, diproses, selesai, ditolak)
CREATE OR REPLACE FUNCTION permohonan_berdasar_status(
    start_date DATE,
    end_date DATE,
    input_status VARCHAR
)
RETURNS TABLE (
    id_permohonan VARCHAR,
    tanggal_pengajuan DATE,
    nama_warga VARCHAR,
    nama_surat VARCHAR,
    nama_staff VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ps.id_permohonan,
        ps.tanggal_pengajuan,
        w.nama AS nama_warga,
        js.nama_surat,
        CASE 
            WHEN LOWER(ps.status) != 'menunggu' THEN sw.nama
            ELSE NULL
        END AS nama_staff
    FROM permohonan_surat ps
    JOIN warga w ON ps.warga_nik = w.nik
    JOIN jenis_surat js ON ps.jenis_surat_id_jenis = js.id_jenis
    LEFT JOIN staff s ON ps.staff_id_staff = s.id_staff
    LEFT JOIN warga sw ON s.warga_nik = sw.nik
    WHERE LOWER(ps.status) = LOWER(input_status)
      AND ps.tanggal_pengajuan BETWEEN start_date AND end_date
    ORDER BY ps.tanggal_pengajuan DESC, nama_staff ASC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM permohonan_berdasar_status('2025-01-01', '2025-01-31', 'menunggu');
SELECT * FROM permohonan_berdasar_status('2025-01-01', '2025-01-31', 'diproses');
SELECT * FROM permohonan_berdasar_status('2025-01-01', '2025-01-31', 'selesai');
SELECT * FROM permohonan_berdasar_status('2025-01-01', '2025-01-31', 'ditolak');
DROP FUNCTION IF EXISTS permohonan_berdasar_status;

-- 3
-- kelompokkan permohonan yang jenis dokumennya mirip menggunakan kata kunci
CREATE OR REPLACE FUNCTION kelompokkan_permohonan_serupa(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    jenis_surat TEXT,
    menunggu BIGINT,
    diproses BIGINT,
    selesai BIGINT,
    ditolak BIGINT,
    total BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        sub.keyword AS jenis_surat,
        COUNT(*) FILTER (WHERE LOWER(sub.status) = 'menunggu') AS menunggu,
        COUNT(*) FILTER (WHERE LOWER(sub.status) = 'diproses') AS diproses,
        COUNT(*) FILTER (WHERE LOWER(sub.status) = 'selesai') AS selesai,
        COUNT(*) FILTER (WHERE LOWER(sub.status) = 'ditolak') AS ditolak,
        COUNT(*) AS total
    FROM (
        SELECT 
            ps.status,
            CASE
                WHEN LOWER(js.nama_surat) LIKE '%pemakzulan%' THEN 'Surat Pemakzulan'
                WHEN LOWER(js.nama_surat) LIKE '%permintaan%' THEN 'Surat Permintaan'
                WHEN LOWER(js.nama_surat) LIKE '%pemunduran%' THEN 'Surat Pemunduran'
                WHEN LOWER(js.nama_surat) LIKE '%keterangan%' THEN 'Surat Keterangan'
                WHEN LOWER(js.nama_surat) LIKE '%dokumen%' THEN 'Surat Dokumen'
                WHEN LOWER(js.nama_surat) LIKE '%kepemilikan%' THEN 'Surat Kepemilikan'
                WHEN LOWER(js.nama_surat) LIKE '%perizinan%' THEN 'Surat Perizinan'
                WHEN LOWER(js.nama_surat) LIKE '%pengantar%' THEN 'Surat Pengantar'
                WHEN LOWER(js.nama_surat) LIKE '%tanah%' THEN 'Surat Tanah'
                ELSE NULL
            END AS keyword
        FROM permohonan_surat ps
        JOIN jenis_surat js ON ps.jenis_surat_id_jenis = js.id_jenis
        WHERE ps.tanggal_pengajuan BETWEEN start_date AND end_date
    ) AS sub
    WHERE sub.keyword IS NOT NULL
    GROUP BY sub.keyword
    ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM kelompokkan_permohonan_serupa('2025-01-01', '2025-01-31');
DROP FUNCTION IF EXISTS kelompokkan_permohonan_serupa;

-- 4
-- tampilkan semua permohonan surat oleh warga tertentu
CREATE OR REPLACE FUNCTION riwayat_permohonan_warga(
    nik_warga VARCHAR
)
RETURNS TABLE (
    id_permohonan VARCHAR,
    tanggal_pengajuan DATE,
    nama_surat VARCHAR,
    keterangan TEXT,
    status_permohonan VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ps.id_permohonan,
        ps.tanggal_pengajuan,
        js.nama_surat,
        ps.keterangan,
        ps.status
    FROM permohonan_surat ps
    JOIN jenis_surat js ON ps.jenis_surat_id_jenis = js.id_jenis
    WHERE ps.warga_nik = nik_warga
    ORDER BY ps.tanggal_pengajuan DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM riwayat_permohonan_warga('4737622221000005');
DROP FUNCTION IF EXISTS riwayat_permohonan_warga;

-- 5
-- tampilkan detail permohonan
CREATE OR REPLACE FUNCTION detail_permohonan(
    input_id_permohonan VARCHAR
)
RETURNS TABLE (
    key TEXT,
    value TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM (
        SELECT
            unnest(ARRAY[
                'id_permohonan','tanggal_pengajuan',
                'nama_surat','keterangan','nama_pemohon',
                'status_permohonan','tanggal_respon','nama_staff',
                'dokumen','nomor_surat','url_file_surat'
            ]) AS key,
            unnest(ARRAY[
                ps.id_permohonan::TEXT,
                ps.tanggal_pengajuan::TEXT,
                js.nama_surat,ps.keterangan,w.nama,ps.status,
                COALESCE(rp.tanggal_respon::TEXT, ''),
                COALESCE(sw.nama, ''),
                (
                    SELECT COALESCE(STRING_AGG(dp.jenis_dokumen, ', '), '')
                    FROM dokumen_persyaratan dp
                    WHERE dp.permohonan_surat_id_permohonan = ps.id_permohonan
                ),
                COALESCE(srt.nomor_surat, ''),
                COALESCE(srt.url_file, '')
            ]) AS value
        FROM permohonan_surat ps
        JOIN warga w ON ps.warga_nik = w.nik
        JOIN jenis_surat js ON ps.jenis_surat_id_jenis = js.id_jenis
        LEFT JOIN respon_permohonan rp ON rp.permohonan_surat_id_permohonan = ps.id_permohonan
        LEFT JOIN staff st ON rp.staff_id_staff = st.id_staff
        LEFT JOIN warga sw ON st.warga_nik = sw.nik
        LEFT JOIN surat srt ON srt.respon_permohonan_id_respon = rp.id_respon
        WHERE ps.id_permohonan = input_id_permohonan
    ) AS detail;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM detail_permohonan('PRMHN000273UAOTP');
DROP FUNCTION IF EXISTS detail_permohonan;

-- 6
-- tampilkan daftar semua surat yang telah dicetak dalam periode tertentu
-- lengkap dengan data pemohon, jenis surat, dan staff pencetak
CREATE OR REPLACE FUNCTION daftar_surat_dicetak(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    id_surat VARCHAR,
    tanggal_cetak DATE,
    nomor_surat VARCHAR,
    nama_surat VARCHAR,
    nama_warga VARCHAR,
    nama_staff VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        srt.id_surat,
        srt.tanggal_cetak,
        srt.nomor_surat,
        js.nama_surat,
        w.nama AS nama_warga,
        sw.nama AS nama_staff
    FROM surat srt
    JOIN respon_permohonan rp ON srt.respon_permohonan_id_respon = rp.id_respon
    JOIN permohonan_surat ps ON rp.permohonan_surat_id_permohonan = ps.id_permohonan
    JOIN warga w ON ps.warga_nik = w.nik
    JOIN jenis_surat js ON ps.jenis_surat_id_jenis = js.id_jenis
    JOIN staff st ON rp.staff_id_staff = st.id_staff
    JOIN warga sw ON st.warga_nik = sw.nik
    WHERE srt.tanggal_cetak BETWEEN start_date AND end_date
    ORDER BY srt.tanggal_cetak ASC, sw.nama ASC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM daftar_surat_dicetak('2025-01-01', '2025-01-31');
DROP FUNCTION IF EXISTS daftar_surat_dicetak;

-- 7
-- tampilkan permohonan pada periode tertentu yang tidak memiliki dokumen persyaratan
CREATE OR REPLACE FUNCTION permohonan_tidak_lengkap(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    id_permohonan VARCHAR,
    tanggal_pengajuan DATE,
    nama_warga VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ps.id_permohonan,
        ps.tanggal_pengajuan,
        w.nama
    FROM permohonan_surat ps
    JOIN warga w ON ps.warga_nik = w.nik
    LEFT JOIN dokumen_persyaratan dp ON dp.permohonan_surat_id_permohonan = ps.id_permohonan
    WHERE dp.id_dokumen IS NULL
      AND ps.tanggal_pengajuan BETWEEN start_date AND end_date
    ORDER BY ps.tanggal_pengajuan DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM permohonan_tidak_lengkap('2025-01-01', '2025-01-31');
DROP FUNCTION IF EXISTS permohonan_tidak_lengkap;