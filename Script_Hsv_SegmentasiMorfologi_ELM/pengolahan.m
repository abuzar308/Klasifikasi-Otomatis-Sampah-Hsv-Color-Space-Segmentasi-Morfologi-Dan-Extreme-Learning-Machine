clc; clear; close all;

%%% Proses Pelatihan
% Menentukan lokasi folder data latih
nama_folder = 'data latih';
% Baca file yang berformat PNG
nama_file = dir(fullfile(nama_folder,'*.png'));
% Hitung jumlah file yang dibaca
jumlah_file = numel(nama_file);
% Inisialisasi variabel ciri
ciri = zeros(jumlah_file,5);
kelas = zeros(jumlah_file,1);
% Proses ekstraksi ciri 
for n = 1:jumlah_file
    % Baca file citra
    Img = imread(fullfile(nama_folder,nama_file(n).name));
    % Konversi ruang warna citra rgb ke hsv
    hsv = rgb2hsv(Img);
    % Ekstrak komponen v
    v = hsv(:,:,3);
    % Lakukan thresholding terhadap komponen value, sesuaikan dengan Versi
    % Matlab Anda untuk script im2bw
    bw = im2bw(v,0.9);
    % Proses median filtering
    bw = medfilt2(~bw,[5,5]);
    % Proses operasi morfologi filling holes
    bw = imfill(bw,'holes');
    % Proses operasi morfologi area opening
    bw = bwareaopen(bw,1000);
    % Proses operasi morfologi closing
    str = strel('square',10);
    bw = imdilate(bw,str);
    % Proses ekstraksi ciri citra biner hasil thresholding
    s  = regionprops(bw, 'all');
    area = cat(1, s.Area);
    perimeter = cat(1, s.Perimeter);
    eccentricity = cat(1, s.Eccentricity);
    mayor = cat(1, s.MajorAxisLength);
    minor = cat(1, s.MinorAxisLength);
    % Susun variabel ciri
    ciri(n,1) = max(area);
    ciri(n,2) = max(perimeter);
    ciri(n,3) = max(eccentricity);
    ciri(n,4) = max(mayor);
    ciri(n,5) = max(minor);
end

% Menetapkan kelas target latih
% 1:10 maksudnya adalah Citra ke 1 s.d citra ke 10
kelas(1:10) = 1;
kelas(11:20) = 2;
kelas(21:30) = 3;

% Susun data latih
data_training = [kelas,ciri];
% Susun parameter2 elm
NumberofInputNeurons = 5;
NumberofHiddenNeurons = 60;
% bobot diinisialisasi secara random
% InputWeight = rand(NumberofHiddenNeurons,NumberofInputNeurons)*2-1;
% BiasofHiddenNeurons = rand(NumberofHiddenNeurons,1);
% bobot ditetapkan di awal
load bobot_awal
Elm_Type = 1;
ActivationFunction  = 'sin';

% pelatihan model elm
[~, ~, ~, ~, predicted_class] = ...
    ELM(data_training, data_training, ...
    InputWeight, BiasofHiddenNeurons, Elm_Type,...
    ActivationFunction);

% Hitun akurasi pelatihan
[~,n] = find(predicted_class==kelas);
akurasi = numel(n)/jumlah_file*100;
disp(['akurasi pelatihan = ',num2str(akurasi),'%'])

% menyimpan variabel2 pelatihan
save('net','data_training','InputWeight','BiasofHiddenNeurons',...
    'Elm_Type','ActivationFunction')
clc;
%%% Proses Pengujian
% Menentukan lokasi folder data uji
nama_folder = 'data uji';
% Baca file yang berformat PNG
nama_file = dir(fullfile(nama_folder,'*.png'));
% Hitung jumlah file
jumlah_file = numel(nama_file);
% Inisialisasi variabel ciri
ciri = zeros(jumlah_file,5);
kelas = zeros(jumlah_file,1);
% Proses ekstraksi ciri 
for n = 1:jumlah_file
    % Baca file citra
    Img = imread(fullfile(nama_folder,nama_file(n).name));
    % Konversi ruang warna citra rgb to hsv
    hsv = rgb2hsv(Img);
    % Ekstrak komponen v
    v = hsv(:,:,3);
    % Proses thresholding terhadap komponen value, sesuaikan script im2bw
    % dengan versi Matlab anda
    bw = im2bw(v,0.9);
    % Proses median filtering
    bw = medfilt2(~bw,[5,5]);
    % Proses operasi morfologi filling holes
    bw = imfill(bw,'holes');
    % Proses operasi morfologi area opening
    bw = bwareaopen(bw,1000);
    % Proses operasi morfologi closing
    str = strel('square',10);
    bw = imdilate(bw,str);
    % Proses ekstraksi ciri citra biner hasil thresholding
    s  = regionprops(bw, 'all');
    area = cat(1, s.Area);
    perimeter = cat(1, s.Perimeter);
    eccentricity = cat(1, s.Eccentricity);
    mayor = cat(1, s.MajorAxisLength);
    minor = cat(1, s.MinorAxisLength);
    % Susun variabel ciri
    ciri(n,1) = max(area);
    ciri(n,2) = max(perimeter);
    ciri(n,3) = max(eccentricity);
    ciri(n,4) = max(mayor);
    ciri(n,5) = max(minor);
end

% Tetap kelas target uji
kelas(1:4) = 1;
kelas(5:6) = 2;
kelas(7:12) = 3;

% Susun data uji
data_testing = [kelas,ciri];

% pengujian model elm
[~, ~, ~, ~, predicted_class] = ...
    ELM(data_training, data_testing, ...
    InputWeight, BiasofHiddenNeurons, Elm_Type,...
    ActivationFunction);

% Hitung akurasi pelatihan
[~,n] = find(predicted_class==kelas);
akurasi = numel(n)/jumlah_file*100;
disp(['akurasi pengujian = ',num2str(akurasi),'%'])

% Tampilkan data yang gagal diklasifikasikan
fprintf('\nSample yang gagal diklasifikasikan:\n');
jumlah_salah = 0;
for i = 1:jumlah_file
    if predicted_class(i) ~= kelas(i)
        fprintf('  %s => Prediksi: %d | Target: %d\n', ...
            nama_file(i).name, predicted_class(i), kelas(i));
        jumlah_salah = jumlah_salah + 1;
    end
end
fprintf('Total gagal klasifikasi: %d dari %d sampel.\n', jumlah_salah, jumlah_file);

% Visualisasi Akurasi Per Kelas
% Menghitung jumlah benar per kelas
unique_kelas = unique(kelas);
jumlah_kelas = numel(unique_kelas);
akurasi_per_kelas = zeros(jumlah_kelas,1);

for k = 1:jumlah_kelas
    idx = find(kelas == unique_kelas(k));
    benar = sum(predicted_class(idx) == kelas(idx));
    total = numel(idx);
    akurasi_per_kelas(k) = benar / total * 100;
end

% Tampilkan grafik akurasi per kelas
figure;
bar(unique_kelas, akurasi_per_kelas);
title('Akurasi Pengujian per Kelas');
xlabel('Kelas');
ylabel('Akurasi (%)');
ylim([0 110]);
grid on;

% Grafik Perbandingan Prediksi vs Aktual
figure;
plot(1:jumlah_file, kelas, 'b-o', 'LineWidth', 2); hold on;
plot(1:jumlah_file, predicted_class, 'r--x', 'LineWidth', 2);
ylim([0.5 3.5]);
yticks([1 2 3]);
yticklabels({'Botol Kaleng', 'Kertas', 'Botol Plastik'});
xlabel('Nomor Sampel Uji');
ylabel('Kelas');
title('Grafik Prediksi vs Kelas Aktual');
legend('Kelas Aktual', 'Kelas Prediksi', 'Location', 'northwest');
grid on;
