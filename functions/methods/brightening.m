function imgOut = brightening(imgIn, alpha, bias)
%BRIGHTENING Fungsi untuk mencerah/gelapkan citra dengan faktor param
    isRGB = (ndims(imgIn) == 3);

    if isRGB
        imgOut = zeros(size(imgIn), 'uint8');
        for c = 1:3
            imgOut(:, :, c) = brightenChannel(imgIn(:, :, c), alpha, bias);
        end
    else 
        imgOut = brightenChannel(imgIn, alpha, bias);
    end
end

function out = brightenChannel(channel, alpha, bias)
%BRIGHTENCHANNEL Mencerahkan / gelapkan channel citra
% channel + param, pastikan hasilnya tetap dalam rentang [0, 255]
    values = double(uint8(channel));
    values = values * alpha + bias;
    out = uint8(round(max(0, min(255, values))));
end
