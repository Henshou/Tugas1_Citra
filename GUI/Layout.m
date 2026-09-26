classdef Layout < handle
    % LAYOUT Menangani pembuatan dan pengaturan elemen View

    properties (SetAccess = private)
        Fig           matlab.ui.Figure
        Grid          matlab.ui.container.GridLayout
        
        % Control Panel Elements
        BtnSelectInput    matlab.ui.control.Button
        LblInput          matlab.ui.control.Label
        BtnSelectRef      matlab.ui.control.Button
        LblReference      matlab.ui.control.Label
        MenuMethod        matlab.ui.control.DropDown
        MenuType          matlab.ui.control.DropDown
        LblParam          matlab.ui.control.Label
        TxtParam          matlab.ui.control.EditField
        BtnProcess        matlab.ui.control.Button
        BtnReset          matlab.ui.control.Button
        LblStatus         matlab.ui.control.Label
        
        % Image Canvas Elements
        AxInput           matlab.ui.control.UIAxes
        AxOutput          matlab.ui.control.UIAxes
        
        % Inspection Area
        TxtInputFeatures  matlab.ui.control.TextArea
        TxtOutputFeatures matlab.ui.control.TextArea
    end

    methods
        function obj = Layout(closeRequestCallback)
            obj.buildUI(closeRequestCallback);
        end

        function delete(obj)
            if isvalid(obj.Fig)
                delete(obj.Fig);
            end
        end
    end

    methods (Access = private)
        function buildUI(obj, closeRequestCallback)
            % Color Palette
            cBg        = [0.98 0.99 1.00];
            cCard      = [0.92 0.94 0.96];
            cPanel     = [0.13 0.15 0.18];
            cText      = [0.96 0.98 1.00];
            cTextDark  = [0.10 0.12 0.15];
            cMuted     = [0.78 0.82 0.88];
            cPrimary   = [0.00 0.45 0.85]; 
            cSecondary = [0.20 0.25 0.30]; 
            cDropDown  = [0.20 0.25 0.30];
            
            obj.Fig = uifigure('Name', 'Image Enhancement Workbench', ...
                'Position', [80 80 1280 720], ...
                'Color', cBg, ...
                'CloseRequestFcn', closeRequestCallback);

            % Grid Top, Middle, Bottom
            obj.Grid = uigridlayout(obj.Fig, [3, 1]);
            obj.Grid.RowHeight = {50, '1x', 30};
            obj.Grid.ColumnWidth = {'1x'};
            obj.Grid.Padding = [15 15 15 15];
            obj.Grid.RowSpacing = 10;

            pnlHeader = uipanel(obj.Grid, 'BackgroundColor', cCard, 'BorderType', 'none');
            pnlHeader.Layout.Row = 1;
            
            lblTitle = uilabel(pnlHeader, 'Text', 'Image Enhancement Studio', ...
                'FontSize', 18, 'FontWeight', 'bold', 'FontColor', cTextDark, ...
                'Position', [15 10 400 30]);

            % Left side grid
            gridBody = uigridlayout(obj.Grid, [1, 2]);
            gridBody.Layout.Row = 2;
            gridBody.ColumnWidth = {360, '1x'};
            gridBody.Padding = [0 0 0 0];
            gridBody.ColumnSpacing = 12;

            pnlControls = uipanel(gridBody, 'Title', ' Control Center ', ...
                'FontWeight', 'bold', 'FontSize', 12, 'ForegroundColor', cText, ...
                'BackgroundColor', cPanel, 'BorderType', 'line', 'BorderColor', [0.35 0.40 0.48]);

            gridCtrl = uigridlayout(pnlControls, [10, 2]);
            gridCtrl.BackgroundColor = cPanel;
            gridCtrl.RowHeight = {32, 32, 22, 32, 22, 32, 22, 32, 42, 32};
            gridCtrl.ColumnWidth = {130, '1x'};
            gridCtrl.RowSpacing = 6;
            gridCtrl.Padding = [12 12 12 12];

            % Image Selection
            obj.BtnSelectInput = uibutton(gridCtrl, 'push', 'Text', 'Pilih Input', ...
                'BackgroundColor', cSecondary, 'FontColor', 'white', 'FontWeight', 'bold');
            obj.LblInput = uilabel(gridCtrl, 'Text', 'Belum ada citra input', ...
                'FontColor', cMuted, 'HorizontalAlignment', 'left', 'FontSize', 10);
            
            obj.BtnSelectRef = uibutton(gridCtrl, 'push', 'Text', 'Pilih Referensi', ...
                'BackgroundColor', cSecondary, 'FontColor', 'white', 'FontWeight', 'bold');
            obj.LblReference = uilabel(gridCtrl, 'Text', 'Belum ada citra referensi', ...
                'FontColor', cMuted, 'HorizontalAlignment', 'left', 'FontSize', 10);

            % Method Selector
            lblM = uilabel(gridCtrl, 'Text', 'Metode Enhancement', 'FontWeight', 'bold', 'FontColor', cText);
            lblM.Layout.Column = [1 2];
            obj.MenuMethod = uidropdown(gridCtrl, ...
                'Items', {'Intensity Transformation', 'Histogram Equalization', 'Histogram Matching', 'Image Filtering'}, ...
                'BackgroundColor', cDropDown, 'FontColor', 'white');
            obj.MenuMethod.Layout.Column = [1 2];

            % Type / Kernel Selector
            lblK = uilabel(gridCtrl, 'Text', 'Jenis / Kernel Options', 'FontWeight', 'bold', 'FontColor', cText);
            lblK.Layout.Column = [1 2];
            obj.MenuType = uidropdown(gridCtrl, ...
                'Items', {'Negative', 'Log', 'Gamma', 'Contrast'}, ...
                'BackgroundColor', cDropDown, 'FontColor', 'white');
            obj.MenuType.Layout.Column = [1 2];

            % Parameter Input
            obj.LblParam = uilabel(gridCtrl, 'Text', 'Parameter Dynamic', 'FontWeight', 'bold', 'FontColor', cText);
            obj.LblParam.Layout.Column = [1 2];
            obj.TxtParam = uieditfield(gridCtrl, 'text', 'Value', '0.5', ...
                'BackgroundColor', 'white', 'FontColor', cTextDark);
            obj.TxtParam.Layout.Column = [1 2];
            obj.BtnProcess = uibutton(gridCtrl, 'push', 'Text', 'PROSES ENHANCEMENT', ...
                'BackgroundColor', cPrimary, 'FontColor', 'white', 'FontWeight', 'bold', 'FontSize', 13);
            obj.BtnProcess.Layout.Column = [1 2];

            obj.BtnReset = uibutton(gridCtrl, 'push', 'Text', 'Reset UI & Data', ...
                'BackgroundColor', [0.92 0.94 0.96], 'FontColor', cTextDark, 'FontWeight', 'bold');
            obj.BtnReset.Layout.Column = [1 2];

            % Right side grid
            gridImage = uigridlayout(gridBody, [2, 2]);
            gridImage.RowHeight = {'1x', 140};
            gridImage.ColumnWidth = {'1x', '1x'};
            gridImage.RowSpacing = 12;
            gridImage.ColumnSpacing = 12;

            % Image Display Panels
            pnlAxIn = uipanel(gridImage, 'Title', ' Citra Masukan (Input) ', ...
                'FontWeight', 'bold', 'ForegroundColor', cText, 'BackgroundColor', cPanel);
            pnlAxIn.Layout.Row = 1; pnlAxIn.Layout.Column = 1;
            
            gridAxIn = uigridlayout(pnlAxIn, [1, 1]);
            gridAxIn.Padding = [5 5 5 5];
            obj.AxInput = uiaxes(gridAxIn, 'BackgroundColor', [0.10 0.12 0.15], ...
                'XColor', 'none', 'YColor', 'none');

            pnlAxOut = uipanel(gridImage, 'Title', ' Citra Hasil (Output) ', ...
                'FontWeight', 'bold', 'ForegroundColor', cText, 'BackgroundColor', cPanel);
            pnlAxOut.Layout.Row = 1; pnlAxOut.Layout.Column = 2;
            
            gridAxOut = uigridlayout(pnlAxOut, [1, 1]);
            gridAxOut.Padding = [5 5 5 5];
            obj.AxOutput = uiaxes(gridAxOut, 'BackgroundColor', [0.10 0.12 0.15], ...
                'XColor', 'none', 'YColor', 'none');

            % Analysis Feature Panels
            pnlFtIn = uipanel(gridImage, 'Title', ' Analysis Fitur Input ', ...
                'FontWeight', 'bold', 'ForegroundColor', cText, 'BackgroundColor', cPanel);
            pnlFtIn.Layout.Row = 2; pnlFtIn.Layout.Column = 1;
            
            gridFtIn = uigridlayout(pnlFtIn, [1, 1]);
            gridFtIn.Padding = [5 5 5 5];
            obj.TxtInputFeatures = uitextarea(gridFtIn, 'Editable', 'off', ...
                'BackgroundColor', [0.98 0.99 1.00], 'FontColor', cTextDark, 'FontWeight', 'bold');

            pnlFtOut = uipanel(gridImage, 'Title', ' Analysis Fitur Output ', ...
                'FontWeight', 'bold', 'ForegroundColor', cText, 'BackgroundColor', cPanel);
            pnlFtOut.Layout.Row = 2; pnlFtOut.Layout.Column = 2;
            
            gridFtOut = uigridlayout(pnlFtOut, [1, 1]);
            gridFtOut.Padding = [5 5 5 5];
            obj.TxtOutputFeatures = uitextarea(gridFtOut, 'Editable', 'off', ...
                'BackgroundColor', [0.98 0.99 1.00], 'FontColor', cTextDark, 'FontWeight', 'bold');

            % Status Bar Panel
            pnlStatus = uipanel(obj.Grid, 'BackgroundColor', cCard, 'BorderType', 'none');
            pnlStatus.Layout.Row = 3;
            
            obj.LblStatus = uilabel(pnlStatus, ...
                'Text', ' Ready. Pilih citra input untuk memulai.', ...
                'FontColor', cTextDark, 'FontWeight', 'bold', 'Position', [10 4 1000 22]);
        end
    end
end