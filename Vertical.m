clc;clear all;close all;
data_Ca=load ('ATOUSA_VEOG.txt');
Fs=1000;
L_Ca_V=length(data_Ca);
t_Ca=(0:L_Ca_V-1)./Fs;
%% low pass filter
data_Ca_V=data_Ca-mean(data_Ca);
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.01,0.08,1,110);
d=design(h,'equiripple'); %Lowpass FIR filter
data_Ca_V_LPF=filtfilt(d.Numerator,1,data_Ca_V); %zero-phase filtering
%% find peak
CA_Ca_V = cwt(data_Ca_V_LPF,20,'haar');
b=1;
[pks,locs] = findpeaks(abs(CA_Ca_V));
for i=1:length(pks)
       if abs(pks(i))>0.05
          loc2(b)=locs(i);
          b= b+1;
       end
end
b_dur=diff(loc2);
%% Find threshold
ampl=mean(abs(CA_Ca_V(loc2)));
thresh_V=ampl*0.8;
%% Blink of calibration
m_V_b=zeros(L_Ca_V,1);
for i=1: length(b_dur)
if b_dur(i)< 100
    m_V_b(loc2(i):loc2(i)+(b_dur(i)/2))=2;
    m_V_b(loc2(i+1)-(b_dur(i)/2):loc2(i+1))=-2;
end
end
%% find eye movement 
load ('Saccade.mat');
data_V=data;
data_V=data_V-mean(data_V);
Fs=1000;
L_V=length(data_V);
t=(0:L_V-1)./Fs;
%% low pass filter
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.01,0.08,1,110);
d=design(h,'equiripple'); %Lowpass FIR filter
data_V_LPF=filtfilt(d.Numerator,1,data_V); %zero-phase filtering
%% saccade and fixation
CA_V = cwt(data_V_LPF,20,'haar');
m_V=zeros(L_V,1);
for i=1:L_V
    if CA_V(i)> thresh_V
        m_V(i,1)=-1;
    else if CA_V(i)<-thresh_V
            m_V(i,1)=1;
        else
            m_V(i,1)=0;
        end
    end
end

%% find Up or Down
[pks2,locs2] = findpeaks(abs(CA_V));
c=1;
d=1;
for i=1:length(pks2)
       if CA_V(locs2(i))> thresh_V
          loc_type(c,1)=locs2(i);
          y(c)=0.1;
          type_V(c,1)='U';
          c= c+1;
         
       else if CA_V(locs2(i))< -thresh_V
          loc_type(c,1)=locs2(i);
          y(c)=0.1;
          type_V(c,1)='D';
          c= c+1;
          
           end
       end
end
%% Transition time
diff_Wav=100*diff(CA_V);
[pks1,locs1] = findpeaks(abs(diff_Wav));
 a=1;
for i=3:length(pks1)-3
       if pks1(i)>3*thresh_V
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
ppv=data_V_LPF(loc_type(1:length(tran_time))+tran_time);%ppv=peak potential value
%% Blink Detection
b_V=diff(loc_type);
for i=1:length(b_V)
    if b_V(i)< 100
        m_V(loc_type(i):loc_type(i)+(b_V(i)/2))=2;
        m_V(loc_type(i+1)-(b_V(i)/2):loc_type(i+1))=-2;
        type_V(i)='B';
    end
end
   type=cellstr(type_V);    
%% plot
subplot(2,2,1)
plot(t,data_V)
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('EOG')

subplot(2,2,3)
plot(t,data_V_LPF)
text(((loc_type+60)/Fs),data_V(loc_type),type,'color',[1 0 0])
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Filtering EOG')

subplot(2,2,2)
plot(t(20:end-20),CA_V(20:end-20))
hold on
plot(t(loc_type),CA_V(loc_type),'r*')
xlabel('Time(s)')
ylabel('Amplitude(mV)')
title('Wavelet transform')

subplot(2,2,4)
plot(t,m_V)
xlabel('Time(s)')
title('Vector M')

figure
subplot(3,1,1)
plot(t_Ca,data_Ca_V_LPF)
xlabel('Time(s)')
ylabel('Amplitude(V)')
title('EOG Calibration signal')

subplot(3,1,2)
plot(t_Ca(20:end-20),CA_Ca_V(20:end-20))
hold on
plot(t_Ca(loc2),CA_Ca_V(loc2),'r*')
xlabel('Time(s)')
ylabel('Amplitude(V)')
title('Wavelet transform')

subplot(3,1,3)
plot(t_Ca,m_V_b)
xlabel('Time(s)')
ylabel('Amplitude(V)')
title('Blink detection')

%% table of data
dat(1:10,1)=tran_time(1:10)/Fs;
dat(1:10,3)=ppv(1:10);
dat(1:10,2)=fix_drt(1:10)/Fs;
dat(:,4)=m_V(loc_type(1:10));

f = figure('Position',[100 100 400 150]);dat;
columnname =   {'transition time(s)','fixation duration(s)','Amplitude','Direction of eye Movement '};
columnformat = {'numeric', 'bank'}; 
columneditable =  [true,true]; 
t = uitable('Units','normalized','Position',...
            [0.1 0.1 0.9 0.9],'data',dat, ... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnEditable', columneditable);
       