function imgOut = histogramMatching(imgIn, referenceImg)
%HISTOGRAMMATCHING Histogram Specification/Matching.
%   Menyesuaikan histogram imgIn agar mengikuti histogram referenceImg.
%   Untuk citra RGB, pencocokan dilakukan pada channel luminance Y (YCbCr).

    validateattributes(referenceImg, {'numeric', 'logical'}, ...
        {'nonempty'}, mfilename, 'referenceImg');

    isColor = (ndims(imgIn) == 3);

    if isColor
        ycbcr = rgb2ycbcr(uint8(imgIn));
        referenceY = getLuminance(referenceImg);
        ycbcr(:, :, 1) = matchChannel(ycbcr(:, :, 1), referenceY);
        imgOut = ycbcr2rgb(ycbcr);
    else
        imgOut = matchChannel(imgIn, referenceImg);
    end
end

function luminance = getLuminance(img)
%GETLUMINANCE Mengambil channel luminance Y dari citra secara konsisten.
    if ndims(img) == 3
        ycbcrRef = rgb2ycbcr(uint8(img));
        luminance = ycbcrRef(:, :, 1);
    else
        luminance = uint8(img);
    end
end

function out = matchChannel(channel, reference)
%MATCHCHANNEL Menyesuaikan histogram channel agar mengikuti histogram reference.
    channel = uint8(channel);
    reference = uint8(reference);

    sourceHist = makeHist(channel);
    referenceHist = makeHist(reference);
    sourceCdf = cumsum(sourceHist) / numel(channel);
    referenceCdf = cumsum(referenceHist) / numel(reference);

    mapping = zeros(1, 256, 'uint8');
    for sourceLevel = 1:256
        targetLevel = find(referenceCdf >= sourceCdf(sourceLevel), 1, 'first');
        if isempty(targetLevel)
            targetLevel = 256;
        end
        mapping(sourceLevel) = uint8(targetLevel - 1);
    end

    out = mapping(double(channel) + 1);
end