classdef App < handle
    % APP Menangani logika aplikasi & interaksi UI (Controller)

    properties (Access = private)
        UI         Layout
        Service    Service

        ImgInput           uint8
        ImgOutput          uint8
        InputName          char = ''
        
        PipelineSteps      struct = struct('MethodIndex', {}, 'MethodName', {}, 'TypeValue', {}, 'ParamStr', {}, 'ImgRef', {}, 'RefName', {})
        IntermediateImages cell   = {}
        TempStepImgRef     uint8  = []
        TempStepRefName    char   = ''
        
        IsUpdatingUI       logical = false
    end

    methods (Access = public)
        function obj = App(rootFolder)
            if nargin < 1 || isempty(rootFolder)
                rootFolder = fileparts(mfilename('fullpath'));
            end

            obj.Service = Service();
            obj.UI = Layout(@(~,~) obj.delete());

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
            obj.UI.BtnSelectInput.ButtonPushedFcn  = @(~,~) obj.selectInput();
            obj.UI.BtnSelectRef.ButtonPushedFcn    = @(~,~) obj.selectStepReference();
            obj.UI.MenuMethod.ValueChangedFcn      = @(~,~) obj.onConfigChanged();
            obj.UI.MenuType.ValueChangedFcn        = @(~,~) obj.onConfigChanged();
            obj.UI.TxtParam.ValueChangedFcn        = @(~,~) obj.onConfigChanged();

            obj.UI.BtnAddStep.ButtonPushedFcn      = @(~,~) obj.addStep();
            obj.UI.BtnRemoveStep.ButtonPushedFcn   = @(~,~) obj.removeStep();
            obj.UI.BtnMoveUp.ButtonPushedFcn       = @(~,~) obj.moveStepUp();
            obj.UI.BtnMoveDown.ButtonPushedFcn     = @(~,~) obj.moveStepDown();
            obj.UI.LstPipeline.ValueChangedFcn     = @(~,~) obj.onStepSelected();
            obj.UI.Fig.WindowButtonDownFcn         = @(~,~) obj.onRecipeStreamClicked();

            obj.UI.BtnRunPipeline.ButtonPushedFcn  = @(~,~) obj.runPipeline();
            obj.UI.BtnReset.ButtonPushedFcn        = @(~,~) obj.resetGui();
        end

        function selectInput(obj)
            [fileName, folderName] = uigetfile( ...
                {'*.jpg;*.jpeg;*.png;*.bmp;*.tif', 'Image files'}, 'Pilih Citra Input Utama');
            if isequal(fileName, 0), return; end

            obj.ImgInput = imread(fullfile(folderName, fileName));
            obj.InputName = fileName;
            obj.UI.LblInput.Text = fileName;

            imshow(obj.ImgInput, 'Parent', obj.UI.AxInputPreview);
            obj.UI.LblStatus.Text = 'Citra input utama dimuat.';
        end

        function selectStepReference(obj)
            [fileName, folderName] = uigetfile( ...
                {'*.jpg;*.jpeg;*.png;*.bmp;*.tif', 'Image files'}, 'Pilih Citra Referensi Step');
            if isequal(fileName, 0), return; end

            obj.TempStepImgRef = imread(fullfile(folderName, fileName));
            obj.TempStepRefName = fileName;
            obj.UI.LblReference.Text = fileName;

            imshow(obj.TempStepImgRef, 'Parent', obj.UI.AxRefPreview);

            obj.onConfigChanged();
        end

        function updateParameterPanel(obj)
            methodIndex = find(strcmp(obj.UI.MenuMethod.Value, obj.UI.MenuMethod.Items));
            obj.UI.BtnSelectRef.Enable = 'off';
            
            if methodIndex == 3
                obj.UI.MenuType.Items = {'Standard'};
                obj.UI.MenuType.Enable = 'off';
                obj.UI.LblParam.Text = 'Parameter:';
                obj.UI.TxtParam.Value = 'Membutuhkan Reference';
                obj.UI.TxtParam.Enable = 'off';
                obj.UI.BtnSelectRef.Enable = 'on';

                if ~isempty(obj.TempStepImgRef)
                    imshow(obj.TempStepImgRef, 'Parent', obj.UI.AxRefPreview);
                end
            else
                cla(obj.UI.AxRefPreview);

                if methodIndex == 1
                    typeItems = {'Negative', 'Log', 'Gamma', 'Contrast'};
                    obj.UI.MenuType.Items = typeItems;
                    obj.UI.MenuType.Enable = 'on';
                    
                    if strcmp(obj.UI.MenuType.Value, 'Gamma')
                        obj.UI.LblParam.Text = 'Parameter Gamma:';
                        if isempty(obj.UI.TxtParam.Value) || strcmp(obj.UI.TxtParam.Value, 'Tidak diperlukan')
                            obj.UI.TxtParam.Value = '0.5';
                        end
                        obj.UI.TxtParam.Enable = 'on';
                    elseif strcmp(obj.UI.MenuType.Value, 'Contrast')
                        obj.UI.LblParam.Text = 'Rentang Contrast [low high]:';
                        if isempty(obj.UI.TxtParam.Value) || strcmp(obj.UI.TxtParam.Value, 'Tidak diperlukan')
                            obj.UI.TxtParam.Value = '[0 1]';
                        end
                        obj.UI.TxtParam.Enable = 'on';
                    else
                        obj.UI.LblParam.Text = 'Parameter:';
                        obj.UI.TxtParam.Value = 'Tidak diperlukan';
                        obj.UI.TxtParam.Enable = 'off';
                    end

                elseif methodIndex == 4
                    typeItems = {'Mean 3x3', 'Gaussian 3x3', 'Sharpen 3x3', 'Edge 3x3', 'Manual 3x3'};
                    obj.UI.MenuType.Items = typeItems;
                    obj.UI.MenuType.Enable = 'on';

                    if strcmp(obj.UI.MenuType.Value, 'Manual 3x3')
                        obj.UI.LblParam.Text = 'Kernel Manual 3x3:';
                        if isempty(obj.UI.TxtParam.Value) || strcmp(obj.UI.TxtParam.Value, 'Tidak diperlukan')
                            obj.UI.TxtParam.Value = '[1 1 1; 1 1 1; 1 1 1]/9';
                        end
                        obj.UI.TxtParam.Enable = 'on';
                    else
                        obj.UI.LblParam.Text = 'Parameter:';
                        obj.UI.TxtParam.Value = 'Tidak diperlukan';
                        obj.UI.TxtParam.Enable = 'off';
                    end
                else
                    obj.UI.MenuType.Items = {'Standard'};
                    obj.UI.MenuType.Enable = 'off';
                    obj.UI.LblParam.Text = 'Parameter:';
                    obj.UI.TxtParam.Value = 'Tidak diperlukan';
                    obj.UI.TxtParam.Enable = 'off';
                end
            end
        end

        function onConfigChanged(obj)
            if obj.IsUpdatingUI, return; end
            
            obj.updateParameterPanel();
            
            idx = obj.getSelectedStepIndex();
            if idx > 0
                obj.PipelineSteps(idx).MethodIndex = find(strcmp(obj.UI.MenuMethod.Value, obj.UI.MenuMethod.Items));
                obj.PipelineSteps(idx).MethodName  = obj.UI.MenuMethod.Value;
                obj.PipelineSteps(idx).TypeValue   = obj.UI.MenuType.Value;
                obj.PipelineSteps(idx).ParamStr    = obj.UI.TxtParam.Value;
                obj.PipelineSteps(idx).ImgRef      = obj.TempStepImgRef;
                obj.PipelineSteps(idx).RefName     = obj.TempStepRefName;
                
                obj.refreshPipelineList();
                obj.UI.LstPipeline.Value = {obj.UI.LstPipeline.Items{idx}};
            end
        end

        function addStep(obj)
            methodIdx  = find(strcmp(obj.UI.MenuMethod.Value, obj.UI.MenuMethod.Items));
            methodName = obj.UI.MenuMethod.Value;
            typeVal    = obj.UI.MenuType.Value;
            paramVal   = obj.UI.TxtParam.Value;
            selectedIdx = obj.getSelectedStepIndex();

            if methodIdx == 3 && isempty(obj.TempStepImgRef)
                uialert(obj.UI.Fig, 'Silakan pilih Citra Referensi terlebih dahulu.', 'Reference Missing');
                return;
            end

            stepData = struct( ...
                'MethodIndex', methodIdx, ...
                'MethodName', methodName, ...
                'TypeValue', typeVal, ...
                'ParamStr', paramVal, ...
                'ImgRef', obj.TempStepImgRef, ...
                'RefName', obj.TempStepRefName ...
            );

            if selectedIdx > 0
                obj.PipelineSteps(selectedIdx) = stepData;
                obj.refreshPipelineList();
                obj.UI.LstPipeline.Value = {obj.UI.LstPipeline.Items{selectedIdx}};
                obj.UI.BtnAddStep.Text = 'Update Recipe';
                obj.UI.LblStatus.Text = 'Recipe berhasil diperbarui.';
            else
                obj.PipelineSteps(end+1) = stepData;
                obj.refreshPipelineList();
                obj.UI.LstPipeline.Value = {};
                obj.clearTemporaryReference();
                obj.UI.LblStatus.Text = 'Langkah berhasil ditambahkan.';
            end
        end

        function onStepSelected(obj)
            idx = obj.getSelectedStepIndex();
            if idx == 0
                obj.UI.BtnAddStep.Text = '+ Tambah ke Recipe Stream';
                return;
            end

            obj.UI.BtnAddStep.Text = 'Update Recipe';

            st = obj.PipelineSteps(idx);
            
            obj.IsUpdatingUI = true;
            obj.UI.MenuMethod.Value = st.MethodName;
            obj.updateParameterPanel();
            
            if any(strcmp(st.TypeValue, obj.UI.MenuType.Items))
                obj.UI.MenuType.Value = st.TypeValue;
            end
            obj.UI.TxtParam.Value = st.ParamStr;
            obj.TempStepImgRef = st.ImgRef;
            obj.TempStepRefName = st.RefName;
            
            if ~isempty(st.RefName)
                obj.UI.LblReference.Text = st.RefName;
                imshow(st.ImgRef, 'Parent', obj.UI.AxRefPreview);
            else
                obj.UI.LblReference.Text = 'Ref: -';
                cla(obj.UI.AxRefPreview);
            end
            obj.IsUpdatingUI = false;

            if ~isempty(obj.IntermediateImages)
                obj.inspectStep(idx);
            end
        end

        function removeStep(obj)
            idx = obj.getSelectedStepIndex();
            if idx == 0, return; end

            obj.PipelineSteps(idx) = [];
            obj.refreshPipelineList();
            obj.UI.LblStatus.Text = 'Langkah dihapus dari recipe.';
        end

        function moveStepUp(obj)
            idx = obj.getSelectedStepIndex();
            if idx <= 1, return; end

            temp = obj.PipelineSteps(idx-1);
            obj.PipelineSteps(idx-1) = obj.PipelineSteps(idx);
            obj.PipelineSteps(idx) = temp;

            obj.refreshPipelineList();
            obj.UI.LstPipeline.Value = {obj.UI.LstPipeline.Items{idx-1}};
        end

        function moveStepDown(obj)
            idx = obj.getSelectedStepIndex();
            if idx == 0 || idx >= length(obj.PipelineSteps), return; end

            temp = obj.PipelineSteps(idx+1);
            obj.PipelineSteps(idx+1) = obj.PipelineSteps(idx);
            obj.PipelineSteps(idx) = temp;

            obj.refreshPipelineList();
            obj.UI.LstPipeline.Value = {obj.UI.LstPipeline.Items{idx+1}};
        end

        function refreshPipelineList(obj)
            items = cell(1, length(obj.PipelineSteps));
            for i = 1:length(obj.PipelineSteps)
                st = obj.PipelineSteps(i);
                items{i} = sprintf('%d. %s (%s)', i, st.MethodName, st.TypeValue);
            end
            obj.UI.LstPipeline.Items = items;
        end

        function clearTemporaryReference(obj)
            obj.TempStepImgRef = [];
            obj.TempStepRefName = '';
            obj.UI.LblReference.Text = 'Ref: -';
            cla(obj.UI.AxRefPreview);
            obj.UI.BtnAddStep.Text = '+ Tambah ke Recipe Stream';
        end

        function onRecipeStreamClicked(obj)
            if isempty(obj.PipelineSteps) || ~isequal(obj.UI.Fig.CurrentObject, obj.UI.LstPipeline)
                return;
            end

            listPosition = getpixelposition(obj.UI.LstPipeline, true);
            clickPosition = obj.UI.Fig.CurrentPoint;
            rowHeight = max(18, obj.UI.LstPipeline.FontSize + 8);
            itemAreaBottom = listPosition(2) + listPosition(4) - ...
                min(length(obj.PipelineSteps) * rowHeight, listPosition(4));

            if clickPosition(2) < itemAreaBottom
                obj.UI.LstPipeline.Value = {};
                obj.onStepSelected();
            end
        end

        function idx = getSelectedStepIndex(obj)
            val = obj.UI.LstPipeline.Value;
            if isempty(val), idx = 0; return; end
            if iscell(val), val = val{1}; end
            items = obj.UI.LstPipeline.Items;
            idx = find(strcmp(val, items), 1);
            if isempty(idx), idx = 0; end
        end

        function runPipeline(obj)
            if isempty(obj.ImgInput)
                uialert(obj.UI.Fig, 'Silakan pilih Citra Input Utama terlebih dahulu.', 'Input Belum Ada');
                return;
            end
            if isempty(obj.PipelineSteps)
                uialert(obj.UI.Fig, 'Recipe Pipeline masih kosong.', 'Pipeline Kosong');
                return;
            end

            try
                [obj.ImgOutput, obj.IntermediateImages] = obj.Service.processPipeline(obj.ImgInput, obj.PipelineSteps);
                
                lastIdx = length(obj.PipelineSteps);
                obj.inspectStep(lastIdx);

                obj.UI.LblStatus.Text = 'Pipeline selesai dieksekusi.';
            catch exception
                uialert(obj.UI.Fig, exception.message, 'Eksekusi Pipeline Gagal');
            end
        end

        function inspectStep(obj, idx)
            if nargin < 2
                idx = obj.getSelectedStepIndex();
            end
            if idx == 0 || idx > length(obj.IntermediateImages), return; end

            if idx == 1
                stepInput = obj.ImgInput;
                inTitle = 'Input Utama (Step 1)';
            else
                stepInput = obj.IntermediateImages{idx-1};
                inTitle = sprintf('Hasil Step %d (Input Step %d)', idx-1, idx);
            end

            imshow(stepInput, 'Parent', obj.UI.AxInput);
            title(obj.UI.AxInput, inTitle, 'Color', 'w');
            obj.Service.plotHistogramToAxes(stepInput, obj.UI.AxInputHist, 'Histogram Input Step');
            obj.UI.TxtInputFeatures.Value = obj.Service.formatFeatures(stepInput);

            stepInfo = obj.PipelineSteps(idx);
            if stepInfo.MethodIndex == 3 && ~isempty(stepInfo.ImgRef)
                obj.UI.setReferenceVisible(true);
                imshow(stepInfo.ImgRef, 'Parent', obj.UI.AxRef);
                title(obj.UI.AxRef, ['Ref: ' stepInfo.RefName], 'Interpreter', 'none', 'Color', 'w');
                obj.Service.plotHistogramToAxes(stepInfo.ImgRef, obj.UI.AxRefHist, 'Histogram Reference');
                obj.UI.TxtRefFeatures.Value = obj.Service.formatFeatures(stepInfo.ImgRef);
            else
                obj.UI.setReferenceVisible(false);
            end

            stepOutput = obj.IntermediateImages{idx};
            imshow(stepOutput, 'Parent', obj.UI.AxOutput);
            title(obj.UI.AxOutput, sprintf('Hasil Output Step %d', idx), 'Color', 'w');
            obj.Service.plotHistogramToAxes(stepOutput, obj.UI.AxOutputHist, sprintf('Histogram Output Step %d', idx));
            obj.UI.TxtOutputFeatures.Value = obj.Service.formatFeatures(stepOutput);

            obj.UI.LblStatus.Text = sprintf('Menampilkan inspeksi Step %d.', idx);
        end

        function resetGui(obj)
            obj.ImgInput = [];
            obj.ImgOutput = [];
            obj.InputName = '';
            obj.PipelineSteps = struct('MethodIndex', {}, 'MethodName', {}, 'TypeValue', {}, 'ParamStr', {}, 'ImgRef', {}, 'RefName', {});
            obj.IntermediateImages = {};
            obj.TempStepImgRef = [];
            obj.TempStepRefName = '';

            cla(obj.UI.AxInputPreview); cla(obj.UI.AxRefPreview);
            cla(obj.UI.AxInput);        cla(obj.UI.AxInputHist);
            cla(obj.UI.AxRef);          cla(obj.UI.AxRefHist);
            cla(obj.UI.AxOutput);       cla(obj.UI.AxOutputHist);

            obj.UI.LblInput.Text = 'Input: Belum dipilih';
            obj.UI.LblReference.Text = 'Ref: -';
            obj.UI.TxtInputFeatures.Value = '';
            obj.UI.TxtRefFeatures.Value = '';
            obj.UI.TxtOutputFeatures.Value = '';
            obj.UI.LstPipeline.Items = {};
            obj.UI.LstPipeline.Value = {};
            obj.UI.BtnAddStep.Text = '+ Tambah ke Recipe Stream';
            obj.UI.setReferenceVisible(false);
            obj.UI.LblStatus.Text = 'Reset selesai.';

            obj.updateParameterPanel();
        end
    end
end