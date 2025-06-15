# Pemicu 4

Judul : Sistem Manajemen Pelayanan Publik dan Administrasi Desa untuk Meningkatkan Efisiensi Layanan Masyarakat  
Kelompok : E7

| NRP        | Nama                             |
| ---------- | -------------------------------- |
| 5025231124 | Christoforus Indra Bagus Pratama |
| 5025231187 | Dapunta Adyapaksi Ratyanasja     |
| 5025231213 | Rafif Thariq Dhiyaulhaqi         |
| 5025231236 | Fitra Arya Rajendra              |
| 5025231298 | Izan Nafis Rahman                |

### Topik yang dipilih

- **Manajemen Pelayanan Warga**
    Mengelola permohonan surat keterangan dan dokumen warga seperti KTP, KK, surat keterangan domisili, surat pengantar, dan dokumen administrasi lainnya.
- **Manajemen Pendataan Penduduk**
    Memfasilitasi pendataan warga, termasuk data keluarga, data pendidikan, pekerjaan, dan status ekonomi untuk mendukung pengambilan keputusan.
- **Pengaduan Masyarakat**
    Mengelola keluhan dan saran dari warga mengenai pelayanan publik dan pembangunan desa.

### Business Rule

- Warga harus terdaftar *(punya NIK yang valid)* untuk bisa melakukan pengaduan atau permohonan surat
- Satu warga hanya dapat mengajukan satu permohonan surat dengan status *“Menunggu”* dalam satu waktu
- Surat keterangan hanya dapat dicetak jika permohonan sudah disetujui
- Setiap permohonan surat harus memiliki jenis surat yang valid dan ditangani oleh satu staff desa
- Setiap tanggapan pengaduan wajib disertai ID staff yang menanggapi.

### Pekerjaan 1

| CDM                     | PDM                     |
| ----------------------- | ----------------------- |
| ![cdm](/assets/cdm.png) | ![pdm](/assets/pdm.png) |

### Pekerjaan 2

**Data Definition Language**
- [Query Create Table](/sql/create_table.sql)
- [Query Drop Table](/sql/drop_table.sql)

**Generator**
- Generator : [generate_data.py](/python/generate_data.py)
- Convert `.txt` to `.sql` : [convert_txt_to_sql.py](/python/convert_txt_to_sql.py)

**Data Dummy**
- Query Create & Insert : [create_insert.zip](https://drive.google.com/file/d/1EmcPnNvNC6ExKUNF1RoNU18jqORm4JIP/view?usp=sharing)

**Cara Insert**
- Default
    ```sh
    psql -U [nama_user] -d [nama_database] -f [nama_file.sql]
    ```
- Contoh
    ```sh
    psql -U postgres -d desa -f insert_warga.sql
    ```

**Hasil Insert**  
| Table               | Jumlah Data | Screenshot |
| ------------------- | ----------- | ---------- |
| jenis_surat         | 200000 | ![](/assets/pekerjaan2/insert_jenis_surat.png) |
| keluarga            | 200000 | ![](/assets/pekerjaan2/insert_keluarga.png) |
| pekerjaan           | 200000 | ![](/assets/pekerjaan2/insert_pekerjaan.png) |
| pendidikan          | 10 | ![](/assets/pekerjaan2/insert_pendidikan.png) |
| warga               | 400000 | ![](/assets/pekerjaan2/insert_warga.png) |
| staff               | 25 | ![](/assets/pekerjaan2/insert_staff.png) |
| pengaduan           | 500000 | ![](/assets/pekerjaan2/insert_pengaduan.png) |
| tanggapan_pengaduan | 333615 | ![](/assets/pekerjaan2/insert_tanggapan_pengaduan.png) |
| permohonan_surat    | 600000 | ![](/assets/pekerjaan2/insert_permohonan_surat.png) |
| dokumen_persyaratan | 449863 | ![](/assets/pekerjaan2/insert_dokumen_persyaratan.png) |
| respon_permohonan   | 450309 | ![](/assets/pekerjaan2/insert_respon_permohonan.png) |
| surat               | 149605 | ![](/assets/pekerjaan2/insert_surat.png) |


