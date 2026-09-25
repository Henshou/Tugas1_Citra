function histogram = makeHist(img)
%MAKEHIST Menghitung histogram 256 dari image input
%   Fungsi ini menyimpan frekuensi dari setiap nilai keabuan
%   yang disimpan dalam suatu histogram

    img = uint8(img);
    histogram = zeros(1, 256);

    [row, column] = size(img);

    for rowIndex = 1:row
        for columnIndex = 1:column
            histogram(img(rowIndex, columnIndex) + 1) = ...
                histogram(img(rowIndex, columnIndex) + 1) + 1;
        end
    end
end