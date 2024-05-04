clc; clear all; close all;
f=1000;
fs = 16000;
t=[0:1/fs:1/fs*1023];
y0 = cos(2*pi*f*t);
y1 = exp(1i*2*pi*f*t);
y2 = hilbert(y0);

figure
subplot(2,2,1)
plot(t,real(y1),t,real(y2));
xlabel("real")
subplot(2,2,2)
plot(t,imag(y1),t,imag(y2));
xlabel("imag")


diff_real = real(y1) - real(y2);
diff_image = imag(y1) - imag(y2);
subplot(2,2,3)
plot(t,diff_real);
xlabel("real dif")
subplot(2,2,4)
plot(t,diff_image);
xlabel("imag dif")