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

[Query Create Table](/sql/create_table.sql)

| CDM                     | PDM                     |
| ----------------------- | ----------------------- |
| ![cdm](/assets/cdm.png) | ![pdm](/assets/pdm.png) |









