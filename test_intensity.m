% Pengujian Intensity Transformation.
% Ganti subfolder atau nama file untuk menguji citra lain.

clear; clc; close all;

rootFolder = fileparts(mfilename('fullpath'));
addpath(fullfile(rootFolder, 'functions', 'common'));
addpath(fullfile(rootFolder, 'functions', 'methods'));

%% 1. Baca citra input
subfolderDataset = '2. Kasus 1';
namaFile = 'image_01.png';
pathCitra = fullfile(rootFolder, 'dataset', subfolderDataset, namaFile);
imgAsli = imread(pathCitra);

%% 2. Terapkan beberapa transformasi intensitas
imgNegative = intensityTransformation(imgAsli, 'negative');
imgLog = intensityTransformation(imgAsli, 'log');
imgGamma = intensityTransformation(imgAsli, 'gamma', 0.5);
imgContrast = intensityTransformation(imgAsli, 'contrast', [0.2 0.8]);

%% 3. Tampilkan hasil transformasi
figure('Name', 'Intensity Transformation');
subplot(2, 3, 1);
imshow(imgAsli);
title(['Asli: ' namaFile], 'Interpreter', 'none');

subplot(2, 3, 2);
imshow(imgNegative);
title('Negative');

subplot(2, 3, 3);
imshow(imgLog);
title('Log');

subplot(2, 3, 4);
imshow(imgGamma);
title('Gamma (0.5)');

subplot(2, 3, 5);
imshow(imgContrast);
title('Contrast [0.2 0.8]');

%% 4. Tampilkan histogram hasil transformasi
showHist(imageAnalysis(imgAsli), 'Histogram Asli');
showHist(imageAnalysis(imgNegative), 'Histogram Negative');
showHist(imageAnalysis(imgLog), 'Histogram Log');
showHist(imageAnalysis(imgGamma), 'Histogram Gamma');
showHist(imageAnalysis(imgContrast), 'Histogram Contrast');
