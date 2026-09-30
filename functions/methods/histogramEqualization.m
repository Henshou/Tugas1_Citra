function imgOut = histogramEqualization(imgIn)
%HISTOGRAMEQUALIZATION Fungsi enhancement Histogram Equalization
%   Fungsi ini sebagai bentuk awal pemisahan antara gambar berwarna dan
%   tidak. Gambar berwarna akan dikonversi dulu ke color space YCbCr karena
%   kita ingin meng-equalize channel Y-nya dan masih memerlukan Cb dan Cr
%   untuk mengembalikan gambar kembali menjadi gambar berwarna (RGB)
    
    isColor = (ndims(imgIn) == 3);

    if isColor
        for c = 1:3
            imgOut(:,:,c) = equalize(imgIn(:,:,c))
        end
    else
        imgOut = equalize(imgIn);
    end
end


function outCh = equalize(channel)
%EQUALIZE Fungsi utama dari Histogram Equalization ini
    channel = uint8(channel);

    h = makeHist(channel);

    totalPixel = numel(channel);
    pdf = h / totalPixel;

    cdf = cumsum(pdf);

    tab = round(cdf * 255);
    tab = uint8(tab);

    outCh = tab(double(channel) + 1);
end