-- 1
-- hitung jumlah pengaduan berdasarkan status dalam periode tertentu
CREATE OR REPLACE FUNCTION distribusi_status_pengaduan(
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
        pg.status,
        COUNT(*) AS jumlah
    FROM pengaduan pg
    WHERE pg.tanggal_pengaduan BETWEEN start_date AND end_date
    GROUP BY pg.status
    ORDER BY jumlah DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM distribusi_status_pengaduan('2025-01-01', '2025-01-31');
DROP FUNCTION IF EXISTS distribusi_status_pengaduan;

-- 2
-- tampilkan semua pengaduan berdasar status
-- (menunggu, diproses, selesai)
CREATE OR REPLACE FUNCTION pengaduan_berdasar_status(
    start_date DATE,
    end_date DATE,
    input_status VARCHAR
)
RETURNS TABLE (
    id_pengaduan VARCHAR,
    tanggal_pengaduan DATE,
    nama_warga VARCHAR,
    kategori VARCHAR,
    isi_pengaduan TEXT,
    nama_staff VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pg.id_pengaduan,
        pg.tanggal_pengaduan,
        w.nama AS nama_warga,
        pg.kategori,
        pg.isi_pengaduan,
        CASE 
            WHEN LOWER(pg.status) != 'menunggu' THEN sw.nama
            ELSE NULL
        END AS nama_staff
    FROM pengaduan pg
    JOIN warga w ON pg.warga_nik = w.nik
    LEFT JOIN tanggapan_pengaduan tp ON tp.pengaduan_id_pengaduan = pg.id_pengaduan
    LEFT JOIN staff s ON tp.staff_id_staff = s.id_staff
    LEFT JOIN warga sw ON s.warga_nik = sw.nik
    WHERE LOWER(pg.status) = LOWER(input_status)
      AND pg.tanggal_pengaduan BETWEEN start_date AND end_date
    ORDER BY pg.tanggal_pengaduan DESC, nama_staff ASC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM pengaduan_berdasar_status('2025-01-01', '2025-01-31', 'menunggu');
SELECT * FROM pengaduan_berdasar_status('2025-01-01', '2025-01-31', 'diproses');
SELECT * FROM pengaduan_berdasar_status('2025-01-01', '2025-01-31', 'selesai');
DROP FUNCTION IF EXISTS pengaduan_berdasar_status;

-- 3
-- hitung jumlah pengaduan berdasar kategori pada periode tertentu
CREATE OR REPLACE FUNCTION distribusi_pengaduan_per_kategori(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    kategori_pengaduan VARCHAR,
    jumlah BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pg.kategori,
        COUNT(*) AS jumlah
    FROM pengaduan pg
    WHERE pg.tanggal_pengaduan BETWEEN start_date AND end_date
    GROUP BY pg.kategori
    ORDER BY jumlah DESC;
END
$$ LANGUAGE plpgsql;
SELECT * FROM distribusi_pengaduan_per_kategori('2025-01-01', '2025-01-31');
DROP FUNCTION IF EXISTS distribusi_pengaduan_per_kategori;

-- 4
-- tampilkan semua pengaduan oleh warga tertentu
CREATE OR REPLACE FUNCTION riwayat_pengaduan_warga(
    nik_warga VARCHAR
)
RETURNS TABLE (
    id_pengaduan VARCHAR,
    tanggal_pengaduan DATE,
    kategori VARCHAR,
    isi_pengaduan TEXT,
    status_pengaduan VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pg.id_pengaduan,
        pg.tanggal_pengaduan,
        pg.kategori,
        pg.isi_pengaduan,
        pg.status
    FROM pengaduan pg
    WHERE pg.warga_nik = nik_warga
    ORDER BY pg.tanggal_pengaduan DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM riwayat_pengaduan_warga('4737622221000005');
DROP FUNCTION IF EXISTS riwayat_pengaduan_warga;

-- 5
-- tampilkan detail pengaduan
CREATE OR REPLACE FUNCTION detail_pengaduan(
    input_id_pengaduan VARCHAR
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
                'id_pengaduan','tanggal_pengaduan','kategori',
                'isi_pengaduan','nama_pengadu','status_pengaduan',
                'tanggal_tanggapan','nama_staff','isi_tanggapan'
            ]) AS key,
            unnest(ARRAY[
                pg.id_pengaduan::TEXT,
                pg.tanggal_pengaduan::TEXT,
                pg.kategori,pg.isi_pengaduan,w.nama,pg.status,
                COALESCE(tp.tanggal_tanggapan::TEXT, ''),
                COALESCE(sw.nama, ''),
                COALESCE(tp.isi_tanggapan, '')
            ]) AS value
        FROM pengaduan pg
        JOIN warga w ON pg.warga_nik = w.nik
        LEFT JOIN tanggapan_pengaduan tp ON tp.pengaduan_id_pengaduan = pg.id_pengaduan
        LEFT JOIN staff st ON tp.staff_id_staff = st.id_staff
        LEFT JOIN warga sw ON st.warga_nik = sw.nik
        WHERE pg.id_pengaduan = input_id_pengaduan
    ) AS detail;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM detail_pengaduan('PNGDN000003UJDCL');
DROP FUNCTION IF EXISTS detail_pengaduan;