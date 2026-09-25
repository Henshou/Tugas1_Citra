% Cara pakai: ganti 'namafile.jpg' di bawah dengan path citra uji dari
% dataset(folder Kasus 1/2/3/4).

clear; clc; close all;

% Path fungsi dihitung dari lokasi script ini sendiri, supaya tidak
% bergantung pada current folder saat dijalankan
rootFolder = fileparts(mfilename('fullpath'));
addpath(fullfile(rootFolder, 'functions', 'common'));
addpath(fullfile(rootFolder, 'functions', 'methods'));


%% 1. Baca citra masukan
% Dataset ada di root/dataset, dengan subfolder bernama seperti
% "1. Histogram Citra", "2. Kasus 1", dst. Pakai fullfile() supaya aman
% terhadap spasi/titik di nama folder dan tetap portable di OS mana pun.

subfolderDataset = '2. Kasus 1';   % ganti sesuai subfolder yang sedang dikerjakan
namaFile         = 'image_01.png';   % ganti dengan nama file citra uji

pathCitra = fullfile(rootFolder, 'dataset', subfolderDataset, namaFile);
imgAsli   = imread(pathCitra);

figure('Name', 'Citra Masukan');
imshow(imgAsli);
title(['Citra Masukan: ' namaFile], 'Interpreter', 'none');


%% 2. Analisis citra masukan: histogram + fitur
% analisisCitra() otomatis deteksi berwarna/grayscale, hitung histogram
% (per kanal R,G,B jika berwarna, sesuai wajib spesifikasi) + fitur
% tambahan (mean, std, min, max, entropy dari versi grayscale).

analisisAwal = imageAnalysis(imgAsli);
showHist(analisisAwal, 'Histogram Citra Masukan');

disp('--- Fitur Citra Masukan ---');
disp(featureToText(analisisAwal));

%% 3. Terapkan Enhancement
imgEq = histogramEqualization(imgAsli);

figure('Name', 'Hasil Enhancement');
subplot(1,2,1); imshow(imgAsli); title('Sebelum');
subplot(1,2,2); imshow(imgEq);   title('Sesudah Enhancement');


%% 4. Analisis citra hasil: histogram + fitur (bandingkan dengan sebelum)
analisisEq = imageAnalysis(imgEq);
showHist(analisisEq, 'Histogram Hasil Enhancement');

disp('--- Fitur Citra Setelah Enhancement ---');
disp(featureToText(analisisEq));

fprintf('\n--- Perbandingan ---\n');
fprintf('Sebelum : %s\n', featureToText(analisisAwal));
fprintf('Sesudah : %s\n', featureToText(analisisEq));


imgEq_bawaan = histeq(analisisAwal.imgGray);

figure('Name', 'Validasi: Equalization Sendiri vs histeq() Bawaan');
subplot(1,3,1); imshow(analisisAwal.imgGray); title('Asli (Grayscale)');
subplot(1,3,2); imshow(analisisEq.imgGray);   title('Equalization Sendiri');
subplot(1,3,3); imshow(imgEq_bawaan);         title('histeq() Bawaan (Pembanding)');

