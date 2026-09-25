function fitur = makeFeature(img)
%MAKEFEATURE Fitur-fitur analisis dari gambar
%   Fitur berupa min, max, mean, std, dan entropy

    img = double(img);
    h = makeHist(uint8(img));
    totalPixel = numel(img);

    fitur.minVal = min(img(:));
    fitur.maxVal = max(img(:));
    fitur.meanVal = mean(img(:));
    fitur.stdVal = std(img(:));

    %entropi
    p = h / totalPixel;
    p = p(p > 0);
    fitur.entropi = -sum(p .* log2(p));
end