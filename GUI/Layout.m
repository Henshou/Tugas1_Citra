classdef Layout < handle
    % LAYOUT Menangani pembuatan dan pengaturan UI (View)
    properties (SetAccess = private)
        Fig               matlab.ui.Figure
        MainGrid          matlab.ui.container.GridLayout

        BtnSelectInput    matlab.ui.control.Button
        AxInputPreview    matlab.ui.control.UIAxes
        LblInput          matlab.ui.control.Label

        MenuMethod        matlab.ui.control.DropDown
        MenuType          matlab.ui.control.DropDown
        LblParam          matlab.ui.control.Label
        TxtParam          matlab.ui.control.EditField

        PnlKernelGrid     matlab.ui.container.Panel
        KernelFields      cell = {}   

        BtnSelectRef      matlab.ui.control.Button
        AxRefPreview      matlab.ui.control.UIAxes
        LblReference      matlab.ui.control.Label
        BtnAddStep        matlab.ui.control.Button

        LstPipeline       matlab.ui.control.ListBox
        BtnMoveUp         matlab.ui.control.Button
        BtnMoveDown       matlab.ui.control.Button
        BtnRemoveStep     matlab.ui.control.Button
        BtnRunPipeline    matlab.ui.control.Button
        BtnReset          matlab.ui.control.Button

        GridVis           matlab.ui.container.GridLayout
        PnlIn             matlab.ui.container.Panel
        PnlRef            matlab.ui.container.Panel
        PnlOut            matlab.ui.container.Panel

        AxInput           matlab.ui.control.UIAxes
        AxInputHist       matlab.ui.control.UIAxes
        TxtInputFeatures  matlab.ui.control.TextArea

        AxRef             matlab.ui.control.UIAxes
        AxRefHist         matlab.ui.control.UIAxes
        TxtRefFeatures    matlab.ui.control.TextArea

        AxOutput          matlab.ui.control.UIAxes
        AxOutputHist      matlab.ui.control.UIAxes
        TxtOutputFeatures matlab.ui.control.TextArea

        LblStatus         matlab.ui.control.Label

        Colors            struct 
    end

    methods
        function obj = Layout(closeRequestCallback)
            obj.buildUI(closeRequestCallback);
        end

        function setReferenceVisible(obj, visible)
            if visible
                obj.GridVis.ColumnWidth = {'1x', '1x', '1x'};
                obj.PnlRef.Visible = 'on';
            else
                obj.GridVis.ColumnWidth = {'1x', 0, '1x'};
                obj.PnlRef.Visible = 'off';
            end
        end

        function BuildKernelGrid(obj, n)
            delete(obj.PnlKernelGrid.Children);

            innerGrid = uigridlayout(obj.PnlKernelGrid, [n, n]);
            innerGrid.RowSpacing = 2;
            innerGrid.ColumnSpacing = 2;
            innerGrid.Padding = [4 4 4 4];

            obj.KernelFields = cell(n, n);
            for i = 1:n
                for j = 1:n
                    obj.KernelFields{i, j} = uieditfield(innerGrid, 'numeric', ...
                        'Value', 0, 'BackgroundColor', 'white', ...
                        'FontColor', obj.Colors.textDark, 'FontSize', 9, ...
                        'HorizontalAlignment', 'center');
                end
            end
        end

        function mat = GetKernelMatrix(obj)
            n = size(obj.KernelFields, 1);
            mat = zeros(n, n);
            for i = 1:n
                for j = 1:n
                    mat(i, j) = obj.KernelFields{i, j}.Value;
                end
            end
        end

        function SetKernelMatrix(obj, mat)
            n = size(mat, 1);
            if isempty(obj.KernelFields) || size(obj.KernelFields, 1) ~= n
                obj.BuildKernelGrid(n);
            end
            for i = 1:n
                for j = 1:n
                    obj.KernelFields{i, j}.Value = mat(i, j);
                end
            end
        end

        function delete(obj)
            if isvalid(obj.Fig)
                delete(obj.Fig);
            end
        end
    end

    methods (Access = private)
        function buildUI(obj, closeRequestCallback)
        % BUILDUI Main method untuk membangun seluruh UI
            colors = obj.createColorScheme();
            obj.Colors = colors;   % simpan supaya bisa dipakai BuildKernelGrid nanti
            obj.createMainWindow(closeRequestCallback, colors);

            % Top
            obj.buildHeader(colors);

            % Mid
            midGrid = obj.createMidGrid();
            obj.buildControlPanel(midGrid, colors); % Left
            obj.buildRecipePanel(midGrid, colors); % Center
            obj.buildVisualization(midGrid, colors); % Right

            % Bot
            obj.buildStatus(colors);
        end

        function colors = createColorScheme(~)
            colors.background = [0.95 0.96 0.98];
            colors.card =       [0.90 0.92 0.95];
            colors.panel =      [0.13 0.15 0.18];
            colors.text =       [0.96 0.98 1.00];
            colors.textDark =   [0.10 0.12 0.15];
            colors.muted =      [0.78 0.82 0.88];
            colors.primary =    [0.00 0.45 0.85];
            colors.secondary =  [0.22 0.26 0.32];
            colors.success =    [0.10 0.60 0.30];
            colors.axis =       [0.10 0.12 0.15];
            colors.axisText =   [0.80 0.80 0.80];
            colors.danger =     [0.75 0.20 0.20];
        end

        function createMainWindow(obj, closeRequestCallback, colors)
            obj.Fig = uifigure('Name', 'Image Enhancement', ...
                'Position', [30 30 1450 820], 'Color', colors.background, ...
                'CloseRequestFcn', closeRequestCallback);

            obj.MainGrid = uigridlayout(obj.Fig, [3, 1]);
            obj.MainGrid.RowHeight = {45, '1x', 30};
            obj.MainGrid.Padding = [10 10 10 10];
            obj.MainGrid.RowSpacing = 8;
        end

        function buildHeader(obj, colors)
            header = uipanel(obj.MainGrid, 'BackgroundColor', colors.card, 'BorderType', 'none');
            header.Layout.Row = 1;
            uilabel(header, 'Text', 'Image Enhancement Pipeline', ...
                'FontSize', 17, 'FontWeight', 'bold', 'FontColor', colors.textDark, ...
                'Position', [15 8 500 30]);
        end

        function midGrid = createMidGrid(obj)
            midGrid = uigridlayout(obj.MainGrid, [1, 3]);
            midGrid.Layout.Row = 2;
            midGrid.ColumnWidth = {300, 250, '1x'};
            midGrid.ColumnSpacing = 10;
            midGrid.Padding = [0 0 0 0];
        end

        function buildControlPanel(obj, midGrid, colors)
        % BUILDCONTROLPANEL Membuat panel kontrol di grid 1 (Left) dari midGrid
            panel = uipanel(midGrid, 'Title', ' Operations & Step Config ', ...
                'FontWeight', 'bold', 'ForegroundColor', colors.text, ...
                'BackgroundColor', colors.panel);

            % Bagi menjadi 11 baris
            gridControl = uigridlayout(panel, [11, 1]);
            gridControl.RowHeight = {32, 65, 22, 32, 22, 32, 22, 32, 110, 65, 35};
            gridControl.RowSpacing = 4;
            gridControl.Padding = [8 8 8 8];

            % Input Image
            obj.BtnSelectInput = uibutton(gridControl, 'push', 'Text', '1. Pilih Citra Input Utama', ...
                'BackgroundColor', colors.primary, 'FontColor', 'white', 'FontWeight', 'bold');

            inputPreview = uigridlayout(gridControl, [1, 2]);
            inputPreview.ColumnWidth = {60, '1x'};
            inputPreview.Padding = [0 0 0 0];

            obj.AxInputPreview = obj.createPreviewAxes(inputPreview, colors);
            obj.LblInput = uilabel(inputPreview, 'Text', 'Input: Belum dipilih', ...
                'FontColor', colors.muted, 'FontSize', 10, 'WordWrap', 'on');

            % Metode
            uilabel(gridControl, 'Text', 'Metode Enhancement:', ...
                'FontWeight', 'bold', 'FontColor', colors.text);
            obj.MenuMethod = uidropdown(gridControl, 'Items', ...
                {'Intensity Transformation', 'Histogram Equalization', ...
                'Histogram Matching', 'Image Filtering'}, ...
                'BackgroundColor', colors.secondary, 'FontColor', 'white');

            % Tipe / Kernel
            uilabel(gridControl, 'Text', 'Tipe / Kernel:', ...
                'FontWeight', 'bold', 'FontColor', colors.text);
            obj.MenuType = uidropdown(gridControl, 'Items', {'Negative'}, ...
                'BackgroundColor', colors.secondary, 'FontColor', 'white');

            % Parameter 
            obj.LblParam = uilabel(gridControl, 'Text', 'Parameter:', ...
                'FontWeight', 'bold', 'FontColor', colors.text);
            obj.TxtParam = uieditfield(gridControl, 'text', 'Value', '', ...
                'BackgroundColor', 'white', 'FontColor', colors.textDark);

            % Kernel Manual Grid 
            obj.PnlKernelGrid = uipanel(gridControl, 'Title', 'Kernel Manual (isi tiap sel)', ...
                'FontWeight', 'bold', 'ForegroundColor', colors.text, ...
                'BackgroundColor', colors.panel, 'Visible', 'off');

            % Reference Image
            referencePreview = uigridlayout(gridControl, [1, 2]);
            referencePreview.ColumnWidth = {110, '1x'};
            referencePreview.Padding = [0 0 0 0];
            referenceControls = uigridlayout(referencePreview, [2, 1]);
            referenceControls.RowHeight = {28, '1x'};
            referenceControls.Padding = [0 0 0 0];

            obj.BtnSelectRef = uibutton(referenceControls, 'push', ...
                'Text', 'Pilih Reference', 'BackgroundColor', colors.secondary, ...
                'FontColor', 'white', 'FontSize', 10, 'Enable', 'off');
            obj.LblReference = uilabel(referenceControls, 'Text', 'Ref: -', ...
                'FontColor', colors.muted, 'FontSize', 9, 'WordWrap', 'on');
            obj.AxRefPreview = obj.createPreviewAxes(referencePreview, colors);

            % Step Button
            obj.BtnAddStep = uibutton(gridControl, 'push', 'Text', '+ Tambah ke Recipe Stream', ...
                'BackgroundColor', colors.success, 'FontColor', 'white', ...
                'FontWeight', 'bold', 'FontSize', 12);
        end

        function buildRecipePanel(obj, midGrid, colors)
        % BUILDRECIPEPANEL Membuat panel recipe di grid 2 (Center) dari midGrid
            panel = uipanel(midGrid, 'Title', ' Recipe Stream ', ...
                'FontWeight', 'bold', 'ForegroundColor', colors.text, ...
                'BackgroundColor', colors.panel);

            % Bagi menjadi 3 baris untuk menampung listbox dan tombol pengaturan urutan
            grid = uigridlayout(panel, [3, 1]);
            grid.RowHeight = {'1x', 32, 38};
            grid.RowSpacing = 6;
            grid.Padding = [8 8 8 8];

            % List Box
            obj.LstPipeline = uilistbox(grid, 'Items', {}, 'Multiselect', 'on', ...
                'BackgroundColor', [0.18 0.22 0.27], 'FontColor', 'white');

            % Pengatur Urutan
            orderGrid = uigridlayout(grid, [1, 3]);
            orderGrid.ColumnWidth = {'1x', '1x', '1x'};
            orderGrid.Padding = [0 0 0 0];
            obj.BtnMoveUp = uibutton(orderGrid, 'push', 'Text', '▲ Naik', ...
                'BackgroundColor', colors.secondary, 'FontColor', 'white');
            obj.BtnMoveDown = uibutton(orderGrid, 'push', 'Text', '▼ Turun', ...
                'BackgroundColor', colors.secondary, 'FontColor', 'white');
            obj.BtnRemoveStep = uibutton(orderGrid, 'push', 'Text', '✖ Hapus', ...
                'BackgroundColor', colors.danger, 'FontColor', 'white');

            % Run
            runGrid = uigridlayout(grid, [1, 2]);
            runGrid.ColumnWidth = {'1x', 70};
            runGrid.Padding = [0 0 0 0];
            obj.BtnRunPipeline = uibutton(runGrid, 'push', 'Text', '▶ RUN PIPELINE', ...
                'BackgroundColor', colors.primary, 'FontColor', 'white', ...
                'FontWeight', 'bold', 'FontSize', 12);
            obj.BtnReset = uibutton(runGrid, 'push', 'Text', 'Reset', ...
                'BackgroundColor', colors.card, 'FontColor', colors.textDark, ...
                'FontWeight', 'bold');
        end

        function buildVisualization(obj, midGrid, colors)
            obj.GridVis = uigridlayout(midGrid, [1, 3]);
            obj.GridVis.ColumnWidth = {'1x', 0, '1x'};
            obj.GridVis.RowHeight = {'1x'};
            obj.GridVis.ColumnSpacing = 8;
            obj.GridVis.Padding = [0 0 0 0];

            [obj.PnlIn, obj.AxInput, obj.AxInputHist, obj.TxtInputFeatures] = ...
                obj.createVisualizationPanel(' Citra Masukan Step ', colors, true);
            [obj.PnlRef, obj.AxRef, obj.AxRefHist, obj.TxtRefFeatures] = ...
                obj.createVisualizationPanel(' Citra Referensi Step ', colors, false);
            [obj.PnlOut, obj.AxOutput, obj.AxOutputHist, obj.TxtOutputFeatures] = ...
                obj.createVisualizationPanel(' Hasil Output Step ', colors, true);
        end

        function [panel, imageAxes, histogramAxes, featureText] = ...
                createVisualizationPanel(obj, titleText, colors, visible)

            visibility = 'off';
            if visible
                visibility = 'on';
            end

            panel = uipanel(obj.GridVis, 'Title', titleText, ...
                'FontWeight', 'bold', 'ForegroundColor', colors.text, ...
                'BackgroundColor', colors.panel, 'Visible', visibility);

            grid = uigridlayout(panel, [3, 1]);
            grid.RowHeight = {'1x', 140, 80};
            grid.RowSpacing = 6;
            grid.Padding = [4 4 4 4];

            imageAxes = obj.createPreviewAxes(grid, colors);
            histogramAxes = uiaxes(grid, 'BackgroundColor', colors.axis, ...
                'XColor', colors.axisText, 'YColor', colors.axisText);
            featureText = uitextarea(grid, 'Editable', 'off', ...
                'BackgroundColor', colors.background, 'FontColor', colors.textDark, ...
                'FontWeight', 'bold');
        end

        function axesHandle = createPreviewAxes(~, parent, colors)
            axesHandle = uiaxes(parent, 'BackgroundColor', colors.axis, ...
                'XColor', 'none', 'YColor', 'none');
        end

        function buildStatus(obj, colors)
            panel = uipanel(obj.MainGrid, 'BackgroundColor', colors.card, 'BorderType', 'none');
            panel.Layout.Row = 3;
            obj.LblStatus = uilabel(panel, ...
                'Text', ' Ready. Silakan pilih citra input dan susun recipe stream.', ...
                'FontColor', colors.textDark, 'FontWeight', 'bold', ...
                'Position', [10 4 1000 22]);
        end
    end
end