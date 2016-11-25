clc;clear all;close all;
load ('saccade.mat');
data1=data;
L=length(data1);
data=load ('ATOUSA_VEOG.txt');
data(end+1:end+L)=data1;
