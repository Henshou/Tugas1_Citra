function teks = fiturKeTeks(hasilAnalisis)
% FITURKETEKS  Mengubah hasil analisisCitra() menjadi teks multi-baris,
% siap ditampilkan ke komponen uilabel/uitextarea di GUI.

f = hasilAnalisis.fitur;
teks = sprintf('Min:%.1f  Max:%.1f  Mean:%.2f  Std:%.2f  Entropy:%.2f', ...
    f.minVal, f.maxVal, f.meanVal, f.stdVal, f.entropi);
end