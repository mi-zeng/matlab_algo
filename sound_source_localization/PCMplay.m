clc;clear all;close all;

filename = 'xu20240418.pcm';
%filename = './sound_data/1khz_60deg.pcm';
sampleRate = 16000;
bitDepth = 16;
 
% 读取PCM文件为数组
fid = fopen(filename, 'rb');
formatSpec = sprintf('%dB', bitDepth);
audioData = fread(fid, Inf, 'int16')'; % 读取所有数据，转换为列向量
fclose(fid);

% 重塑数据以匹配所需的格式
audioData_reshape = reshape(audioData, 8, []).';
figure
plot(audioData(1,:));



%%
audio_track = audioData_reshape(:,1);
figure
plot(audio_track)

%frequency domain analyze
Y = fft(audio_track);
L = length(audio_track);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

figure
f = sampleRate*(0:(L/2))/L;
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%%

% 创建一个audioplayer对象
player = audioplayer(audioData_reshape(1,:)./3000, sampleRate);

% 播放音频
play(player);