clc; clear; close all;

%%% Proses Pelatihan Data Citra
% Menentukan folder data latih
nama_folder = 'data latih';

% Baca File Citra dengan Format PNG
nama_file = dir(fullfile(nama_folder,'*.png'));

% Count Jumlah File
jumlah_file = numel(nama_file);

% Menentukan variabel ciri
ciri = zeros(jumlah_file,5);
kelas = zeros(jumlah_file,1);

% Ekstasi Ciri pada semua citra
for n = 1:jumlah_file
    % Baca file citra
    Img = imread(fullfile(nama_folder,nama_file(n).name));
    % Konversi rgb to hsv
    hsv = rgb2hsv(Img);
    % Ekstrak komponen v
    v = hsv(:,:,3);
    % Proses thresholding terhadap komponen v, sesuaikan dengan versi Matlab Anda
    bw = im2bw(v,0.9);
    % proses median filtering
    bw = medfilt2(~bw,[5,5]);
    
    % proses operasi morfologi filling holes
    bw = imfill(bw,'holes');
    % Proses operasi morfologi area opening
    bw = bwareaopen(bw,1000);
    % Proses operasi morfologi closing
    str = strel('square',10);
    bw = imdilate(bw,str);
    % Proses ekstraksi ciri terhadap citra biner hasil thresholding
    s  = regionprops(bw, 'all');
    area = cat(1, s.Area);
    perimeter = cat(1, s.Perimeter);
    eccentricity = cat(1, s.Eccentricity);
    mayor = cat(1, s.MajorAxisLength);
    minor = cat(1, s.MinorAxisLength);
    % menyusun variabel ciri
    ciri(n,1) = max(area);
    ciri(n,2) = max(perimeter);
    ciri(n,3) = max(eccentricity);
    ciri(n,4) = max(mayor);
    ciri(n,5) = max(minor);
end

% tetapkan kelas target latih
kelas(1:10) = 1;
kelas(11:20) = 2;
kelas(21:30) = 3;

% susun data latih
data_training = [kelas,ciri];
% susun parameter2 elm
NumberofInputNeurons = 5;
NumberofHiddenNeurons = 60;
% bobot diinisialisasi secara random
% InputWeight = rand(NumberofHiddenNeurons,NumberofInputNeurons)*2-1;
% BiasofHiddenNeurons = rand(NumberofHiddenNeurons,1);
% bobot ditetapkan di awal
load bobot_awal
Elm_Type = 1;
ActivationFunction  = 'sin';

% pelatihan elm
[~, ~, ~, ~, predicted_class] = ...
    ELM(data_training, data_training, ...
    InputWeight, BiasofHiddenNeurons, Elm_Type,...
    ActivationFunction);

% menghitung akurasi pelatihan
[~,n] = find(predicted_class==kelas);
akurasi = numel(n)/jumlah_file*100;
disp(['akurasi pelatihan = ',num2str(akurasi),'%'])

% menyimpan variabel2 pelatihan
save('net','data_training','InputWeight','BiasofHiddenNeurons',...
    'Elm_Type','ActivationFunction')
clc;
%%% Proses Pengujian Data
%  lokasi folder data uji
nama_folder = 'data uji';
% baca file yang berformat PNG
nama_file = dir(fullfile(nama_folder,'*.png'));
% hitung jumlah file
jumlah_file = numel(nama_file);
% tentukan  variabel ciri
ciri = zeros(jumlah_file,5);
kelas = zeros(jumlah_file,1);
% proses ekstraksi ciri seluruh citra
for n = 1:jumlah_file
    % baca file citra
    Img = imread(fullfile(nama_folder,nama_file(n).name));
    % konversi ruang warna citra rgb to hsv
    hsv = rgb2hsv(Img);
    % ekstrak komponen v
    v = hsv(:,:,3);
    % proses thresholding terhadap komponen v, sesuaikan dengan versi Matlab anda
    bw = im2bw(v,0.9);
    % proses median filtering
    bw = medfilt2(~bw,[5,5]);
    % proses operasi morfologi filling holes
    bw = imfill(bw,'holes');
    % proses operasi morfologi area opening
    bw = bwareaopen(bw,1000);
    % proses operasi morfologi closing
    str = strel('square',10);
    bw = imdilate(bw,str);
    % proses ekstraksi ciri terhadap citra biner hasil thresholding
    s  = regionprops(bw, 'all');
    area = cat(1, s.Area);
    perimeter = cat(1, s.Perimeter);
    eccentricity = cat(1, s.Eccentricity);
    mayor = cat(1, s.MajorAxisLength);
    minor = cat(1, s.MinorAxisLength);
    % susun variabel ciri
    ciri(n,1) = max(area);
    ciri(n,2) = max(perimeter);
    ciri(n,3) = max(eccentricity);
    ciri(n,4) = max(mayor);
    ciri(n,5) = max(minor);
end

% tetapkan kelas target uji
kelas(1:4) = 1;
kelas(5:6) = 2;
kelas(7:12) = 3;

% susun data uji
data_testing = [kelas,ciri];

% pengujian elm
[~, ~, ~, ~, predicted_class] = ...
    ELM(data_training, data_testing, ...
    InputWeight, BiasofHiddenNeurons, Elm_Type,...
    ActivationFunction);

% hitung akurasi pelatihan
[~,n] = find(predicted_class==kelas);
akurasi = numel(n)/jumlah_file*100;
disp(['akurasi pengujian = ',num2str(akurasi),'%'])

% Menampilkan data yang gagal diklasifikasikan
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

