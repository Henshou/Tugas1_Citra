clear; clc; close all;

scriptFolder = fileparts(mfilename('fullpath'));  
rootFolder   = fileparts(scriptFolder);   
addpath(fullfile(rootFolder, 'functions', 'common'));
addpath(fullfile(rootFolder, 'functions', 'methods'));


%% 1. Baca citra masukan
subfolderDataset = '5. Kasus 4';   % ganti sesuai subfolder yang sedang dikerjakan
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

%% 3a. Linear Filtering - Gaussian (smoothing)
kernelGaussian = [1 2 1; 2 4 2; 1 2 1] / 16;
imgGaussian = convFilt(imgAsli, kernelGaussian);

figure('Name', 'Hasil Gaussian Filter (Linear)');
subplot(1,2,1); imshow(imgAsli);      title('Sebelum');
subplot(1,2,2); imshow(imgGaussian);  title('Sesudah Gaussian 3x3');

analisisGaussian = imageAnalysis(imgGaussian);
showHist(analisisGaussian, 'Histogram Hasil Gaussian');
fprintf('\n--- Fitur Setelah Gaussian ---\n%s\n', featureToText(analisisGaussian));


%% 3b. Linear Filtering - Sharpen (penajaman)
kernelSharpen = [0 -1 0; -1 5 -1; 0 -1 0];
imgSharpen = convFilt(imgAsli, kernelSharpen);

figure('Name', 'Hasil Sharpen Filter (Linear)');
subplot(1,2,1); imshow(imgAsli);     title('Sebelum');
subplot(1,2,2); imshow(imgSharpen);  title('Sesudah Sharpen 3x3');

analisisSharpen = imageAnalysis(imgSharpen);
showHist(analisisSharpen, 'Histogram Hasil Sharpen');
fprintf('\n--- Fitur Setelah Sharpen ---\n%s\n', featureToText(analisisSharpen));


%% 4. Non-linear Filtering - Median
windowSize = 3;   % ganti ukuran window (harus ganjil: 3, 5, 7)
imgMedian = medianFilt(imgAsli, windowSize);

figure('Name', 'Hasil Median Filter (Non-linear)');
subplot(1,2,1); imshow(imgAsli);     title('Sebelum');
subplot(1,2,2); imshow(imgMedian);   title(sprintf('Sesudah Median %dx%d', windowSize, windowSize));

analisisMedian = imageAnalysis(imgMedian);
showHist(analisisMedian, 'Histogram Hasil Median');
fprintf('\n--- Fitur Setelah Median ---\n%s\n', featureToText(analisisMedian));


%% 5. Ringkasan perbandingan seluruh metode
fprintf('\n=== RINGKASAN PERBANDINGAN FITUR ===\n');
fprintf('Asli     : %s\n', featureToText(analisisAwal));
fprintf('Gaussian : %s\n', featureToText(analisisGaussian));
fprintf('Sharpen  : %s\n', featureToText(analisisSharpen));
fprintf('Median   : %s\n', featureToText(analisisMedian));

imgGray = analisisAwal.imgGray;

% Validasi Gaussian (konvolusi)
imgGaussian_bawaan = imfilter(imgGray, kernelGaussian, 'replicate');
figure('Name', 'Validasi: Gaussian Sendiri vs imfilter() Bawaan');
subplot(1,3,1); imshow(imgGray);                              title('Asli (Grayscale)');
subplot(1,3,2); imshow(convFilt(imgGray, kernelGaussian));     title('Gaussian Sendiri');
subplot(1,3,3); imshow(imgGaussian_bawaan);                    title('imfilter() Bawaan (Pembanding)');

% Validasi Median
imgMedian_bawaan = medfilt2(imgGray, [windowSize windowSize]);
figure('Name', 'Validasi: Median Sendiri vs medfilt2() Bawaan');
subplot(1,3,1); imshow(imgGray);                              title('Asli (Grayscale)');
subplot(1,3,2); imshow(medianFilt(imgGray, windowSize));       title('Median Sendiri');
subplot(1,3,3); imshow(imgMedian_bawaan);                      title('medfilt2() Bawaan (Pembanding)');


