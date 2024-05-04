clc;clear all;close all;

%read audio data file from M260C annular array
filename = './sound_data/music_180deg_1.65m.pcm';
sampleRate = 16000;
bitDepth = 16;

%frequency assumed to be known and signal is narrow band limited
f = 2000;
c = 343;

% read PCM file as array
fid = fopen(filename, 'rb');
formatSpec = sprintf('%dB', bitDepth);
audioData = fread(fid, Inf, 'int16')';
fclose(fid);

% reshape array as 8 channels
audioData_reshape = reshape(audioData, 8, []);

%M260C mic's order for annular array is
%0бу=1 60бу=2 120бу=3 180бу=5 240бу=4 300бу=6 
%so swap row 4 and row 5 to set data in order
audioData_reshape([4,5],:)=audioData_reshape([5,4],:);
audioData_reshape = audioData_reshape((1:6),:);

%generally embeded system has limited memory
%so clip a 1024 window as sample (as a expotenial of 2 for FFT)
%6channel * 32bit/float *1024 float =  196,608bits
sample_num = 1024;
init = round(rand*length(audioData_reshape(1,:)));
audio_window = audioData_reshape(:,init:init+sample_num-1);

%%
%corrrelation part, calculating sample difference for mic, which indicates
%the time delay between two mic sig array
[Cor_Array,lags] = xcorr(audio_window(1,:),audio_window(4,:));
[Value,Cor_Index] = max(Cor_Array); 
sample_delay =lags(Cor_Index);

figure
hold on
plot(audio_window(1,:),'r')
plot(audio_window(4,:),'b')

figure
plot(lags,Cor_Array)

display(sample_delay);