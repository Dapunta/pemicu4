-- Independent

-- Table: jenis_surat
CREATE TABLE jenis_surat (
    id_jenis varchar(16)  NOT NULL,
    nama_surat varchar(50)  NOT NULL,
    CONSTRAINT jenis_surat_pk PRIMARY KEY (id_jenis)
);

-- Table: keluarga
CREATE TABLE keluarga (
    no_kk varchar(16)  NOT NULL,
    alamat text  NOT NULL,
    rt int  NOT NULL,
    rw int  NOT NULL,
    CONSTRAINT keluarga_pk PRIMARY KEY (no_kk)
);

-- Table: pekerjaan
CREATE TABLE pekerjaan (
    id_pekerjaan varchar(16)  NOT NULL,
    nama varchar(100)  NOT NULL,
    gaji_per_bulan int  NULL,
    CONSTRAINT pekerjaan_pk PRIMARY KEY (id_pekerjaan)
);

-- Table: pendidikan
CREATE TABLE pendidikan (
    id_pendidikan varchar(16)  NOT NULL,
    nama varchar(50)  NOT NULL,
    CONSTRAINT pendidikan_pk PRIMARY KEY (id_pendidikan)
);

-- Not Independent

-- Table: warga
-- Requirement : keluarga, pekerjaan, pendidikan
CREATE TABLE warga (
    nik varchar(16)  NOT NULL,
    nama varchar(100)  NOT NULL,
    jenis_kelamin char(1)  NOT NULL,
    agama varchar(20)  NOT NULL,
    tempat_lahir varchar(50)  NOT NULL,
    tanggal_lahir date  NOT NULL,
    alamat text  NOT NULL,
    status_keluarga varchar(20)  NOT NULL,
    status_perkawinan varchar(20)  NOT NULL,
    keluarga_no_kk varchar(16)  NOT NULL,
    pekerjaan_id_pekerjaan varchar(16)  NULL,
    pendidikan_id_pendidikan varchar(16)  NULL,
    CONSTRAINT warga_pk PRIMARY KEY (nik)
);

-- Table: staff
-- Requirement : warga
CREATE TABLE staff (
    id_staff varchar(16)  NOT NULL,
    jabatan varchar(50)  NOT NULL,
    username varchar(50)  NOT NULL,
    password text  NOT NULL,
    warga_nik varchar(16)  NOT NULL,
    CONSTRAINT AK_0 UNIQUE (username) NOT DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT staff_pk PRIMARY KEY (id_staff)
);

-- Table: pengaduan
-- Requirement : warga
CREATE TABLE pengaduan (
    id_pengaduan varchar(16)  NOT NULL,
    tanggal_pengaduan date  NOT NULL,
    kategori varchar(50)  NOT NULL,
    isi_pengaduan text  NOT NULL,
    status varchar(20)  NOT NULL DEFAULT 'menunggu',
    warga_nik varchar(16)  NOT NULL,
    CONSTRAINT pengaduan_pk PRIMARY KEY (id_pengaduan)
);

-- Table: tanggapan_pengaduan
-- Requirement : pengaduan, staff
CREATE TABLE tanggapan_pengaduan (
    id_tanggapan varchar(16)  NOT NULL,
    tanggal_tanggapan date  NOT NULL,
    isi_tanggapan text  NOT NULL,
    pengaduan_id_pengaduan varchar(16)  NOT NULL,
    staff_id_staff varchar(16)  NOT NULL,
    CONSTRAINT tanggapan_pengaduan_pk PRIMARY KEY (id_tanggapan)
);

-- Table: permohonan_surat
-- Requirement : warga, staff, jenis_surat
CREATE TABLE permohonan_surat (
    id_permohonan varchar(16)  NOT NULL,
    tanggal_pengajuan date  NOT NULL,
    status varchar(20)  NOT NULL DEFAULT 'menunggu',
    keterangan text  NULL,
    warga_nik varchar(16)  NOT NULL,
    staff_id_staff varchar(16)  NOT NULL,
    jenis_surat_id_jenis varchar(16)  NOT NULL,
    CONSTRAINT permohonan_surat_pk PRIMARY KEY (id_permohonan)
);

-- Table: dokumen_persyaratan
-- Requirement : permohonan_surat
CREATE TABLE dokumen_persyaratan (
    id_dokumen varchar(16)  NOT NULL,
    jenis_dokumen varchar(50)  NOT NULL,
    url_file text  NOT NULL,
    permohonan_surat_id_permohonan varchar(16)  NOT NULL,
    CONSTRAINT dokumen_persyaratan_pk PRIMARY KEY (id_dokumen)
);

-- Table: respon_permohonan
-- Requirement : permohonan_surat, staff
CREATE TABLE respon_permohonan (
    id_respon varchar(16)  NOT NULL,
    tanggal_respon date  NOT NULL,
    status varchar(20)  NOT NULL,
    catatan text  NOT NULL,
    permohonan_surat_id_permohonan varchar(16)  NOT NULL,
    staff_id_staff varchar(16)  NOT NULL,
    CONSTRAINT respon_permohonan_pk PRIMARY KEY (id_respon)
);

-- Table: surat
-- Requirement : respon_permohonan
CREATE TABLE surat (
    id_surat varchar(16)  NOT NULL,
    nomor_surat varchar(50)  NOT NULL,
    tanggal_cetak date  NOT NULL,
    url_file text  NOT NULL,
    respon_permohonan_id_respon varchar(16)  NOT NULL,
    CONSTRAINT surat_pk PRIMARY KEY (id_surat)
);

-- foreign keys

ALTER TABLE warga ADD CONSTRAINT FK_0
    FOREIGN KEY (keluarga_no_kk)
    REFERENCES keluarga (no_kk)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE warga ADD CONSTRAINT FK_1
    FOREIGN KEY (pekerjaan_id_pekerjaan)
    REFERENCES pekerjaan (id_pekerjaan)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE warga ADD CONSTRAINT FK_2
    FOREIGN KEY (pendidikan_id_pendidikan)
    REFERENCES pendidikan (id_pendidikan)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE staff ADD CONSTRAINT FK_3
    FOREIGN KEY (warga_nik)
    REFERENCES warga (nik)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE permohonan_surat ADD CONSTRAINT FK_4
    FOREIGN KEY (warga_nik)
    REFERENCES warga (nik)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE permohonan_surat ADD CONSTRAINT FK_5
    FOREIGN KEY (staff_id_staff)
    REFERENCES staff (id_staff)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE permohonan_surat ADD CONSTRAINT FK_6
    FOREIGN KEY (jenis_surat_id_jenis)
    REFERENCES jenis_surat (id_jenis)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE dokumen_persyaratan ADD CONSTRAINT FK_7
    FOREIGN KEY (permohonan_surat_id_permohonan)
    REFERENCES permohonan_surat (id_permohonan)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE respon_permohonan ADD CONSTRAINT FK_8
    FOREIGN KEY (permohonan_surat_id_permohonan)
    REFERENCES permohonan_surat (id_permohonan)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE respon_permohonan ADD CONSTRAINT FK_9
    FOREIGN KEY (staff_id_staff)
    REFERENCES staff (id_staff)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE surat ADD CONSTRAINT FK_10
    FOREIGN KEY (respon_permohonan_id_respon)
    REFERENCES respon_permohonan (id_respon)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE pengaduan ADD CONSTRAINT FK_11
    FOREIGN KEY (warga_nik)
    REFERENCES warga (nik)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE tanggapan_pengaduan ADD CONSTRAINT FK_12
    FOREIGN KEY (pengaduan_id_pengaduan)
    REFERENCES pengaduan (id_pengaduan)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE tanggapan_pengaduan ADD CONSTRAINT FK_13
    FOREIGN KEY (staff_id_staff)
    REFERENCES staff (id_staff)
    ON UPDATE CASCADE ON DELETE CASCADE
    NOT DEFERRABLE INITIALLY IMMEDIATE;