

% parameter setup
%Fs = 3.125e6;
Fs=16e6;
snr = 40;
preamble_detect = 1;
interp_fac = 32;
n_partition = 250;
fingerprint_size = 25;

tic
fingerprint_all = zeros(20,fingerprint_size);
for i = 1:10
    %signalpath='/home/ueda21/Desktop/MatlabR2022b/bin/blephytracking/BLE_Fingerprinting/BLESignal_Data/';
    signalpath='D:\OneDrive - 岐阜大学\2023卒論\blephytracking2\BLE_Fingerprinting\BLE_signal_Data\';
    signalname='BLEsignal';
    signalnum=pad(string(i),3,"left",'0');
    signalname=append(signalpath,signalname, signalnum, '.mat');
    %clear signalform_IQFreqWgnadd
    load(signalname,'waveform_IQFreqWgnadd')
    waveform_IQFreqWgnadd(1:10,:);
    waveform_IQFreqWgnadd = waveform_IQFreqWgnadd(1:end-12);
    sz4=size(waveform_IQFreqWgnadd);

    % Physical layer fingerprinting
    [fingerprint,bits] = BLE_Fingerprint(waveform_IQFreqWgnadd,snr,Fs,preamble_detect,interp_fac,n_partition);
    fingerprint_all(i,:) = fingerprint;
    disp(fingerprint_all        )% 追加1/20 yuga
end
%{
for i = 1:20

    % Reading the file including the signal
    samplefilepath = sprintf('Example_Data/%d',i);
    fid = fopen(samplefilepath, 'r');
    [signal, ~] = fread(fid, 'float');
    fclose(fid);
    signal = reshape(signal, 2, []).';
    disp(signal)
    sz1=size(signal)
    signal = signal(:,1) + 1i * signal(:,2);
    sz2=size(signal)
    signal(1:10,:);
    sz3=size(signal)
    signal = signal(1:end-12);
    sz4=size(signal)
    % Physical layer fingerprinting
    [fingerprint,bits] = BLE_Fingerprint(signal,snr,Fs,preamble_detect,interp_fac,n_partition);
    fingerprint_all(i,:) = fingerprint;
    disp(fingerprint_all        )% 追加1/20 yuga
    
end
%}
toc       