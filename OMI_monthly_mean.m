function [OMI_monthly,OMI_daily] = OMI_monthly_mean()
% this function prepare OMI monthly mean and interpreted daily
DU = 2.6870e+16;
%load('C:\Projects\OMI\NO2\OMI_NO2_Downsview.mat');%
load('C:\Projects\OMI\NO2\OMI_NO2_FortMcKay.mat');%

data = OMI;

TF_type = OMI.mean_type == "closest";
%TF_type = OMI.mean_type == "dis_f2";
data(~TF_type,:)=[];

data.mean_type = [];

data = table2timetable(data,'RowTimes','UTC');

% general QC
TF_negative = data.ColumnAmountNO2Strat < 0;
data(TF_negative,:)=[];
TF_negative = data.ColumnAmountNO2 < 0;
data(TF_negative,:)=[];
% calculate monthly mean
data_monthly = retime(data,'monthly','mean');
data_monthly.NO2_strat = data_monthly.ColumnAmountNO2Strat./DU;
data_monthly.NO2 = data_monthly.ColumnAmountNO2./DU;
% calculate daily
data_daily = retime(data,'daily','linear');
data_daily.NO2_strat = data_daily.ColumnAmountNO2Strat./DU;
data_daily.NO2 = data_daily.ColumnAmountNO2./DU;

figure;hold all;
yyaxis left;
plot(data.UTC,data.ColumnAmountNO2Strat./DU,'.');
plot(data_monthly.UTC,data_monthly.NO2_strat,'s-');
plot(data_daily.UTC,data_daily.NO2_strat,'s-');
ylabel(['OMI strat. NO_2 [DU]']);
yyaxis right;
plot(data.UTC,data.ColumnAmountNO2./DU,'.');
plot(data_monthly.UTC,data_monthly.NO2,'s-');
ylabel(['OMI total NO_2 [DU]']);
legend({'strat daily','strat monthly mean','strat daily (interp)','total daily','total monthly mean'});
title(['Toronto']);

OMI_monthly = table;
OMI_monthly.OMI_monthly_UTC = data_monthly.UTC;
OMI_monthly.OMI_monthly_NO2_strat = data_monthly.NO2_strat;
OMI_monthly.OMI_monthly_NO2 = data_monthly.NO2;

OMI_daily = table;
OMI_daily.OMI_daily_UTC = data_daily.UTC;
OMI_daily.OMI_daily_NO2_strat = data_daily.NO2_strat;
OMI_daily.OMI_daily_NO2 = data_daily.NO2;


OMI_monthly = table2timetable(OMI_monthly,'RowTimes','OMI_monthly_UTC');
OMI_daily = table2timetable(OMI_daily,'RowTimes','OMI_daily_UTC');


