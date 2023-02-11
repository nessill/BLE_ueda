% The example reads 10 BLE packets received over the air from the same device
% and estimate their hardware imperfection fingerprints

% parameter setup
Fs = 3.125e6;
snr = 40;
preamble_detect = 1;
interp_fac = 32;
n_partition = 250;
fingerprint_size = 25;

% Constellation Diagram
I = real(waveform); % I成分
Q = imag(waveform); % Q成分
hold on; % 複数のグラフを同じFigureにプロットするためにhold onを使用する
scatter(I, Q, '+', 'b'); % scatter plotを作成 blue
hold off;  % hold onの状態を解除する
xlabel('I'); ylabel('Q'); % x軸とy軸にラベルを付ける

tic
fingerprint_all = zeros(20,fingerprint_size);
for i = 1:20
    % Reading the file including the signal
    samplefilepath = sprintf('Example_Data/%d',i);
    fid = fopen(samplefilepath, 'r');
    [signal, ~] = fread(fid, 'float');
    fclose(fid);
    signal = reshape(signal, 2, []).';
    signal = signal(:,1) + 1i * signal(:,2);
    signal(1:10,:);
    
    signal = signal(1:end-12);
    
    % Physical layer fingerprinting
    [fingerprint,bits] = BLE_Fingerprint(signal,snr,Fs,preamble_detect,interp_fac,n_partition);
    fingerprint_all(i,:) = fingerprint;
end
toc       
Footer
© 2023 GitHub, Inc.
Footer navigation
Terms
Privacy
