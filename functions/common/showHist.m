function showHist(hasil, judul)
%SHOWHIST Summary of this function goes here
%   Detailed explanation goes here

    figure('Name', judul);

    if hasil.isColor
        subplot(3,1,1); bar(0:255, hasil.hist.R, 'r')
        title([judul ' - kanal R']); xlim([0 255]);

        subplot(3,1,2); bar(0:255, hasil.hist.G, 'g')
        title([judul ' - kanal G']); xlim([0 255]);

        subplot(3,1,3); bar(0:255, hasil.hist.B, 'b')
        title([judul ' - kanal B']); xlim([0 255]);
    else
        bar(0:255, hasil.hist);
        title(judul); xlim([0 255])
end