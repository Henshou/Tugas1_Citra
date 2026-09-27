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
                    kernel = obj.parseKernel(typeValue, paramStr);
                    imgOutput = convFilt(imgInput, kernel);
                otherwise
                    error('Metode tidak dikenali.');
            end
        end

        function plotHistogramToAxes(~, img, targetAxes, titleStr)
            cla(targetAxes);
            if isempty(img)
                title(targetAxes, '');
                return;
            end

            analysis = imageAnalysis(img);
            if analysis.isColor
                hold(targetAxes, 'on');
                stem(targetAxes, 0:255, analysis.hist.R, 'r', 'Marker', 'none');
                stem(targetAxes, 0:255, analysis.hist.G, 'g', 'Marker', 'none');
                stem(targetAxes, 0:255, analysis.hist.B, 'b', 'Marker', 'none');
                hold(targetAxes, 'off');
            else
                bar(targetAxes, 0:255, analysis.hist, 'k', 'EdgeColor', 'none');
            end
            
            xlim(targetAxes, [0 255]);
            grid(targetAxes, 'on');
            targetAxes.XColor = [0.8 0.8 0.8];
            targetAxes.YColor = [0.8 0.8 0.8];
            targetAxes.FontSize = 8;
            title(targetAxes, titleStr, 'Color', [0.9 0.9 0.9], 'FontSize', 9);
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
            if strcmp(typeName, 'Mean 3x3')
                kernel = ones(3, 3) / 9;
            elseif strcmp(typeName, 'Gaussian 3x3')
                kernel = [1 2 1; 2 4 2; 1 2 1] / 16;
            elseif strcmp(typeName, 'Sharpen 3x3')
                kernel = [0 -1 0; -1 5 -1; 0 -1 0];
            elseif strcmp(typeName, 'Edge 3x3')
                kernel = [-1 -1 -1; -1 8 -1; -1 -1 -1];
            else
                kernel = str2num(paramStr);
            end
            if isempty(kernel) || ndims(kernel) ~= 2 || any(size(kernel) ~= [3 3]) || any(~isfinite(kernel(:)))
                error('Kernel harus berupa matriks 3x3 yang valid.');
            end
        end
    end
end