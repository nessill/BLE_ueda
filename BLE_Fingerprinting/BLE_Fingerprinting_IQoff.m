

% parameter setup
%Fs = 3.125e6;

%Fs=8e6;%後々コード変えます
snr = 40;
preamble_detect = 1;
interp_fac = 32;
n_partition = 250;
fingerprint_size = 25;

IQ_compair=zeros(20,6); % 2/7追加.１行目は真のI、２行目は真のQ、３行目は推定I、４行目は推定Q
% ５行目はI誤差、６行目はQ誤差

tic
fingerprint_all = zeros(20,fingerprint_size);
for i = 1:20
    signalpath='BLE_Data_IQoff/';
    signalname='BLEsignal';
    signalnum=pad(string(i),6,"left",'0');
    signalname=append(signalpath,signalname, signalnum, '.mat');
    %clear signalform_IQFreqWgnadd
    load(signalname,'re_waveform_IQoff','im_waveform_IQoff','Fs','I_offset','Q_offset')
    signal=re_waveform_IQoff+1j*im_waveform_IQoff;
    signal(1:10,:);
    %waveform_FIQ = waveform_FIQ(1:end-12);
    %sz4=size(waveform_FIQ);

    % Physical layer fingerprinting
    [fingerprint,bits] = BLE_Fingerprint(signal,snr,Fs,preamble_detect,interp_fac,n_partition);
    fingerprint_all(i,:) = fingerprint;
    
    IQ_compair(i,1)=I_offset;
    IQ_compair(i,2)=Q_offset;
    IQ_compair(i,3)=fingerprint(1,6);
    IQ_compair(i,4)=fingerprint(1,7);
    IQ_compair(i,5)=abs(I_offset)-abs(fingerprint(1,6));
    IQ_compair(i,6)=abs(Q_offset)-abs(fingerprint(1,7));
    mean_Ierr=sum(IQ_compair(1:20,3))/20;
    mean_Qerr=sum(IQ_compair(1:20,4))/20;
end
Ierr_mean=mean(abs(IQ_compair(1:20,5)));
Qerr_mean=mean(abs(IQ_compair(1:20,6))); 
IQ_compair=round(IQ_compair,5)
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