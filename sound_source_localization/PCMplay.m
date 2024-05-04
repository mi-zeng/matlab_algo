clc;clear all;close all;

filename = 'xu20240418.pcm';
%filename = './sound_data/1khz_60deg.pcm';
sampleRate = 16000;
bitDepth = 16;
 
% ��ȡPCM�ļ�Ϊ����
fid = fopen(filename, 'rb');
formatSpec = sprintf('%dB', bitDepth);
audioData = fread(fid, Inf, 'int16')'; % ��ȡ�������ݣ�ת��Ϊ������
fclose(fid);

% ����������ƥ������ĸ�ʽ
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

% ����һ��audioplayer����
player = audioplayer(audioData_reshape(1,:)./3000, sampleRate);

% ������Ƶ
play(player);