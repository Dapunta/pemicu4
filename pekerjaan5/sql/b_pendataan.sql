-- 1
-- rekap tingkat pendidikan warga
CREATE OR REPLACE FUNCTION rekap_pendidikan_warga()
RETURNS TABLE (
    tingkat_pendidikan VARCHAR,
    jumlah_warga BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.nama AS tingkat_pendidikan,
        COUNT(*) AS jumlah_warga
    FROM warga w
    LEFT JOIN pendidikan p ON w.pendidikan_id_pendidikan = p.id_pendidikan
    GROUP BY p.nama
    ORDER BY jumlah_warga DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM rekap_pendidikan_warga();
DROP FUNCTION IF EXISTS rekap_pendidikan_warga;

-- 2
-- analisis kepadatan keluarga
CREATE OR REPLACE FUNCTION analisis_kepadatan_keluarga()
RETURNS TABLE (
    no_kk VARCHAR,
    alamat TEXT,
    rt INT,
    rw INT,
    jumlah_anggota BIGINT,
    anggota_keluarga TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        k.no_kk,
        k.alamat,
        k.rt,
        k.rw,
        COUNT(w.nik) AS jumlah_anggota,
        STRING_AGG(w.nama, ', ' ORDER BY w.jenis_kelamin ASC, w.nama) AS anggota_keluarga
    FROM keluarga k
    LEFT JOIN warga w ON w.keluarga_no_kk = k.no_kk
    GROUP BY k.no_kk, k.alamat, k.rt, k.rw
    ORDER BY jumlah_anggota DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM analisis_kepadatan_keluarga();
DROP FUNCTION IF EXISTS analisis_kepadatan_keluarga;

-- 3
-- lihat anggota keluarga
CREATE OR REPLACE FUNCTION lihat_anggota_keluarga(
    input_no_kk VARCHAR
)
RETURNS TABLE (
    nik VARCHAR,
    nama VARCHAR,
    jenis_kelamin CHAR(1),
    agama VARCHAR,
    tempat_lahir VARCHAR,
    tanggal_lahir DATE,
    alamat TEXT,
    status_keluarga VARCHAR,
    status_perkawinan VARCHAR,
    nama_pendidikan VARCHAR,
    nama_pekerjaan VARCHAR,
    gaji_per_bulan INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        w.nik,
        w.nama,
        w.jenis_kelamin,
        w.agama,
        w.tempat_lahir,
        w.tanggal_lahir,
        w.alamat,
        w.status_keluarga,
        w.status_perkawinan,
        pd.nama AS nama_pendidikan,
        pk.nama AS nama_pekerjaan,
        pk.gaji_per_bulan
    FROM warga w
    LEFT JOIN pendidikan pd ON w.pendidikan_id_pendidikan = pd.id_pendidikan
    LEFT JOIN pekerjaan pk ON w.pekerjaan_id_pekerjaan = pk.id_pekerjaan
    WHERE w.keluarga_no_kk = input_no_kk
    ORDER BY w.nik, w.nama;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM lihat_anggota_keluarga('KLRGA155593CSPOI');
DROP FUNCTION IF NOT EXISTS lihat_anggota_keluarga;

-- 4
-- lihat sebaran penghasilan berdasar tipe tertentu (warga/keluarga)
CREATE OR REPLACE FUNCTION sebaran_penghasilan(tipe TEXT)
RETURNS TABLE (
    range_gaji TEXT,
    kategori TEXT,
    jumlah BIGINT
) AS $$
BEGIN
    IF LOWER(tipe) = 'warga' THEN
        RETURN QUERY
        SELECT 
            CASE 
                WHEN p.gaji_per_bulan IS NULL THEN 'Tidak Bekerja'
                WHEN p.gaji_per_bulan < 1000000 THEN '< 1 Juta'
                WHEN p.gaji_per_bulan BETWEEN 1000000 AND 2999999 THEN '1 - 3 Juta'
                WHEN p.gaji_per_bulan BETWEEN 3000000 AND 3999999 THEN '3 - 4 Juta'
                WHEN p.gaji_per_bulan BETWEEN 4000000 AND 6999999 THEN '4 - 7 Juta'
                ELSE '> 7 Juta'
            END AS range_gaji,
            CASE 
                WHEN p.gaji_per_bulan IS NULL THEN 'bawah'
                WHEN p.gaji_per_bulan < 1000000 THEN 'bawah'
                WHEN p.gaji_per_bulan BETWEEN 1000000 AND 2999999 THEN 'menengah ke bawah'
                WHEN p.gaji_per_bulan BETWEEN 3000000 AND 3999999 THEN 'menengah'
                WHEN p.gaji_per_bulan BETWEEN 4000000 AND 6999999 THEN 'menengah ke atas'
                ELSE 'atas'
            END AS kategori,
            COUNT(*) AS jumlah
        FROM warga w
        LEFT JOIN pekerjaan p ON w.pekerjaan_id_pekerjaan = p.id_pekerjaan
        GROUP BY range_gaji, kategori
        ORDER BY jumlah DESC;

    ELSIF LOWER(tipe) = 'keluarga' THEN
        RETURN QUERY
        SELECT 
            CASE 
                WHEN rata_gaji = 0 THEN 'Tidak Bekerja'
                WHEN rata_gaji < 1000000 THEN '< 1 Juta'
                WHEN rata_gaji BETWEEN 1000000 AND 2999999 THEN '1 - 3 Juta'
                WHEN rata_gaji BETWEEN 3000000 AND 3999999 THEN '3 - 4 Juta'
                WHEN rata_gaji BETWEEN 4000000 AND 6999999 THEN '4 - 7 Juta'
                ELSE '> 7 Juta'
            END AS range_gaji,
            CASE 
                WHEN rata_gaji = 0 THEN 'bawah'
                WHEN rata_gaji < 1000000 THEN 'bawah'
                WHEN rata_gaji BETWEEN 1000000 AND 2999999 THEN 'menengah ke bawah'
                WHEN rata_gaji BETWEEN 3000000 AND 3999999 THEN 'menengah'
                WHEN rata_gaji BETWEEN 4000000 AND 6999999 THEN 'menengah ke atas'
                ELSE 'atas'
            END AS kategori,
            COUNT(*) AS jumlah
        FROM (
            SELECT 
                k.no_kk,
                COUNT(w.nik) AS jumlah_anggota,
                COALESCE(SUM(p.gaji_per_bulan), 0) AS total_gaji,
                CASE 
                    WHEN COUNT(w.nik) > 0 THEN 
                        COALESCE(SUM(p.gaji_per_bulan), 0)::NUMERIC / COUNT(w.nik)
                    ELSE NULL
                END AS rata_gaji
            FROM keluarga k
            LEFT JOIN warga w ON w.keluarga_no_kk = k.no_kk
            LEFT JOIN pekerjaan p ON w.pekerjaan_id_pekerjaan = p.id_pekerjaan
            GROUP BY k.no_kk
        ) AS sub
        WHERE rata_gaji IS NOT NULL
        GROUP BY range_gaji, kategori
        ORDER BY jumlah DESC;

    ELSE
        RAISE EXCEPTION 'Tipe hanya boleh ''warga'' atau ''keluarga''';
    END IF;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM sebaran_penghasilan('warga');
SELECT * FROM sebaran_penghasilan('keluarga');
DROP FUNCTION IF EXISTS sebaran_penghasilan;

-- 5
-- daftar warga dengan rentang penghasilan tertentu
CREATE OR REPLACE FUNCTION daftar_warga_berdasar_penghasilan(
    batas_bawah BIGINT,
    batas_atas BIGINT
)
RETURNS TABLE (
    nik VARCHAR,
    nama VARCHAR,
    nama_pekerjaan VARCHAR,
    gaji_per_bulan INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        w.nik,
        w.nama,
        p.nama AS nama_pekerjaan,
        COALESCE(p.gaji_per_bulan, 0) AS gaji_per_bulan
    FROM warga w
    LEFT JOIN pekerjaan p ON w.pekerjaan_id_pekerjaan = p.id_pekerjaan
    WHERE COALESCE(p.gaji_per_bulan, 0) BETWEEN batas_bawah AND batas_atas
    ORDER BY gaji_per_bulan DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM daftar_warga_berdasar_penghasilan(0, 0);
DROP FUNCTION IF EXISTS daftar_warga_berdasar_penghasilan;

-- 6
-- daftar keluarga dengan rentang penghasilan tertentu
CREATE OR REPLACE FUNCTION daftar_keluarga_berdasar_penghasilan(
    batas_bawah BIGINT,
    batas_atas BIGINT
)
RETURNS TABLE (
    no_kk VARCHAR,
    alamat TEXT,
    rt INT,
    rw INT,
    jumlah_anggota BIGINT,
    total_gaji BIGINT,
    rata_gaji_per_anggota NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        k.no_kk,
        k.alamat,
        k.rt,
        k.rw,
        sub.jumlah_anggota,
        sub.total_gaji,
        ROUND(sub.rata_gaji, 2) AS rata_gaji_per_anggota
    FROM keluarga k
    JOIN (
        SELECT 
            w.keluarga_no_kk,
            COUNT(w.nik) AS jumlah_anggota,
            SUM(COALESCE(p.gaji_per_bulan, 0)) AS total_gaji,
            CASE 
                WHEN COUNT(w.nik) > 0 THEN
                    SUM(COALESCE(p.gaji_per_bulan, 0))::NUMERIC / COUNT(w.nik)
                ELSE NULL
            END AS rata_gaji
        FROM warga w
        LEFT JOIN pekerjaan p ON w.pekerjaan_id_pekerjaan = p.id_pekerjaan
        GROUP BY w.keluarga_no_kk
    ) AS sub ON k.no_kk = sub.keluarga_no_kk
    WHERE sub.rata_gaji BETWEEN batas_bawah AND batas_atas
    ORDER BY sub.rata_gaji DESC, sub.total_gaji DESC;
END;
$$ LANGUAGE plpgsql;
SELECT * FROM daftar_keluarga_berdasar_penghasilan(0, 0);
DROP FUNCTION IF EXISTS daftar_keluarga_berdasar_penghasilan;