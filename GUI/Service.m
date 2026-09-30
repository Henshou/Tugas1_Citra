classdef Service < handle
    % SERVICE Menangani logika bisnis & pemrosesan citra (Model)

    methods
        function [imgOutput, intermediateImages] = processPipeline(obj, imgInput, pipeline)
            imgCurrent = imgInput;
            numSteps = length(pipeline);
            intermediateImages = cell(1, numSteps);

            for i = 1:numSteps
                step = pipeline(i);
                imgCurrent = obj.processStep(step, imgCurrent);
                intermediateImages{i} = imgCurrent;
            end

            imgOutput = imgCurrent;
        end

        function imgOutput = processStep(obj, step, imgInput)
            methodIndex = step.MethodIndex;
            typeValue   = step.TypeValue;
            paramStr    = step.ParamStr;
            imgRef      = step.ImgRef;

            switch methodIndex
                case 1
                    typeName = lower(typeValue);
                    param = obj.parseIntensityParameter(typeName, paramStr);
                    imgOutput = intensityTransformation(imgInput, typeName, param);
                case 2
                    imgOutput = histogramEqualization(imgInput);
                case 3
                    if isempty(imgRef)
                        error('Step Histogram Matching membutuhkan citra referensi.');
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
            if isempty(img), lines = {''}; return; end
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
            if strcmp(typeName, 'gamma')
                parameter = str2double(paramStr);
                if isnan(parameter) || parameter <= 0
                    error('Parameter gamma harus berupa angka positif.');
                end
            elseif strcmp(typeName, 'contrast')
                parameter = str2num(paramStr);
                if numel(parameter) ~= 2 || any(~isfinite(parameter)) || parameter(1) >= parameter(2)
                    error('Contrast harus berupa [low high], dengan low < high.');
                end
            else
                parameter = [];
            end
        end

        function kernel = parseKernel(~, typeName, paramStr)
            if strcmp(typeName, 'Gaussian')
                kernel = [1 2 1; 2 4 2; 1 2 1] / 16;
            elseif strcmp(typeName, 'Sharpen')
                kernel = [0 -1 0; -1 5 -1; 0 -1 0];
            else
                kernel = str2num(paramStr);
            end

            if isempty(kernel) || ~ismatrix(kernel) || any(~isfinite(kernel(:)))
                error('Kernel harus berupa matriks yang valid.');
            end
            [kh, kw] = size(kernel);
            if kh ~= kw || mod(kh, 2) == 0
                error('Kernel harus berupa matriks persegi berukuran ganjil (mis. 3x3, 5x5, 7x7).');
            end
        end

        function windowSize = parseWindowSize(~, paramStr)
            windowSize = round(str2double(paramStr));
            if isnan(windowSize) || windowSize < 3 || mod(windowSize, 2) == 0
                error('Ukuran window harus bilangan ganjil dan minimal 3 (mis. 3, 5, 7).');
            end
        end
    end
end