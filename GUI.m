function gui
%GUI App GUI utama.

    rootFolder = fileparts(mfilename('fullpath'));
    addpath(fullfile(rootFolder, 'functions', 'common'));
    addpath(fullfile(rootFolder, 'functions', 'methods'));

    state.imgInput = [];
    state.imgReference = [];
    state.imgOutput = [];
    state.inputName = '';
    state.referenceName = '';

    mainFig = figure('Name', 'Image Enhancement GUI', ...
        'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
        'Color', [0.94 0.94 0.94], 'Position', [80 80 1280 720]);

    uicontrol(mainFig, 'Style', 'text', 'String', 'Image Enhancement', ...
        'FontSize', 18, 'FontWeight', 'bold', 'BackgroundColor', [0.94 0.94 0.94], ...
        'Position', [20 675 1240 30]);

    uicontrol(mainFig, 'Style', 'pushbutton', 'String', 'Pilih Citra Input', ...
        'Position', [20 625 145 32], 'Callback', @selectInput);
    inputLabel = uicontrol(mainFig, 'Style', 'text', 'String', 'Belum ada citra input', ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.94 0.94 0.94], ...
        'Position', [175 625 300 32]);

    uicontrol(mainFig, 'Style', 'pushbutton', 'String', 'Pilih Citra Referensi', ...
        'Position', [20 585 145 32], 'Callback', @selectReference);
    referenceLabel = uicontrol(mainFig, 'Style', 'text', 'String', ...
        'Belum ada citra referensi', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.94 0.94 0.94], 'Position', [175 585 300 32]);

    uicontrol(mainFig, 'Style', 'text', 'String', 'Metode', ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.94 0.94 0.94], ...
        'Position', [20 535 100 22]);
    methodMenu = uicontrol(mainFig, 'Style', 'popupmenu', ...
        'String', {'Intensity Transformation', 'Histogram Equalization', ...
        'Histogram Matching', 'Image Filtering'}, 'Position', [125 535 250 28], ...
        'Callback', @updateParameterPanel);

    uicontrol(mainFig, 'Style', 'text', 'String', 'Jenis / Kernel', ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.94 0.94 0.94], ...
        'Position', [20 490 100 22]);
    typeMenu = uicontrol(mainFig, 'Style', 'popupmenu', ...
        'String', {'Negative', 'Log', 'Gamma', 'Contrast'}, ...
        'Position', [125 490 250 28]);

    parameterLabel = uicontrol(mainFig, 'Style', 'text', 'String', 'Parameter', ...
        'HorizontalAlignment', 'left', 'BackgroundColor', [0.94 0.94 0.94], ...
        'Position', [20 445 100 22]);
    parameterEdit = uicontrol(mainFig, 'Style', 'edit', 'String', '0.5', ...
        'HorizontalAlignment', 'left', 'Position', [125 445 250 28]);

    uicontrol(mainFig, 'Style', 'pushbutton', 'String', 'Proses Enhancement', ...
        'FontWeight', 'bold', 'Position', [20 390 355 38], 'Callback', @processImage);
    uicontrol(mainFig, 'Style', 'pushbutton', 'String', 'Reset', ...
        'Position', [20 350 355 30], 'Callback', @resetGui);

    inputAxes = axes('Parent', mainFig, 'Units', 'pixels', ...
        'Position', [410 390 390 270]);
    title(inputAxes, 'Citra Masukan');
    outputAxes = axes('Parent', mainFig, 'Units', 'pixels', ...
        'Position', [830 390 390 270]);
    title(outputAxes, 'Citra Hasil');

    uicontrol(mainFig, 'Style', 'text', 'String', 'Fitur Citra Masukan', ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.94 0.94 0.94], 'Position', [410 330 390 25]);
    inputFeatures = uicontrol(mainFig, 'Style', 'edit', 'Max', 2, ...
        'Enable', 'inactive', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', 'white', 'Position', [410 270 390 60]);

    uicontrol(mainFig, 'Style', 'text', 'String', 'Fitur Citra Hasil', ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.94 0.94 0.94], 'Position', [830 330 390 25]);
    outputFeatures = uicontrol(mainFig, 'Style', 'edit', 'Max', 2, ...
        'Enable', 'inactive', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', 'white', 'Position', [830 270 390 60]);

    statusLabel = uicontrol(mainFig, 'Style', 'text', 'String', ...
        'Pilih citra input untuk memulai.', 'HorizontalAlignment', 'left', ...
        'BackgroundColor', [0.94 0.94 0.94], 'Position', [20 300 355 30]);

    updateParameterPanel([], []);

    function selectInput(~, ~)
        [fileName, folderName] = uigetfile( ...
            {'*.jpg;*.jpeg;*.png;*.bmp;*.tif', 'Image files'}, ...
            'Pilih citra input');
        if isequal(fileName, 0)
            return;
        end
        state.imgInput = imread(fullfile(folderName, fileName));
        state.inputName = fileName;
        set(inputLabel, 'String', fileName);
        showInputImage();
        set(inputFeatures, 'String', formatFeatures(imageAnalysis(state.imgInput)));
        set(statusLabel, 'String', 'Citra input berhasil dimuat.');
    end

    function selectReference(~, ~)
        [fileName, folderName] = uigetfile( ...
            {'*.jpg;*.jpeg;*.png;*.bmp;*.tif', 'Image files'}, ...
            'Pilih citra referensi');
        if isequal(fileName, 0)
            return;
        end
        state.imgReference = imread(fullfile(folderName, fileName));
        state.referenceName = fileName;
        set(referenceLabel, 'String', fileName);
        set(statusLabel, 'String', 'Citra referensi berhasil dimuat.');
    end

    function updateParameterPanel(~, ~)
        methodIndex = get(methodMenu, 'Value');
        if methodIndex == 1
            set(typeMenu, 'String', {'Negative', 'Log', 'Gamma', 'Contrast'}, ...
                'Enable', 'on', 'Value', 1);
            set(parameterLabel, 'String', 'Parameter');
            set(parameterEdit, 'String', '0.5', 'Enable', 'on');
        elseif methodIndex == 4
            set(typeMenu, 'String', {'Mean 3x3', 'Gaussian 3x3', ...
                'Sharpen 3x3', 'Edge 3x3', 'Manual 3x3'}, ...
                'Enable', 'on', 'Value', 1);
            set(parameterLabel, 'String', 'Kernel manual');
            set(parameterEdit, 'String', '[1 1 1; 1 1 1; 1 1 1] / 9', ...
                'Enable', 'on');
        else
            set(typeMenu, 'String', {'Tidak diperlukan'}, 'Enable', 'off');
            set(parameterLabel, 'String', 'Parameter');
            set(parameterEdit, 'String', 'Tidak diperlukan', 'Enable', 'off');
        end
    end

    function processImage(~, ~)
        if isempty(state.imgInput)
            errordlg('Pilih citra input terlebih dahulu.', 'Input belum tersedia');
            return;
        end

        methodIndex = get(methodMenu, 'Value');
        try
            switch methodIndex
                case 1
                    typeNames = get(typeMenu, 'String');
                    typeName = lower(typeNames{get(typeMenu, 'Value')});
                    parameter = parseIntensityParameter(typeName);
                    state.imgOutput = intensityTransformation(state.imgInput, ...
                        typeName, parameter);
                case 2
                    state.imgOutput = histogramEqualization(state.imgInput);
                case 3
                    if isempty(state.imgReference)
                        errordlg('Pilih citra referensi untuk histogram matching.', ...
                            'Referensi belum tersedia');
                        return;
                    end
                    state.imgOutput = histogramMatching(state.imgInput, ...
                        state.imgReference);
                case 4
                    kernel = parseKernel();
                    state.imgOutput = convFilt(state.imgInput, kernel);
            end
        catch exception
            errordlg(exception.message, 'Parameter tidak valid');
            return;
        end

        imshow(state.imgOutput, 'Parent', outputAxes);
        title(outputAxes, 'Citra Hasil');
        set(outputFeatures, 'String', formatFeatures(imageAnalysis(state.imgOutput)));
        set(statusLabel, 'String', 'Enhancement selesai.');
    end

    function parameter = parseIntensityParameter(typeName)
        if strcmp(typeName, 'gamma')
            parameter = str2double(get(parameterEdit, 'String'));
            if isnan(parameter) || parameter <= 0
                error('Parameter gamma harus berupa angka positif.');
            end
        elseif strcmp(typeName, 'contrast')
            parameter = str2num(get(parameterEdit, 'String')); %#ok<ST2NM>
            if numel(parameter) ~= 2 || any(~isfinite(parameter)) || ...
                    parameter(1) >= parameter(2)
                error('Contrast harus berupa [low high], dengan low < high.');
            end
        else
            parameter = [];
        end
    end

    function kernel = parseKernel()
        typeNames = get(typeMenu, 'String');
        typeName = typeNames{get(typeMenu, 'Value')};
        if strcmp(typeName, 'Mean 3x3')
            kernel = ones(3, 3) / 9;
        elseif strcmp(typeName, 'Gaussian 3x3')
            kernel = [1 2 1; 2 4 2; 1 2 1] / 16;
        elseif strcmp(typeName, 'Sharpen 3x3')
            kernel = [0 -1 0; -1 5 -1; 0 -1 0];
        elseif strcmp(typeName, 'Edge 3x3')
            kernel = [-1 -1 -1; -1 8 -1; -1 -1 -1];
        else
            kernel = str2num(get(parameterEdit, 'String')); %#ok<ST2NM>
        end
        if isempty(kernel) || ndims(kernel) ~= 2 || ...
                any(size(kernel) ~= [3 3]) || any(~isfinite(kernel(:)))
            error('Kernel harus berupa matriks 3x3 yang valid.');
        end
    end

    function showInputImage()
        imshow(state.imgInput, 'Parent', inputAxes);
        title(inputAxes, ['Input: ' state.inputName], 'Interpreter', 'none');
    end

    function resetGui(~, ~)
        state.imgInput = [];
        state.imgReference = [];
        state.imgOutput = [];
        state.inputName = '';
        state.referenceName = '';
        cla(inputAxes);
        cla(outputAxes);
        set(inputLabel, 'String', 'Belum ada citra input');
        set(referenceLabel, 'String', 'Belum ada citra referensi');
        set(inputFeatures, 'String', '');
        set(outputFeatures, 'String', '');
        set(statusLabel, 'String', 'Pilih citra input untuk memulai.');
        updateParameterPanel([], []);
    end

    function text = formatFeatures(analysis)
        f = analysis.fitur;
        text = sprintf(['Min: %.1f\nMax: %.1f\nMean: %.2f\nStd: %.2f\n' ...
            'Entropy: %.2f'], f.minVal, f.maxVal, f.meanVal, ...
            f.stdVal, f.entropi);
    end
end
