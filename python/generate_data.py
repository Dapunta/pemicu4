import os, random, string, hashlib, uuid
from faker import Faker
from datetime import datetime, timedelta

fake = Faker('id_ID')
folder = 'txt'

def generate_data(table_name: str) -> None:
    all_data = eval(f'generate_{table_name}')()
    save_to_txt(table_name, all_data)

def generate_numeric_id(count: int) -> list:
    return [str(i).zfill(len(str(count))) for i in range(1, count + 1)]

def save_to_txt(table_name: str, all_data: list):
    os.makedirs(folder, exist_ok=True)
    file_path = f'{folder}/{table_name}.txt'
    with open(file_path, 'w') as f:
        f.write('\n'.join(all_data) + '\n')

#--> jenis_surat
def generate_jenis_surat() -> list:
    all_data = []
    all_id_numeric = generate_numeric_id(200000)

    for i in all_id_numeric:

        #--> id_jenis
        id_jenis = f'JNSRT{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'
        
        #--> nama_surat
        list_head = ['Keterangan', 'Pemakzulan', 'Permintaan', 'Pemunduran', 'Dokumen', 'Kepemilikan', 'Tanah', 'Perizinan', 'Dokumen', 'Pengantar']
        nama_surat = f'Surat {random.choice(list_head)} {"".join(random.choices(string.ascii_uppercase, k=6)).title()}'
        
        #--> append
        all_data.append(f'{id_jenis}|{nama_surat}')
    
    return all_data

#--> keluarga
def generate_keluarga() -> list:
    all_data = []
    all_id_numeric = generate_numeric_id(200000)

    for i in all_id_numeric:

        #--> no_kk
        no_kk = f'KLRGA{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'

        #--> alamat
        alamat = fake.address().replace('\n', ', ')

        #--> rt & rw
        rt, rw = random.randint(1,100), random.randint(1,100)

        #--> append
        all_data.append(f'{no_kk}|{alamat}|{rt}|{rw}')

    return all_data

#--> pekerjaan
def generate_pekerjaan() -> list:
    all_data = []
    all_id_numeric = generate_numeric_id(200000)

    for i in all_id_numeric:

        #--> id_pekerjaan
        id_pekerjaan = f'PKRJN{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'

        #--> nama
        nama = fake.job().replace('\n', ', ')

        #--> gaji_per_bulan
        gaji_per_bulan = int('{}00000'.format(random.randint(5,100)))

        #--> append
        all_data.append(f'{id_pekerjaan}|{nama}|{gaji_per_bulan}')

    return all_data

#--> pendidikan
def generate_pendidikan() -> list:
    all_data = []
    grade_data = [
        'SD/MI/Sederajat', 'SMP/MTs/Sederajat', 'SMA/SMK/MA/Sederajat'
        'D1', 'D2', 'D3', 'D4', 'S1', 'S2', 'S3'
    ]
    all_id_numeric = generate_numeric_id(10)

    for i,x in zip(all_id_numeric, grade_data):

        #--> id_pendidikan
        id_pendidikan = f'PDDKN{i}{"".join(random.choices(string.ascii_uppercase, k=9))}'

        #--> nama
        nama = x

        #--> append
        all_data.append(f'{id_pendidikan}|{nama}')

    return all_data

#--> warga
def generate_warga() -> list:
    all_data = []
    all_id_numeric = generate_numeric_id(400000)

    #--> read table lain
    keluarga   : list[str] = open(f'{folder}/keluarga.txt','r').read().splitlines()
    pekerjaan  : list[str] = open(f'{folder}/pekerjaan.txt','r').read().splitlines()
    pendidikan : list[str] = open(f'{folder}/pendidikan.txt','r').read().splitlines()

    #--> parsing kebutuhan kolom dari table lain
    list_keluarga_no_kk : list[str] = [i.split('|')[0] for i in keluarga]
    list_pekerjaan_id   : list[str] = [i.split('|')[0] for i in pekerjaan]
    list_pendidikan_id  : list[str] = [i.split('|')[0] for i in pendidikan]

    for i in all_id_numeric:

        #--> nik
        nik = '{}{}'.format(random.randint(3000000000,5000000000), i)

        #--> jenis_kelamin
        jenis_kelamin = random.choice(['L','P'])

        #--> nama
        nama = "{} {}".format(fake.first_name_male(), fake.last_name()) if jenis_kelamin == 'L' else "{} {}".format(fake.first_name_female(), fake.last_name())

        #--> agama
        agama = random.choice(['islam', 'kristen katolik', 'kristen protestan', 'hindu', 'budha', 'konghucu']).title()

        #--> tempat_lahir
        tempat_lahir = fake.city().split(',')[0]

        #--> tanggal_lahir
        tanggal_lahir = fake.date_of_birth(minimum_age=17, maximum_age=80).strftime('%Y-%m-%d')

        #--> alamat
        alamat = fake.address().replace('\n', ', ')

        #--> status_keluarga
        status_keluarga = random.choice(['kepala keluarga', 'istri', 'anak', 'orang tua', 'mertua', 'menantu']).title()

        #--> status_perkawinan
        status_perkawinan = random.choice(['kawin', 'belum kawin']).title()

        #--> keluarga_no_kk, pekerjaan_id_pekerjaan, pendidikan_id_pendidikan
        keluarga_no_kk, pekerjaan_id_pekerjaan, pendidikan_id_pendidikan = random.choice(list_keluarga_no_kk), random.choice(list_pekerjaan_id), random.choice(list_pendidikan_id)

        #--> append
        all_data.append(f'{nik}|{nama}|{jenis_kelamin}|{agama}|{tempat_lahir}|{tanggal_lahir}|{alamat}|{status_keluarga}|{status_perkawinan}|{keluarga_no_kk}|{pekerjaan_id_pekerjaan}|{pendidikan_id_pendidikan}')

    return all_data

#--> staff
def generate_staff() -> list:
    all_data = []
    all_id_numeric = generate_numeric_id(25)

    #--> read table lain
    warga : list[str] = open(f'{folder}/warga.txt','r').read().splitlines()

    #--> parsing kebutuhan kolom dari table lain
    list_warga_nik_nama : list[str] = ['{}|{}'.format(i.split('|')[0],i.split('|')[1]) for i in warga]

    #--> list jabatan
    list_jabatan = [
        'Kepala Desa',
        'Wakil Kepala Desa',
        'Sekretaris 1 Desa',
        'Sekretaris 2 Desa',
        'Bendahara 1 Desa',
        'Bendahara 2 Desa',
        'Kasi Pemerintahan',
        'Kasi Kesejahteraan',
        'Kasi Pelayanan',
        'Kaur Umum dan Tata Usaha',
        'Kaur Umum dan Tata Usaha',
        'Kaur Keuangan',
        'Kaur Perencanaan',
        'Operator SIAK / Admin Kependudukan',
        'Operator SIAK / Admin Kependudukan',
        'Petugas Pelayanan Surat',
        'Petugas Pelayanan Surat',
        'Petugas Pengaduan Masyarakat',
        'Petugas Pengaduan Masyarakat',
        'Staf IT / Sistem Informasi Desa',
        'Staf IT / Sistem Informasi Desa',
        'Staf Pelayanan Umum',
        'Staf Pelayanan Umum',
        'Staf Pelayanan Umum',
        'Kepala Dusun',
    ]

    for i,j in zip(all_id_numeric, list_jabatan):

        #--> id_staff
        id_staff = f'STAFF{i}{"".join(random.choices(string.ascii_uppercase, k=9))}'

        #--> data warga
        nik_nama = random.choice(list_warga_nik_nama)

        #--> jabatan
        jabatan = j

        #--> username
        username = nik_nama.split('|')[1].lower().replace(' ','') + str(i)

        #--> password
        password = hashlib.md5(''.join(random.choices(string.ascii_lowercase, k=9)).encode()).hexdigest()

        #--> warga_nik
        warga_nik = nik_nama.split('|')[0]

        #--> append
        all_data.append(f'{id_staff}|{jabatan}|{username}|{password}|{warga_nik}')

    return all_data

#--> pengaduan
def generate_pengaduan() -> list:
    all_data = []
    all_id_numeric = generate_numeric_id(500000)

    #--> read table lain
    warga : list[str] = open(f'{folder}/warga.txt','r').read().splitlines()

    #--> parsing kebutuhan kolom dari table lain
    list_warga_nik : list[str] = [i.split('|')[0] for i in warga]

    #--> pasangan data
    list_pasangan_data = [
        {'kategori': 'Fasilitas Umum', 'isi_pengaduan': ['Kerusakan jalan', 'Perusakan fasilitas publik', 'Pelapukan bangunan', 'Vandalisme di taman', 'Penyalahgunaan aula desa']},
        {'kategori': 'Kesehatan', 'isi_pengaduan': ['Wabah demam berdarah', 'Penyakit menular', 'Kematian mendadak', 'Kurangnya tenaga medis', 'Obat-obatan tidak tersedia']},
        {'kategori': 'Kebersihan Lingkungan', 'isi_pengaduan': ['Buang sampah sembarangan', 'Kotoran menumpuk', 'Sungai mampet', 'Saluran air tersumbat', 'Kurangnya petugas kebersihan']},
        {'kategori': 'Penerangan Jalan', 'isi_pengaduan': ['Lampu jalan mati', 'Tidak ada penerangan di gang', 'Lampu redup', 'Tiang listrik miring', 'Lampu sering padam']},
        {'kategori': 'Keamanan', 'isi_pengaduan': ['Pencurian kendaraan', 'Perkelahian warga', 'Geng motor meresahkan', 'Tidak ada ronda malam', 'Kejadian perampokan']},
        {'kategori': 'Pembangunan Infrastruktur', 'isi_pengaduan': ['Jalan rusak belum diperbaiki', 'Proyek mangkrak', 'Drainase buruk', 'Bangunan sekolah bocor', 'Jembatan tidak layak']},
        {'kategori': 'Pelayanan Administrasi', 'isi_pengaduan': ['Pelayanan lambat', 'Petugas tidak ramah', 'Kesalahan data di KK', 'Susah mengurus surat domisili', 'Sistem sering offline']},
        {'kategori': 'Data Kependudukan', 'isi_pengaduan': ['Nama salah di KTP', 'Data tidak sinkron', 'NIK tidak terdaftar', 'KTP belum jadi', 'Kartu keluarga hilang']},
        {'kategori': 'Kegiatan Sosial', 'isi_pengaduan': ['Tidak transparan dana kegiatan', 'Kegiatan tidak bermanfaat', 'Kurangnya partisipasi warga', 'Pemilihan pengurus tidak adil', 'Tidak ada laporan pertanggungjawaban']},
        {'kategori': 'Gangguan Tetangga', 'isi_pengaduan': ['Terlalu bising', 'Membuang sampah ke rumah tetangga', 'Perkelahian antar warga', 'Gangguan hewan peliharaan', 'Pelanggaran batas tanah']},
        {'kategori': 'Bantuan Sosial', 'isi_pengaduan': ['Tidak mendapat bantuan', 'Pembagian tidak adil', 'Data penerima tidak tepat', 'Bantuan salah sasaran', 'Bantuan tidak diterima']},
        {'kategori': 'Korupsi dan Penyalahgunaan Anggaran', 'isi_pengaduan': ['Dana desa tidak transparan', 'Laporan keuangan fiktif', 'Penyalahgunaan wewenang', 'Mark-up anggaran', 'Pembangunan tidak sesuai RAB']}
    ]

    for i in all_id_numeric:

        #--> id_pengaduan
        id_pengaduan = f'PNGDN{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'

        #--> tanggal_pengaduan
        tanggal_pengaduan = fake.date_between(start_date='-1y', end_date='today').strftime('%Y-%m-%d')

        #--> data_pengaduan
        data_pengaduan = random.choice(list_pasangan_data)

        #--> kategori
        kategori = data_pengaduan['kategori']

        #--> isi_pengaduan
        isi_pengaduan = '{} di {}'.format(random.choice(data_pengaduan['isi_pengaduan']), ''.join(random.choices(string.ascii_uppercase, k=6)).title())

        #--> status
        status = random.choice(['menunggu','diproses','selesai'])

        #--> warga_nik
        warga_nik = random.choice(list_warga_nik)

        #--> append
        all_data.append(f'{id_pengaduan}|{tanggal_pengaduan}|{kategori}|{isi_pengaduan}|{status}|{warga_nik}')

    return all_data

#--> tanggapan_pengaduan
def generate_tanggapan_pengaduan() -> list:
    all_data = []

    #--> read table lain
    list_pengaduan : list[str] = open(f'{folder}/pengaduan.txt','r').read().splitlines()
    list_staff : list[str] = open(f'{folder}/staff.txt','r').read().splitlines()

    #--> sortir selain menunggu
    list_pengaduan : list[str] = [i for i in list_pengaduan if i.split('|')[4].lower() != 'menunggu']

    #--> parsing kebutuhan kolom dari table lain
    list_staff_id : list[str] = [i.split('|')[0] for i in list_staff]

    all_id_numeric = generate_numeric_id(len(list_pengaduan))

    for i,pengaduan in zip(all_id_numeric,list_pengaduan):

        #--> id_tanggapan
        id_tanggapan = f'TNGPN{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'

        #--> tanggal_tanggapan
        old_date = datetime.strptime(pengaduan.split('|')[1], "%Y-%m-%d")
        new_date = old_date + timedelta(days=random.randint(1,14))
        tanggal_tanggapan = new_date.strftime("%Y-%m-%d")

        #--> isi_tanggapan
        status = pengaduan.split('|')[4].lower()
        isi_pengaduan = pengaduan.split('|')[3]
        if status == 'diproses':
            isi_tanggapan = 'Pengaduan anda mengenai {} sedang diproses, mohon bersabar. terima kasih'.format(isi_pengaduan.lower())
        else:
            isi_tanggapan = '{} sudah kami tangani. terima kasih'.format(isi_pengaduan)

        #--> pengaduan_id_pengaduan
        pengaduan_id_pengaduan = pengaduan.split('|')[0]

        #--> staff_id_staff
        staff_id_staff = random.choice(list_staff_id)

        #--> append
        all_data.append(f'{id_tanggapan}|{tanggal_tanggapan}|{isi_tanggapan}|{pengaduan_id_pengaduan}|{staff_id_staff}')

    return all_data

#--> permohonan_surat
def generate_permohonan_surat() -> list:
    all_data = []
    all_id_numeric = generate_numeric_id(600000)

    #--> read table lain
    warga       : list[str] = open(f'{folder}/warga.txt','r').read().splitlines()
    staff       : list[str] = open(f'{folder}/staff.txt','r').read().splitlines()
    jenis_surat : list[str] = open(f'{folder}/jenis_surat.txt','r').read().splitlines()

    #--> parsing kebutuhan kolom dari table lain
    list_warga_nik       : list[str] = [i.split('|')[0] for i in warga]
    list_staff_id        : list[str] = [i.split('|')[0] for i in staff]

    for i in all_id_numeric:

        #--> data jenis surat
        data_jenis_surat : str = random.choice(jenis_surat)
        jenis_surat_id   : str = data_jenis_surat.split('|')[0]
        jenis_surat_nama : str = data_jenis_surat.split('|')[1]

        #--> id_permohonan
        id_permohonan = f'PRMHN{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'

        #--> tanggal_pengajuan
        tanggal_pengajuan = fake.date_between(start_date='-1y', end_date='today').strftime('%Y-%m-%d')

        #--> status
        status = random.choice(['menunggu','diproses','selesai','ditolak'])

        #--> keterangan
        list_action = ['Pembuatan','Pengesahan','Perpanjangan','Penghapusan','Pemblokiran','Pendaftaran']
        keterangan = '{} {}'.format(random.choice(list_action), jenis_surat_nama)

        #--> warga_nik, staff_id_staff, jenis_surat_id_jenis
        warga_nik, staff_id_staff, jenis_surat_id_jenis = random.choice(list_warga_nik), random.choice(list_staff_id), jenis_surat_id

        #--> append
        all_data.append(f'{id_permohonan}|{tanggal_pengajuan}|{status}|{keterangan}|{warga_nik}|{staff_id_staff}|{jenis_surat_id_jenis}')

    return all_data

#--> dokumen_persyaratan
def generate_dokumen_persyaratan() -> list:
    all_data = []

    #--> read table lain
    permohonan_surat : list[str] = open(f'{folder}/permohonan_surat.txt','r').read().splitlines()

    #--> sortir
    permohonan_surat : list[str] = [i for i in permohonan_surat if i.split('|')[2].lower() != 'ditolak']

    all_id_numeric = generate_numeric_id(len(permohonan_surat))

    for i,permohonan in zip(all_id_numeric, permohonan_surat):

        #--> id_dokumen
        id_dokumen = f'DCMNT{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'

        #--> jenis_dokumen
        jenis_dokumen = random.choice(['KTP','Kartu Keluarga', 'Surat Tanah', 'Akta Kelahiran', 'SIM'])

        #--> url_file
        url_file = 'https://{}cdn.slemankab.go.id/data/requestee?id={}&act_key={}'.format(random.randint(10,20), str(uuid.uuid4()), str(uuid.uuid4()))

        #--> permohonan_surat_id_permohonan
        permohonan_surat_id_permohonan = permohonan.split('|')[0]

        #--> append
        all_data.append(f'{id_dokumen}|{jenis_dokumen}|{url_file}|{permohonan_surat_id_permohonan}')

    return all_data

#--> respon_permohonan
def generate_respon_permohonan() -> list:
    all_data = []

    #--> read table lain
    permohonan_surat : list[str] = open(f'{folder}/permohonan_surat.txt','r').read().splitlines()
    staff            : list[str] = open(f'{folder}/staff.txt','r').read().splitlines()

    #--> sortir
    permohonan_surat : list[str] = [i for i in permohonan_surat if i.split('|')[2].lower() != 'menunggu']
    list_staff_id    : list[str] = [i.split('|')[0] for i in staff]

    all_id_numeric = generate_numeric_id(len(permohonan_surat))

    for i,permohonan in zip(all_id_numeric, permohonan_surat):

        #--> id_respon
        id_respon = f'RSPNP{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'

        #--> tanggal_respon
        old_date = datetime.strptime(permohonan.split('|')[1], "%Y-%m-%d")
        new_date = old_date + timedelta(days=random.randint(1,14))
        tanggal_respon = new_date.strftime("%Y-%m-%d")

        #--> status
        status = permohonan.split('|')[2].lower()

        #--> catatan
        if status == 'selesai':
            catatan = '{} telah selesai'.format(permohonan.split('|')[3])
        elif status == 'diproses':
            catatan = '{} sedang diproses'.format(permohonan.split('|')[3])
        else:
            catatan = 'Anda tidak melampirkan dokumen yang valid'
        
        #--> permohonan_surat_id_permohonan
        permohonan_surat_id_permohonan = permohonan.split('|')[0]

        #--> staff_id_staff
        staff_id_staff = random.choice(list_staff_id)

        #--> append
        all_data.append(f'{id_respon}|{tanggal_respon}|{status}|{catatan}|{permohonan_surat_id_permohonan}|{staff_id_staff}')

    return all_data

#--> surat
def generate_surat() -> list:
    all_data = []

    #--> read table lain
    respon_permohonan : list[str] = open(f'{folder}/respon_permohonan.txt','r').read().splitlines()

    #--> sortir
    respon_permohonan : list[str] = [i for i in respon_permohonan if i.split('|')[2].lower() == 'selesai']

    all_id_numeric = generate_numeric_id(len(respon_permohonan))

    for i,permohonan in zip(all_id_numeric, respon_permohonan):

        #--> id_surat
        id_surat = f'SURAT{i}{"".join(random.choices(string.ascii_uppercase, k=5))}'

        #--> nomor_surat
        nomor_surat = str(uuid.uuid4())

        #--> tanggal_cetak
        old_date = datetime.strptime(permohonan.split('|')[1], "%Y-%m-%d")
        new_date = old_date + timedelta(days=random.randint(0,2))
        tanggal_cetak = new_date.strftime("%Y-%m-%d")

        #--> url_file
        url_file = 'https://{}cdn.slemankab.go.id/data/letter?id={}&act_key={}'.format(random.randint(10,20), str(uuid.uuid4()), str(uuid.uuid4()))
        
        #--> respon_permohonan_id_respon
        respon_permohonan_id_respon = permohonan.split('|')[0]

        #--> append
        all_data.append(f'{id_surat}|{nomor_surat}|{tanggal_cetak}|{url_file}|{respon_permohonan_id_respon}')

    return all_data

if __name__ == '__main__':
    table_name = ''
    generate_data(table_name)