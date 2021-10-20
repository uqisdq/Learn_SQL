USE dqlab;
CREATE TABLE IF NOT EXISTS ms_pelanggan (
    `no_urut` INT,
    `kode_cabang` VARCHAR(13) CHARACTER SET utf8,
    `kode_pelanggan` VARCHAR(16) CHARACTER SET utf8,
    `nama_pelanggan` VARCHAR(21) CHARACTER SET utf8,
    `alamat` VARCHAR(45) CHARACTER SET utf8
);

CREATE TABLE IF NOT EXISTS ms_produk (
    `no_urut` INT,
    `kode_produk` VARCHAR(13) CHARACTER SET utf8,
    `nama_produk` VARCHAR(36) CHARACTER SET utf8,
    `harga` INT
);

CREATE TABLE IF NOT EXISTS tr_penjualan (
    `kode_transaksi` VARCHAR(16) CHARACTER SET utf8,
    `tanggal_transaksi` DATETIME,
    `kode_cabang` VARCHAR(13) CHARACTER SET utf8,
    `kode_pelanggan` VARCHAR(16) CHARACTER SET utf8,
    `no_urut` INT,
    `kode_prod` VARCHAR(11) CHARACTER SET utf8,
    `qty` INT,
    `harga` INT
);

CREATE TABLE IF NOT EXISTS tr_penjualan_detail (
    `kode_transaksi` VARCHAR(16) CHARACTER SET utf8,
    `kode_produk` VARCHAR(13) CHARACTER SET utf8,
    `qty` INT,
    `harga_satuan` INT
);

-- Query Produk Database DQLab
SELECT
    no_urut,
    kode_produk,
    nama_produk,
    harga
FROM
    ms_produk
order by
	kode_produk;

-- Query yang namanya ada elemen -Flashdisk-
SELECT
    no_urut,
    kode_produk,
    nama_produk,
    harga
FROM
    ms_produk
WHERE
    nama_produk LIKE '%Flashdisk%';

-- Query Pelanggan Bergelar
SELECT
    no_urut,
    kode_pelanggan,
    nama_pelanggan,
    alamat
FROM
    ms_pelanggan
WHERE
    nama_pelanggan LIKE '%S.H%'
    OR nama_pelanggan LIKE '%Ir.%'
    OR nama_pelanggan LIKE '%Drs.%';

-- Mengurutkan Nama Pelanggan
SELECT
    nama_pelanggan
FROM
    ms_pelanggan
ORDER BY
    nama_pelanggan;

-- Mengurutkan Nama Pelanggan Tanpa Gelar
SELECT
    nama_pelanggan
FROM
    ms_pelanggan
ORDER BY
    SUBSTRING_INDEX(nama_pelanggan, ", ", -1);

-- Nama Pelanggan yang Paling Panjang
SELECT
    nama_pelanggan
FROM
    ms_pelanggan
WHERE
    LENGTH(nama_pelanggan) = (
        SELECT
            MAX(LENGTH(nama_pelanggan))
        FROM
            ms_pelanggan
    );

-- Nama Pelanggan yang Paling Panjang dengan Gelar
SELECT
    nama_pelanggan
FROM
    ms_pelanggan
WHERE
    LENGTH(nama_pelanggan) IN (
        (
            SELECT
                MAX(LENGTH(nama_pelanggan))
            FROM
                ms_pelanggan
        ),
        (
            SELECT
                MIN(LENGTH(nama_pelanggan))
            FROM
                ms_pelanggan
        )
    )
ORDER BY
    LENGTH(nama_pelanggan) DESC;

-- Kuantitas Produk yang Banyak Terjual
SELECT
    ms_produk.kode_produk,
    ms_produk.nama_produk,
    SUM(tr_penjualan_detail.qty) AS total_qty
FROM
    ms_produk
    INNER JOIN tr_penjualan_detail ON ms_produk.kode_produk = tr_penjualan_detail.kode_produk
GROUP BY
    ms_produk.kode_produk,
    ms_produk.nama_produk
HAVING
    SUM(tr_penjualan_detail.qty) > 2;

-- Pelanggan Paling Tinggi Nilai Belanjanya
SELECT
    tr_penjualan.kode_pelanggan,
    ms_pelanggan.nama_pelanggan,
    SUM(
        tr_penjualan_detail.qty * tr_penjualan_detail.harga_satuan
    ) AS total_harga
FROM
    ms_pelanggan
    INNER JOIN tr_penjualan USING (kode_pelanggan)
    INNER JOIN tr_penjualan_detail USING (kode_transaksi)
GROUP BY
    tr_penjualan.kode_pelanggan,
    ms_pelanggan.nama_pelanggan
ORDER BY
    total_harga DESC
LIMIT
    1;

-- Pelanggan yang Belum Pernah Berbelanja
SELECT
    kode_pelanggan,
    nama_pelanggan,
    alamat
FROM
    ms_pelanggan
WHERE
    kode_pelanggan NOT IN (
        SELECT
            kode_pelanggan
        FROM
            tr_penjualan
    );

-- Transaksi Belanja dengan Daftar Belanja lebih dari 1
SELECT
    tr.kode_transaksi,
    tr.kode_pelanggan,
    ms.nama_pelanggan,
    tr.tanggal_transaksi,
    COUNT(td.qty) AS jumlah_detail
FROM
    tr_penjualan tr
    INNER JOIN ms_pelanggan ms ON tr.kode_pelanggan = ms.kode_pelanggan
    INNER JOIN tr_penjualan_detail td ON tr.kode_transaksi = td.kode_transaksi
GROUP BY
    tr.kode_transaksi,
    tr.kode_pelanggan,
    ms.nama_pelanggan,
    tr.tanggal_transaksi
HAVING
    jumlah_detail > 1;
    
