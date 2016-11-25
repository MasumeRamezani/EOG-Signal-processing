clc;clear all;close all;
load ('saccade.mat');
Fs=1000;
L=length(data);
data=data(1:L/3);
L=L/3;
t=(0:L-1)./Fs;
%% low pass filter
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.01,0.08,1,110);
d=design(h,'equiripple'); %Lowpass FIR filter
data_LPF=filtfilt(d.Numerator,1,data); %zero-phase filtering
%% mean averege
windowSize = 100;
data_MAF=filter(ones(1,windowSize)/windowSize,1,data);  %Moving average filter
%% wavelet filter

[ca1,cd1]=dwt(data,'haar');
[ca2,cd2]=dwt(ca1,'haar');
[ca3,cd3]=dwt(ca2,'haar');
[ca4,cd4]=dwt(ca3,'haar');
n=length(ca4);
V = max(var(ca4));
th=Square(2*V*log(n));
for i=1:n
if abs(ca4(i))<th
    ca4(i)=0;
end
end
a=length(cd3);
% b=length(ca3);
% cd3(a:b)=0;
ca2=idwt(ca3(1:a),cd3,'haar');
a=length(cd2);
% b=length(ca2);
% cd2(a:b)=0;
ca1=idwt(ca2(1:a),cd2,'haar');
a=length(cd1);
% b=length(ca1);
% cd1(a:b)=0;
data_WTF=idwt(ca1(1:a),cd1,'haar');
%% plot
subplot(4,1,1)
plot(t,data)
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Original signal')

subplot(4,1,2)
plot(t,data_LPF)
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Low pass Filter')

subplot(4,1,3)
plot(t,data_MAF)
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Median Filter')

subplot(4,1,4)
plot(t,data_WTF)
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Wavelet transform Filter')