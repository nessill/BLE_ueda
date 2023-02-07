

% parameter setup
%Fs = 3.125e6;

%Fs=8e6;%後々コード変えます
snr = 40;
preamble_detect = 1;
interp_fac = 32;
n_partition = 250;
fingerprint_size = 25;

tic
fingerprint_all = zeros(20,fingerprint_size);
for i = 1:20
    signalpath='BLE_Signal_Data/';
    signalname='BLEsignal';
    signalnum=pad(string(i),6,"left",'0');
    signalname=append(signalpath,signalname, signalnum, '.mat');
    %clear signalform_IQFreqWgnadd
    load(signalname,'re_waveform_FIQ','im_waveform_FIQ','Fs')
    signal=re_waveform_FIQ+1j*im_waveform_FIQ;
    signal(1:10,:);
    %waveform_FIQ = waveform_FIQ(1:end-12);
    %sz4=size(waveform_FIQ);

    % Physical layer fingerprinting
    [fingerprint,bits] = BLE_Fingerprint(signal,snr,Fs,preamble_detect,interp_fac,n_partition);
    fingerprint_all(i,:) = fingerprint;
    disp(fingerprint_all)% 追加1/20 yuga
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