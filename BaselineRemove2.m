function[data_in]=BaselineRemove2()
clc;clear all;close all;
data=load ('SaccadesSel.txt');
data=data(:,2);
Fs=1000;
%% Baseline drift remove
CA_V = cwt(data,9,'haar');
[cA,cD] = dwt(data,'db9');  
[cA1,cD1] = dwt(cA,'db9');                                   %1D wavelate at level nine using daubechies
[cA2,cD2] = dwt(cA1,'db9'); 
[cA3,cD3] = dwt(cA2,'db9'); 
[cA4,cD4] = dwt(cA3,'db9'); 
[cA5,cD5] = dwt(cA4,'db9'); 
[cA6,cD6] = dwt(cA5,'db9'); 
[cA7,cD7] = dwt(cA6,'db9'); 
[cA8,cD8] = dwt(cA7,'db9'); 
cA82=zeros(length(cA8),1);
cA72=idwt(cA82,cD8,'db9');
a=length(cD7);
% b=length(cA72);
% cD7(a:b)=0;
cA62=idwt(cA72(1:a),cD7,'db9');
a=length(cD6);
% b=length(cA62);
% cD6(a:b)=0;
cA52=idwt(cA62(1:a),cD6,'db9');
a=length(cD5);
% b=length(cA52);
% cD5(a:b)=0;
cA42=idwt(cA52(1:a),cD5,'db9');
a=length(cD4);
% b=length(cA42);
% cD4(a:b)=0;
cA32=idwt(cA42(1:a),cD4,'db9');
a=length(cD3);
% b=length(cA32);
% cD3(a:b)=0;
cA22=idwt(cA32(1:a),cD3,'db9');
a=length(cD2);
% b=length(cA22);
% cD2(a:b)=0;
cA12=idwt(cA22(1:a),cD2,'db9');
a=length(cD1);
% b=length(cA12);
% cD1(a:b)=0;
cA222=idwt(cA12(1:a),cD1,'db9');
a=length(cD);
% b=length(cA222);
% cD(a:b)=0;
base=idwt(cA222(1:a),cD,'db9');
base_line=data-base;
base_remove=data-mean(data);
L=length(data);
l=length(cA);
alyas_dwt=((l*2)-L);
t=(0:L-1)./Fs;
% Rmean=mean(cA);
% data_in=data- Rmean;
% data_in=zeros(L);
% data_in(1:l)=(data(1:l)-cA);
% a=l-alyas_dwt;
% data_in(a+1:L)=(data(a+1:L)-cD);
subplot(2,1,1)
plot(t,data)
subplot(2,1,2)
plot(t,base_remove)

