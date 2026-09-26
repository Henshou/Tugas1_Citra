classdef Service < handle
    % SERVICE Menangani logika bisnis & pemrosesan citra (Model)

    methods
        function imgOutput = process(obj, methodIndex, typeValue, paramStr, imgInput, imgRef)
            switch methodIndex
                case 1
                    typeName = lower(typeValue);
                    param = obj.parseIntensityParameter(typeName, paramStr);
                    imgOutput = intensityTransformation(imgInput, typeName, param);
                case 2
                    imgOutput = histogramEqualization(imgInput);
                case 3
                    if isempty(imgRef)
                        error('Pilih citra referensi untuk histogram matching.');
                    end
                    imgOutput = histogramMatching(imgInput, imgRef);
                case 4
                    kernel = obj.parseKernel(typeValue, paramStr);
                    imgOutput = convFilt(imgInput, kernel);
                otherwise
                    error('Metode tidak dikenali.');
            end
        end

        function lines = formatFeatures(~, img)
            analysis = imageAnalysis(img);
            f = analysis.fitur;
            lines = { ...
                sprintf('Min: %.1f', f.minVal); ...
                sprintf('Max: %.1f', f.maxVal); ...
                sprintf('Mean: %.2f', f.meanVal); ...
                sprintf('Std: %.2f', f.stdVal); ...
                sprintf('Entropy: %.2f', f.entropi) ...
            };
        end
    end

    methods (Access = private)
        function parameter = parseIntensityParameter(~, typeName, paramStr)
        %PARSEINTENSITYPARAMETER Mengubah string parameter menjadi nilai numerik sesuai tipe transformasi.
            if strcmp(typeName, 'gamma')
                parameter = str2double(paramStr);
                if isnan(parameter) || parameter <= 0
                    error('Parameter gamma harus berupa angka positif.');
                end
            elseif strcmp(typeName, 'contrast')
                parameter = str2num(paramStr); %#ok<ST2NM>
                if numel(parameter) ~= 2 || any(~isfinite(parameter)) || parameter(1) >= parameter(2)
                    error('Contrast harus berupa [low high], dengan low < high.');
                end
            else
                parameter = [];
            end
        end

        function kernel = parseKernel(~, typeName, paramStr)
        %PARSEKERNEL Mengubah string parameter menjadi kernel matriks 3x3 sesuai tipe filter.
            if strcmp(typeName, 'Mean 3x3')
                kernel = ones(3, 3) / 9;
            elseif strcmp(typeName, 'Gaussian 3x3')
                kernel = [1 2 1; 2 4 2; 1 2 1] / 16;
            elseif strcmp(typeName, 'Sharpen 3x3')
                kernel = [0 -1 0; -1 5 -1; 0 -1 0];
            elseif strcmp(typeName, 'Edge 3x3')
                kernel = [-1 -1 -1; -1 8 -1; -1 -1 -1];
            else
                kernel = str2num(paramStr); %#ok<ST2NM>
            end
            if isempty(kernel) || ndims(kernel) ~= 2 || any(size(kernel) ~= [3 3]) || any(~isfinite(kernel(:)))
                error('Kernel harus berupa matriks 3x3 yang valid.');
            end
        end
    end
end