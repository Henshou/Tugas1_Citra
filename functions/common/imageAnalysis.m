function hasil = imageAnalysis(img)
% ANALISISCITRA  Menganalisis citra: deteksi berwarna/grayscale, hitung

hasil.isColor = false;

if ndims(img) == 3
    if size(img, 3) >= 3
        img = img(:, :, 1:3);
        R = img(:, :, 1);
        G = img(:, :, 2);
        B = img(:, :, 3);
        tol = 1;
        isGrayRGB = max(abs(double(R(:)) - double(G(:)))) <= tol && ...
                    max(abs(double(G(:)) - double(B(:)))) <= tol;
        hasil.isColor = ~isGrayRGB;
    else
        img = img(:, :, 1);
    end
end

if hasil.isColor
    hasil.hist.R = makeHist(R);
    hasil.hist.G = makeHist(G);
    hasil.hist.B = makeHist(B);

    hasil.imgGray = rgb2gray(img);
else
    if ndims(img) == 3
        img = img(:, :, 1);
    end
    hasil.hist    = makeHist(img);
    hasil.imgGray = img;
end

hasil.fitur = makeFeature(hasil.imgGray);
end