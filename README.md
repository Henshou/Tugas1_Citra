# Image Enhancement App

Aplikasi MATLAB berbasis GUI untuk melakukan perbaikan kualitas citra (image enhancement). Aplikasi menyediakan beberapa teknik enhancement yang dapat dipilih berdasarkan karakteristik citra, serta menampilkan histogram dan perbandingan citra sebelum dan sesudah enhancement.

Teknik yang Diimplementasikan

Aplikasi mencakup empat kelompok teknik image enhancement:

1. Intensity Transformation
2. Histogram Equalization
3. Histogram Specification/Matching
4. Image Filtering with Masking
    - Linear filtering berbasis konvolusi
    - Non-linear filtering, yaitu median filtering

Teknik enhancement dapat digunakan secara tunggal maupun dikombinasikan sesuai karakteristik citra.

Untuk citra berwarna, histogram ditampilkan secara terpisah untuk kanal R, G, dan B.

Dependensi
- MATLAB
- Image Processing Toolbox

Cara Menjalankan
1. Buka project/folder aplikasi di MATLAB.
2. Pastikan seluruh file dan folder aplikasi berada pada struktur direktori yang sesuai.
3. Jalankan file main.m yang berada di root folder project.

Atau dapat dijalankan melalui Command Window MATLAB dengan:

```matlab
main
```
