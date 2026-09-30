clear; clc; close all;

scriptFolder = fileparts(mfilename('fullpath')); 
rootFolder   = fileparts(scriptFolder);   
addpath(fullfile(rootFolder, 'functions', 'common'));
addpath(fullfile(rootFolder, 'functions', 'methods'));


%% 1. Baca citra masukan

subfolderDataset = '4. Kasus 3';   % ganti sesuai subfolder yang sedang dikerjakan
namaFile         = 'image_01.png';   % ganti dengan nama file citra uji

pathCitra = fullfile(rootFolder, 'dataset', subfolderDataset, namaFile);
imgAsli   = imread(pathCitra);

figure('Name', 'Citra Masukan');
imshow(imgAsli);
title(['Citra Masukan: ' namaFile], 'Interpreter', 'none');


%% 2. Analisis citra masukan: histogram + fitur

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

