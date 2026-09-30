function imgOut = intensityTransformation(imgIn, transformType, parameter)
%INTENSITYTRANSFORMATION Transformasi intensitas titik pada citra.

    if nargin < 2 || isempty(transformType)
        transformType = 'negative';
    end

    if nargin < 3
        parameter = [];
    end

    isColor = (ndims(imgIn) == 3);

    if isColor
        for c = 1:3
            imgOut(:, :, c) = transformChannel(imgIn(:, :, c), transformType, parameter);
        end
    else
        imgOut = transformChannel(imgIn, transformType, parameter);
    end
end

function out = transformChannel(channel, transformType, parameter)
%TRANSFORMCHANNEL Menerapkan transformasi intensitas pada channel citra.
    values = double(uint8(channel)) / 255;
    transformType = lower(char(transformType));

    switch transformType
        case 'negative'
            values = 1 - values;
        case 'log'
            values = log(1 + values) / log(2);
        case 'gamma'
            if isempty(parameter)
                parameter = 1;
            end
            validateattributes(parameter, {'numeric'}, ...
                {'scalar', 'positive'}, mfilename, 'parameter');
            values = values .^ parameter;
        case 'contrast'
            if isempty(parameter)
                parameter = [min(values(:)), max(values(:))];
            end
            validateattributes(parameter, {'numeric'}, ...
                {'numel', 2, 'finite', 'nondecreasing'}, ...
                mfilename, 'parameter');
            low = parameter(1);
            high = parameter(2);
            if high == low
                values = double(values >= low);
            else
                values = (values - low) / (high - low);
            end
        otherwise
            error('intensityTransformation:InvalidType', ...
                'Transformasi harus negative, log, gamma, atau contrast.');
    end

    out = uint8(round(max(0, min(1, values)) * 255));
end