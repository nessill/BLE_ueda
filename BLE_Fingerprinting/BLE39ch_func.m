% Generated by MATLAB(R) 9.13 (R2022b) and Bluetooth Toolbox 1.1 (R2022b).
% Generated on: 04-Feb-2023 20:59:52

%% Bluetooth Low Energy 波形を生成しています
% Bluetooth Low Energy 構成
sps = 8; % 
symbolRate = 1000000;
% input bit source:
in = randi([0, 1], 200, 1);


% 生成
waveform = bleWaveformGenerator(in, 'Mode', 'LE1M', ...
    'SamplesPerSymbol', 8, ...
    'ChannelIndex', 39, ...
    'AccessAddress', [1 0 0 0 1 1 1 0 1 0 0 0 1 0 0 1 1 0 1 1 1 1 1 0 1 1 0 1 0 1 1 0]');

Fs = sps * symbolRate; 								 % 波形のサンプル レートを Hz 単位で指定

% 周波数オフセットの追加修正版.関数を使わず計算式のみで行った.
% 周波数オフセットの値の作成
fcfomin=3000000; % 周波数オフセット最小値
fcfomax=3000000; % 周波数オフセット最大値% BLE規格の周波数オフセットの限界値150e3（これを超すとBluetoothの規格外）
fcfo=fcfomin + (fcfomax-fcfomin)*rand; % 周波数オフセット配列の生成.1k~100kHzでだけ作る.
t=(0:length(waveform)-1)/Fs;
cfo=exp(1j*2*pi*fcfo*t);
waveformF=waveform.*cfo.';
% I/Qオフセットの定義
I_offset=1;
Q_offset=2;
waveform_FIQ=waveformF+I_offset+1j*Q_offset;
% I/Q不均衡パラメータの定義
amp_imbalance = 0.9;
phase_imbalance = 0.05;

% I/Q不均衡を加える
I_imbalanced = real(waveform_FIQ) * amp_imbalance;
Q_imbalanced = (imag(waveform_FIQ) + phase_imbalance) * amp_imbalance;
waveform_FIQ=I_imbalanced+1j * Q_imbalanced;

% パスを指定しそこに信号配列ファイルを追加
numfile=num2str(1, '%06d');
filename=append("BLEsignal", numfile);
% pass = '/home/ueda21/Desktop/blephytracking/BLE_Fingerprinting/BLE_Signal_Data'; % パスの指定
pass = '/home/ueda21/Desktop/MatlabR2022b/bin/blephytracking2/BLE_Fingerprinting/BLE_Signal_Data'; % パスの指定
filenamepass=fullfile(pass,filename);
save(filenamepass, '-regexp','x'); % BLE38chのCFO,I/Qオフセット,ホワイトガウスノイズつきのBLE38chの信号を保存

waveform_FIQWgn = awgn(waveform_FIQ, 0.00, 'measured');% 3dB付加

%% 可視化
% Spectrum Analyzer
spectrum = spectrumAnalyzer('SampleRate', Fs);
spectrum(waveform);
release(spectrum);

% Constellation Diagram
constel = comm.ConstellationDiagram('ColorFading', true, ...
    'ShowTrajectory', 0, ...
    'ShowReferenceConstellation', false);
step(constel, waveform);

step(constel, waveform_FIQ);
release(constel);


% Eye Diagram
%eyediagram(waveform, 2* 8);

% Signal
timeScope = timescope('SampleRate', symbolRate*sps,'TimeSpanSource','Auto',...
    'ShowLegend',true);
% Plot the generated waveform
timeScope.Title = ['Bluetooth LE ',' Waveform for Channel Index = ', '39'];
timeScope(waveform);

% Constellation Diagram
I = real(waveform); % I成分
Q = imag(waveform); % Q成分
I2 = real(waveform_FIQ);
Q2 = imag(waveform_FIQ);
I3 = real(waveform_FIQWgn);
Q3 = imag(waveform_FIQWgn);
hold on; % 複数のグラフを同じFigureにプロットするためにhold onを使用する
scatter(I, Q, '+', 'b'); % scatter plotを作成 blue
scatter(I2, Q2, '.','r'); % scatter plotを作成 red
scatter(I3, Q3, '.','g'); % scatter plotを作成 green
hold off;  % hold onの状態を解除する
xlabel('I'); ylabel('Q'); % x軸とy軸にラベルを付ける