clc;clear all;close all;

%read audio data file from M260C annular array
filename = './sound_data/2khz_90deg.pcm';
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
% figure
% plot(audioData_reshape(1,:)); %channel 1 after reshape

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

%transform to analytic signal
%this is for manipulating phase
audio_window = hilbert(audio_window.').';

%calculate covarience matrix
%Rx = (audio_window*audio_window')./sample_num;
Rx = (audio_window*audio_window');

%prepare mic vector
r_mic = 0.035;
Num_mic = 6;

%accroding to real mic placement
Mic_vec = [r_mic*cosd(360*(0:Num_mic-1)/Num_mic); r_mic*sind(360*(0:Num_mic-1)/Num_mic); zeros(1,Num_mic)];


%localization
Azimuth = 0:360;
Elevation = 0:90;
Power = zeros(length(Azimuth),length(Elevation));
for Az = 1:length(Azimuth)
    for Ele = 1:length(Elevation)
        Ang_vec = -[sind(Elevation(Ele))*cosd(Azimuth(Az)); sind(Elevation(Ele))*sind(Azimuth(Az)); cosd(Elevation(Ele))];
        Ang_vec = (1/c)*Ang_vec.'*Mic_vec;
        W = exp(-1j*2*pi*f*Ang_vec).'; %calculate ang weight(ie. sample delay at each mic cause by incident angle)
        Power(Az,Ele) = W'*Rx*W;
    end
end

%normalize
Power = 20*log10(abs(Power)/max(max(abs(Power))));

%visualize

figure
mesh(Azimuth,Elevation,Power')
xlabel('Azimuth')
ylabel('Elevation')
caxis([-0.5,0])
colormap(jet);

[MA,IA]=max(Power); % max value of each column & row index of each column
[mVal,mInd]=max(MA); % max value of matrix & column index of that value
maxRow=IA(mInd);
maxCol=mInd;
target = [maxRow,maxCol]


%%
%corrrelation part, calculating sample difference for mic, which indicates
%the time delay between two mic sig array
%Cor_Array = xcorr(audio_window(2,:),audio_window(3,:));
[Cor_Array,lags] = xcorr(audio_window(1,:),audio_window(4,:));
[Value,Cor_Index] = max(Cor_Array); 
sample_delay =lags(Cor_Index);

