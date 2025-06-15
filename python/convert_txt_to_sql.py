import os

path = 'sql/insert'

header_dict = {
    'jenis_surat': 'INSERT INTO jenis_surat (id_jenis, nama_surat) VALUES\n',
    'keluarga': 'INSERT INTO keluarga (no_kk, alamat, rt, rw) VALUES\n',
    'pekerjaan': 'INSERT INTO pekerjaan (id_pekerjaan, nama, gaji_per_bulan) VALUES\n',
    'pendidikan': 'INSERT INTO pendidikan (id_pendidikan, nama) VALUES\n',
    'warga': 'INSERT INTO warga (nik, nama, jenis_kelamin, agama, tempat_lahir, tanggal_lahir, alamat, status_keluarga, status_perkawinan, keluarga_no_kk, pekerjaan_id_pekerjaan, pendidikan_id_pendidikan) VALUES\n',
    'staff': 'INSERT INTO staff (id_staff, jabatan, username, password, warga_nik) VALUES\n',
    'pengaduan': 'INSERT INTO pengaduan (id_pengaduan, tanggal_pengaduan, kategori, isi_pengaduan, status, warga_nik) VALUES\n',
    'tanggapan_pengaduan': 'INSERT INTO tanggapan_pengaduan (id_tanggapan, tanggal_tanggapan, isi_tanggapan, pengaduan_id_pengaduan, staff_id_staff) VALUES\n',
    'permohonan_surat': 'INSERT INTO permohonan_surat (id_permohonan, tanggal_pengajuan, status, keterangan, warga_nik, staff_id_staff, jenis_surat_id_jenis) VALUES\n',
    'dokumen_persyaratan': 'INSERT INTO dokumen_persyaratan (id_dokumen, jenis_dokumen, url_file, permohonan_surat_id_permohonan) VALUES\n',
    'respon_permohonan': 'INSERT INTO respon_permohonan (id_respon, tanggal_respon, status, catatan, permohonan_surat_id_permohonan, staff_id_staff) VALUES\n',
    'surat': 'INSERT INTO surat (id_surat, nomor_surat, tanggal_cetak, url_file, respon_permohonan_id_respon) VALUES\n',
}

def read_data_txt(table_name:str) -> list:
    list_data = open(f'txt/{table_name}.txt','r').read().splitlines()
    return(list_data)

def control_function(table_name:str, list_data:list) -> None:
    os.makedirs(path, exist_ok=True)
    convert(table_name, list_data)

def convert(table_name:str, list_data:list) -> None:
    filename = f'{path}/insert_{table_name}.sql'
    open(filename, 'w').write(header_dict[table_name])
    open_file = open(filename, 'a+')
    for item in list_data:
        format_baris = "('%s'),"%(str(item.replace('|',"', '")))
        open_file.write("%s\n"%(format_baris))

if __name__ == '__main__':
    table_name : str  = ''
    list_data  : list = read_data_txt(table_name)
    control_function(table_name, list_data)