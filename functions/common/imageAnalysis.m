function hasil = imageAnalysis(img)
% ANALISISCITRA  Menganalisis citra: deteksi berwarna/grayscale, hitung

hasil.isColor = (ndims(img) == 3);

if hasil.isColor
    R = img(:, :, 1);
    G = img(:, :, 2);
    B = img(:, :, 3);

    hasil.hist.R = makeHist(R);
    hasil.hist.G = makeHist(G);
    hasil.hist.B = makeHist(B);

    hasil.imgGray = rgb2gray(img);
else
    hasil.hist    = makeHist(img);
    hasil.imgGray = img;
end

hasil.fitur = makeFeature(hasil.imgGray);
end