% phaseOffset,cfoOffsetと３ｄBのノイズを追加したBLE信号を生成

% Specify the input parameters for generating Bluetooth LE waveform
numPackets = 10;    % Number of packets to generate
sps = 16;           % Samples per symbol
messageLen = 200;  % Length of message in bits, 25oct*8bits
phyMode = 'LE1M';   % Select one mode from the set {'LE1M','LE2M','LE500K','LE125K'};
channelBW = 2e6;    % Channel spacing (Hz) as per standard
symbolRate=1e6;     % 'LE1M'のためシンボルレート1e6

% 追加 1/31　
% 位相（I/Q)オフセットと周波数オフセットの値の作成
phaseOffset = 30;  % 位相オフセットの角度
freqOffsetmin=1e3; % 周波数オフセット最小値
freqOffsetmax=10e3; % 周波数オフセット最大値
%freqOffset = rand * 5e3; % BLE規格の周波数オフセットの限界値150e3（これを超すとBluetoothの規格外）
freqOffset=randi([freqOffsetmin,freqOffsetmax],1,numPackets); % 周波数オフセット配列の生成.1k~100kHzでnumPacketsの数だけ作る.

% Define symbol rate based on the PHY mode
%{
if any(strcmp(phyMode,{'LE1M','LE500K','LE125K'}))
    symbolRate = 1e6;
else
    symbolRate = 2e6;
end
%}


% Create a spectrum analyzer object
specAn = dsp.SpectrumAnalyzer('SpectrumType','Power density');
specAn.SampleRate = symbolRate*sps;

% Create a time scope object
timeScope = timescope('SampleRate', symbolRate*sps,'TimeSpanSource','Auto',...
     'ShowLegend',true);

% Loop over the number of packets, generating a Bluetooth LE waveform and
% plotting the waveform spectrum
rng default;
for packetIdx = 1:numPackets % numPackets回繰り返す
    message = randi([0 1],messageLen,1);    % Message bits generation
    %channelIndex = randi([0 39],1,1);          % Channel index decimal value
    channelIndex=39; % 01/27更新　アドバタイズチャネル37~39のうち一つを選ぶ　yuga　
    % （追記）ch38は通常2426MHzだが2478MHz付近にスペクトルのピークがあった.2402MHzから順にchが増えていく仕様らしい.
    % Default access address for periodic advertising channels
    accessAddress = [1 0 0 0 1 1 1 0 1 0 0 0 1 0 0 1 1 0 1 1 1 1 1 0 1 1 0 1 0 1 1 0].';%4oct

    %{
    if(channelIndex >=37)
        % Default access address for periodic advertising channels
        %定期的なアドバタイジングチャネルのためのデフォルトのアクセスアドレス
        accessAddress = [0 1 1 0 1 0 1 1 0 1 1 1 1 1 0 1 1 0 0 ...
                            1 0 0 0 1 0 1 1 1 0 0 0 1]';
    else
        % Random access address for data channels
        % Ideally, this access address value should meet the requirements
        % specified in Section 2.1.2 of volume 6 of the Bluetooth Core
        % Specification.
        %{
        データチャネル用ランダムアクセスアドレス
        このアクセスアドレスの値は、Bluetooth Core Volume 6のSection 2.1.2で規定された要件を満たすことが理想的です。
        このアクセスアドレスの値は、Bluetooth Coreの第6巻のセクション2.1.2で指定された要件を満たすことが理想的です。
        仕様書に規定されている要件を満たすことが理想的です。
        %}
        accessAddress = [0 0 0 0 0 0 0 1 0 0 1 0 0 ...
            0 1 1 0 1 0 0 0 1 0 1 0 1 1 0 0 1 1 1]'
    end
    %}
    waveform = bleWaveformGenerator(message,...
                                    'Mode',phyMode,...
                                    'SamplesPerSymbol',sps,...
                                    'ChannelIndex',channelIndex,...
                                    'AccessAddress',accessAddress);
    
    %{
    周波数オフセットの追加を関数を用いて行いたかったが,スペクトラムが移動しなかった.余裕のある方は修正されたし.
    %pfo = comm.PhaseFrequencyOffset(PhaseOffset=phaseOffset, FrequencyOffset=freqOffset(1,i));
    %waveform_IQFreqadd = pfo(waveform); %位相周波数オフセットの追加
    %}
    % 周波数オフセットの追加修正版.関数を使わず計算式のみで行った.
    t=(0:length(waveform)-1)/specAn.SampleRate;
    waveform_IQFreqadd=waveform.*exp(1j*2*pi*freqOffset(1,packetIdx)*t).';
    waveform_IQFreqWgnadd = awgn(waveform_IQFreqadd, 0, 'measured');% 3dB付加

    % パスを指定しそこに信号配列ファイルを追加
    numfile=num2str(packetIdx, '%06d');
    filename=append("BLEsignal", numfile);
    % pass = '/home/ueda21/Desktop/blephytracking/BLE_Fingerprinting/BLE_Signal_Data'; % パスの指定
    pass = 'D:\OneDrive - 岐阜大学\2023卒論\blephytracking2\BLE_Fingerprinting\BLE_Signal_Data'; % パスの指定
    filenamepass=fullfile(pass,filename);
    save(filenamepass,'waveform_IQFreqWgnadd','freqOffset', '-regexp','x'); % BLE38chのCFO,I/Qオフセット,ホワイトガウスノイズつきのBLE38chの信号を保存
    
    specAn.FrequencyOffset = channelBW*channelIndex;
    specAn.Title = ['Spectrum of ',phyMode,' Waveform for Channel Index = ', '39'];
    
    tic
    while toc < 0.5 % To hold the spectrum for 0.5 seconds
        specAn(waveform,waveform_IQFreqadd,waveform_IQFreqWgnadd);
    end

    % Plot the generated waveform
    timeScope.Title = ['Bluetooth LE ',phyMode,' Waveform for Channel Index = ', '39'];
    timeScope(waveform,waveform_IQFreqadd,waveform_IQFreqWgnadd);
    
end
I = real(waveform); % I成分
Q = imag(waveform); % Q成分
I2 = real(waveform_IQFreqadd);
Q2 = imag(waveform_IQFreqadd);
I3 = real(waveform_IQFreqWgnadd);
Q3 = imag(waveform_IQFreqWgnadd);
figure;
hold on; % 複数のグラフを同じFigureにプロットするためにhold onを使用する
scatter(I, Q, '+', 'b'); % scatter plotを作成 blue
scatter(I2, Q2, '.','r'); % scatter plotを作成 red
scatter(I3, Q3, '.','g'); % scatter plotを作成 green
hold off;  % hold onの状態を解除する
xlabel('I'); ylabel('Q'); % x軸とy軸にラベルを付ける