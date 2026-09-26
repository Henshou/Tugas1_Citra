function main
%MAIN Menjalankan aplikasi.

    rootFolder = fileparts(mfilename('fullpath'));
    addpath(fullfile(rootFolder, 'functions', 'common'));
    addpath(fullfile(rootFolder, 'functions', 'methods'));
    addpath(fullfile(rootFolder, 'GUI'));

    app = App(rootFolder);
end
