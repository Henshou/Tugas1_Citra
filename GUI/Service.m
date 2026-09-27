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
                    if strcmp(typeValue, 'Median')
                        windowSize = obj.parseWindowSize(paramStr);
                        imgOutput = medianFilt(imgInput, windowSize);
                    else
                        kernel = obj.parseKernel(typeValue, paramStr);
                        imgOutput = convFilt(imgInput, kernel);
                    end
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
            %PARSEKERNEL Mengubah string parameter menjadi kernel matriks 3x3
            disp(['typeName yang diterima: "' typeName '"']);
            if strcmp(typeName, 'Gaussian 3x3')
                kernel = [1 2 1; 2 4 2; 1 2 1] / 16;
            elseif strcmp(typeName, 'Sharpen 3x3')
                kernel = [0 -1 0; -1 5 -1; 0 -1 0];
            else
                kernel = str2num(paramStr);
            end

            if isempty(kernel) || ~ismatrix(kernel) || any(size(kernel) ~= [3 3]) || any(~isfinite(kernel(:)))
                error('Kernel harus berupa matriks 3x3 yang valid.');
            end
        end

        function windowSize = parseWindowSize(~, paramStr)
            %PARSEWINDOWSIZE Mengubah string parameter menjadi ukuran window
            windowSize = round(str2double(paramStr));
            if isnan(windowSize) || windowSize < 3 || mod(windowSize, 2) == 0
                error('Ukuran window harus bilangan ganjil dan minimal 3 (mis. 3, 5, 7).');
            end
        end
    end
end