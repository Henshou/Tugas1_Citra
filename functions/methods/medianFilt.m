function imgOut = medianFilt(imgIn, windowSize)
% MEDIANFILT  Non-linear filtering menggunakan median filter

    if ndims(imgIn) == 3
        imgOut = zeros(size(imgIn), 'uint8');
        for c = 1:3
            imgOut(:, :, c) = medianFilter(imgIn(:, :, c), windowSize);
        end
    else
        imgOut = medianFilter(imgIn, windowSize);
    end
end


function out = medianFilter(channel, windowSize)
% Fungsi inti median filter untuk satu channel grayscale.
    
    channel = double(channel);
    pad = floor(windowSize / 2);
    
    channelPad = padarray(channel, [pad, pad], 'replicate');
    
    [baris, kolom] = size(channel);
    out = zeros(baris, kolom);
    
    for i = 1:baris
        for j = 1:kolom
            region = channelPad(i:i+windowSize-1, j:j+windowSize-1);
            out(i, j) = median(region(:));
        end
    end
    
    out = uint8(out);
end