clc;clear all;close all;
data_Ca_H=load ('atousa_HEOG.txt');
Fs=1000;
L_Ca_H=length(data_Ca_H);
t_Ca=(0:L_Ca_H-1)./Fs;
%% low pass filter
data_Ca_H=data_Ca_H-mean(data_Ca_H);
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.01,0.08,1,110);
d=design(h,'equiripple'); %Lowpass FIR filter
data_Ca_H_LPF=filtfilt(d.Numerator,1,data_Ca_H); %zero-phase filtering
%% find peak
CA_Ca_H = cwt(data_Ca_H_LPF,20,'haar');
b=1;
[pks,locs] = findpeaks(abs(CA_Ca_H));
for i=3:length(pks)-3
       if abs(pks(i))>0.1
          loc2(b)=locs(i);
          b= b+1;
       end
end
%% Find threshold
ampl=mean(abs(CA_Ca_H(loc2)));
thresh_H=ampl*0.1;
%% find eye movement 
load ('SaccadesSel_1.txt');
data_H=data(:,2);
data_H=data_H-mean(data_H);
Fs=1000;
L_H=length(data_H);
t=(0:L_H-1)./Fs;
%% low pass filter
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.01,0.08,1,110);
d=design(h,'equiripple'); %Lowpass FIR filter
data_H_LPF=filtfilt(d.Numerator,1,data_H); %zero-phase filtering
%% saccade and fixation
CA_H = cwt(data_H_LPF,20,'haar');
m_H=zeros(L_H,1);
for i=1:L_H
    if CA_H(i)> thresh_H
        m_H(i,1)=-1;
    else if CA_H(i)<-thresh_H
            m_H(i,1)=1;
        else
            m_H(i,1)=0;
        end
    end
end
%% find left or right
[pks2,locs2] = findpeaks(abs(CA_H));
c=1;
d=1;
for i=1:length(pks2)
       if CA_H(locs2(i))> thresh_H
          loc_type(c,1)=locs2(i);
          y(c)=0.1;
          type_H(c,1)='L';
          c= c+1;
         
       else if CA_H(locs2(i))< -thresh_H
          loc_type(c,1)=locs2(i);
          y(c)=0.1;
          type_H(c,1)='R';
          c= c+1;
          
           end
       end
end
 type=cellstr(type_H);
%% Transition time
diff_Wav=100*diff(CA_H);
[pks1,locs1] = findpeaks(abs(diff_Wav));
 a=1;
for i=3:length(pks1)-3
       if pks1(i)>3*thresh_H
           loc3(a)=locs1(i);
        a=a+1;
       end
end
% duration
tt1=diff(loc3);
for i=1:fix((length(loc3)/2))-1
tran_time(i,1)=tt1(2*i+1); %Transition time
end
%% gaze duration
fix_drt=diff(loc_type);%gd=gaze duration
%% amplitude
ppv=data_H_LPF(loc_type(1:length(tran_time))+tran_time);%ppv=peak potential value
%% plot
subplot(2,2,1)
plot(t,data_H)
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('EOG')

subplot(2,2,3)
plot(t,data_H_LPF)
text(((loc_type+60)/Fs),data_H(loc_type),type,'color',[1 0 0])
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Filtering EOG')

subplot(2,2,2)
plot(t(20:end-20),CA_H(20:end-20))
hold on
plot(t(loc_type),CA_H(loc_type),'r*')
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Wavelet transform')

subplot(2,2,4)
plot(t,m_H)
xlabel('Time(s)')
title('Vector M')

figure
subplot(2,1,1)
plot(t_Ca,data_Ca_H_LPF)
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('EOG Calibration signal')

subplot(2,1,2)
plot(t_Ca(20:end-20),CA_Ca_H(20:end-20))
hold on
plot(t_Ca(loc2),CA_Ca_H(loc2),'r*')
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Wavelet transform')


%% table of data
dat(1:10,1)=tran_time(1:10)/Fs;
dat(1:10,3)=ppv(1:10);
dat(1:10,2)=fix_drt(1:10)/Fs;
dat(:,4)=m_H(loc_type(1:10));

f = figure('Position',[100 100 400 150]);dat;
columnname =   {'transition time(s)','fixation duration(s)','Amplitude','Direction of eye Movement '};
columnformat = {'numeric', 'bank'}; 
columneditable =  [true,true]; 
t = uitable('Units','normalized','Position',...
            [0.1 0.1 0.9 0.9],'data',dat, ... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', columneditable);
       
