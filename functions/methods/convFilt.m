function imgOut = convFilt(imgIn, kernel)
%CONVFILT Filtering berbasis konvolusi
%  Fungsi ini dipakai sebagai pemrosesan awal jika gambar
%  merupakan gambar RGB atau bukan

    isRGB = (ndims(imgIn) == 3);

    if isRGB
        imgOut = zeros(size(imgIn), 'uint8');
        for c = 1:3
            imgOut(:, :, c) = convFunc(imgIn(:, :, c), kernel);
        end
    else 
        imgOut = convFunc(imgIn, kernel);
    end
end

function out = convFunc(channel, kernel)
%CONVFUNC Fungsi konvolusi yang dipakai pada channel gambar
% dengan kernel yang diberikan
    channel = double(channel);
    [kh, kw] = size(kernel);

    padH = floor(kh/2);
    padW = floor(kw/2);

    padding = padarray(channel, [padH, padW], "replicate");

    [row, column] = size(channel);
    out = zeros(row, column);

    for i = 1:row
        for j = 1:column
            reg = padding(i:i+kh-1, j:j+kw-1);
            out(i,j) = sum(sum(reg .* kernel));
        end
    end

    out = uint8(max(0,min(255, out)));
end