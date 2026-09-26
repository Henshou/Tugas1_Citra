% Pengujian Histogram Specification/Matching.
% Ganti nama file atau subfolder jika ingin memakai pasangan citra lain.

clear; clc; close all;

rootFolder = fileparts(mfilename('fullpath'));
addpath(fullfile(rootFolder, 'functions', 'common'));
addpath(fullfile(rootFolder, 'functions', 'methods'));

%% 1. Baca citra input dan citra referensi
subfolderDataset = '2. Kasus 1';
namaFileInput    = 'image_01.png';
namaFileReferensi = 'image_02.png';

pathInput = fullfile(rootFolder, 'dataset', subfolderDataset, namaFileInput);
pathReferensi = fullfile(rootFolder, 'dataset', subfolderDataset, namaFileReferensi);

imgInput = imread(pathInput);
imgReferensi = imread(pathReferensi);

%% 2. Terapkan histogram matching
imgHmatch = histogramMatching(imgInput, imgReferensi);

%% 3. Tampilkan citra sebelum dan sesudah
figure('Name', 'Histogram Matching');
subplot(1, 3, 1);
imshow(imgInput);
title(['Input: ' namaFileInput], 'Interpreter', 'none');

subplot(1, 3, 2);
imshow(imgReferensi);
title(['Referensi: ' namaFileReferensi], 'Interpreter', 'none');

subplot(1, 3, 3);
imshow(imgHmatch);
title('Hasil Matching');

%% 4. Bandingkan histogram
analisisInput = imageAnalysis(imgInput);
analisisReferensi = imageAnalysis(imgReferensi);
analisisHmatch = imageAnalysis(imgHmatch);

showHist(analisisInput, 'Histogram Input');
showHist(analisisReferensi, 'Histogram Referensi');
showHist(analisisHmatch, 'Histogram Hasil Matching');

%% 5. Tampilkan fitur citra
fprintf('--- Fitur Citra Input ---\n');
disp(featureToText(analisisInput));

fprintf('--- Fitur Citra Referensi ---\n');
disp(featureToText(analisisReferensi));

fprintf('--- Fitur Hasil Matching ---\n');
disp(featureToText(analisisHmatch));
