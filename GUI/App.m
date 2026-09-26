classdef App < handle
    % APP Main Application Controller

    properties (Access = private)
        UI         Layout
        Service    Service
        
        % Data State
        ImgInput      uint8
        ImgReference  uint8
        ImgOutput     uint8
        InputName     char = ''
        ReferenceName char = ''
    end

    methods (Access = public)
        function obj = App(rootFolder)
            if nargin < 1 || isempty(rootFolder)
                rootFolder = fileparts(mfilename('fullpath'));
            end

            obj.Service = Service();
            obj.UI = Layout(@(~,~) obj.delete());

            % Bind
            obj.bindEvents();

            obj.updateParameterPanel();
        end

        function delete(obj)
            if ~isempty(obj.UI) && isvalid(obj.UI)
                delete(obj.UI);
            end
        end
    end

    methods (Access = private)
        function bindEvents(obj)
            obj.UI.BtnSelectInput.ButtonPushedFcn = @(~,~) obj.selectInput();
            obj.UI.BtnSelectRef.ButtonPushedFcn   = @(~,~) obj.selectReference();
            obj.UI.MenuMethod.ValueChangedFcn     = @(~,~) obj.updateParameterPanel();
            obj.UI.MenuType.ValueChangedFcn       = @(~,~) obj.updateParameterPanel();
            obj.UI.BtnProcess.ButtonPushedFcn     = @(~,~) obj.processImage();
            obj.UI.BtnReset.ButtonPushedFcn       = @(~,~) obj.resetGui();
        end

        function selectInput(obj)
        %SELECTINPUT Memilih citra input dari file.
            [fileName, folderName] = uigetfile( ...
                {'*.jpg;*.jpeg;*.png;*.bmp;*.tif', 'Image files'}, 'Pilih citra input');
            if isequal(fileName, 0), return; end

            obj.ImgInput = imread(fullfile(folderName, fileName));
            obj.InputName = fileName;
            obj.UI.LblInput.Text = fileName;

            imshow(obj.ImgInput, 'Parent', obj.UI.AxInput);
            title(obj.UI.AxInput, ['Input: ' obj.InputName], 'Interpreter', 'none');

            obj.UI.TxtInputFeatures.Value = obj.Service.formatFeatures(obj.ImgInput);
            obj.UI.LblStatus.Text = 'Citra input berhasil dimuat.';
        end

        function selectReference(obj)
        %SELECTREFERENCE Memilih citra referensi dari file.
            [fileName, folderName] = uigetfile( ...
                {'*.jpg;*.jpeg;*.png;*.bmp;*.tif', 'Image files'}, 'Pilih citra referensi');
            if isequal(fileName, 0), return; end

            obj.ImgReference = imread(fullfile(folderName, fileName));
            obj.ReferenceName = fileName;
            obj.UI.LblReference.Text = fileName;
            obj.UI.LblStatus.Text = 'Citra referensi berhasil dimuat.';
        end

        function updateParameterPanel(obj)
        %UPDATEPARAMETERPANEL Memperbarui panel parameter sesuai metode & tipe.
            methodIndex = find(strcmp(obj.UI.MenuMethod.Value, obj.UI.MenuMethod.Items));
            if methodIndex == 1
                typeItems = {'Negative', 'Log', 'Gamma', 'Contrast'};
                currentType = obj.UI.MenuType.Value;
                obj.UI.MenuType.Items = typeItems;
                obj.UI.MenuType.Enable = 'on';
                if ~any(strcmp(currentType, typeItems))
                    obj.UI.MenuType.Value = 'Negative';
                end

                if any(strcmp(obj.UI.MenuType.Value, {'Negative', 'Log'}))
                    obj.UI.LblParam.Text = 'Parameter';
                    obj.UI.TxtParam.Value = 'Tidak diperlukan';
                    obj.UI.TxtParam.Enable = 'off';
                elseif strcmp(obj.UI.MenuType.Value, 'Gamma')
                    obj.UI.LblParam.Text = 'Parameter Gamma';
                    obj.UI.TxtParam.Value = '0.5';
                    obj.UI.TxtParam.Enable = 'on';
                else
                    obj.UI.LblParam.Text = 'Rentang Contrast [low high]';
                    obj.UI.TxtParam.Value = '[0 1]';
                    obj.UI.TxtParam.Enable = 'on';
                end
            elseif methodIndex == 4
                typeItems = {'Mean 3x3', 'Gaussian 3x3', 'Sharpen 3x3', 'Edge 3x3', 'Manual 3x3'};
                currentType = obj.UI.MenuType.Value;
                obj.UI.MenuType.Items = typeItems;
                obj.UI.MenuType.Enable = 'on';
                if ~any(strcmp(currentType, typeItems))
                    obj.UI.MenuType.Value = 'Mean 3x3';
                end

                if strcmp(obj.UI.MenuType.Value, 'Manual 3x3')
                    obj.UI.LblParam.Text = 'Kernel manual 3x3';
                    obj.UI.TxtParam.Value = '[1 1 1; 1 1 1; 1 1 1] / 9';
                    obj.UI.TxtParam.Enable = 'on';
                else
                    obj.UI.LblParam.Text = 'Parameter';
                    obj.UI.TxtParam.Value = 'Tidak diperlukan';
                    obj.UI.TxtParam.Enable = 'off';
                end
            else
                obj.UI.MenuType.Items = {'Tidak diperlukan'};
                obj.UI.MenuType.Enable = 'off';
                obj.UI.LblParam.Text = 'Parameter';
                obj.UI.TxtParam.Value = 'Tidak diperlukan';
                obj.UI.TxtParam.Enable = 'off';
            end
        end

        function processImage(obj)
        %PROCESSIMAGE Memproses citra input sesuai metode & parameter.
            if isempty(obj.ImgInput)
                uialert(obj.UI.MainFig, 'Pilih citra input terlebih dahulu.', 'Input belum tersedia');
                return;
            end

            methodIndex = find(strcmp(obj.UI.MenuMethod.Value, obj.UI.MenuMethod.Items));
            try
                obj.ImgOutput = obj.Service.process( ...
                    methodIndex, ...
                    obj.UI.MenuType.Value, ...
                    obj.UI.TxtParam.Value, ...
                    obj.ImgInput, ...
                    obj.ImgReference ...
                );
            catch exception
                uialert(obj.UI.MainFig, exception.message, 'Parameter / Pemrosesan Gagal');
                return;
            end

            imshow(obj.ImgOutput, 'Parent', obj.UI.AxOutput);
            title(obj.UI.AxOutput, 'Citra Hasil');
            obj.UI.TxtOutputFeatures.Value = obj.Service.formatFeatures(obj.ImgOutput);
            obj.UI.LblStatus.Text = 'Enhancement selesai.';
        end

        function resetGui(obj)
        %RESETGUI Mengatur ulang GUI dan data internal.
            obj.ImgInput = [];
            obj.ImgReference = [];
            obj.ImgOutput = [];
            obj.InputName = '';
            obj.ReferenceName = '';

            cla(obj.UI.AxInput);
            cla(obj.UI.AxOutput);

            obj.UI.LblInput.Text = 'Belum ada citra input';
            obj.UI.LblReference.Text = 'Belum ada citra referensi';
            obj.UI.TxtInputFeatures.Value = '';
            obj.UI.TxtOutputFeatures.Value = '';
            obj.UI.LblStatus.Text = 'Pilih citra input untuk memulai.';

            obj.updateParameterPanel();
        end
    end
end