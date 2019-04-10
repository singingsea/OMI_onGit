function check_ZS_DS_skyimager_OMI_v2()
use_corrected_NO2 = true;
addpath('C:\Users\ZhaoX\Documents\MATLAB\matlab');
%load('C:\Projects\Zenith_NO2\matlab_ZSDS_skyimager_OMI_closest_DS_corrected');
%mean_type = 'closest';
%load('C:\Projects\Zenith_NO2\matlab_ZSDS_skyimager_OMI_f1_DS_corrected');%this f1 averging inlcude all pixels
load('C:\Projects\Zenith_NO2\matlab_ZSDS_skyimager_OMI_f1_DS_corrected_onlysmallpix');% this avering only used small pixel
mean_type = 'dis_f1';
%load('C:\Projects\Zenith_NO2\matlab_ZSDS_skyimager_OMI_f2_DS_corrected');%this f2 averging inlcude all pixels
%load('C:\Projects\Zenith_NO2\matlab_ZSDS_skyimager_OMI_f2_DS_corrected_onlysmallpix');% this avering only used small pixel
%mean_type = 'dis_f2';


DU = 2.6870e+16;
if use_corrected_NO2
    data.VCD = data.VCD_corrected;% replace NO2 VCD used in analysis by corrected values
else
    data.VCD = data.NO2_VCD;
end

%data = data_unfiltered;
use_CI_filter = false;
use_sky_imager_filter = false;
use_OMI_filter = true;

% CI filters
if use_CI_filter
    TF_CI = data.CI < (mean(data.CI)-std(data.CI));
    data(TF_CI,:) = [];
end

% sky-imager filters
if use_sky_imager_filter
    TF = isnan(data.iSunStrength);
    data(TF,:) = [];
    TF_iSunStrength = data.iSunStrength < (mean(data.iSunStrength) - std(data.iSunStrength));
    data(TF_iSunStrength,:) = [];

    TF_iPctOpq  = data.iPctOpq  > (mean(data.iPctOpq ) + std(data.iPctOpq ));
    data(TF_iPctOpq ,:) = [];

    TF_iPctThin  = data.iPctThin  > (mean(data.iPctThin ) + std(data.iPctThin ));
    data(TF_iPctThin ,:) = [];
end


% OMI data general filters
TF_OMI = isnan(data.ColumnAmountNO2);
data(TF_OMI,:) =[];
TF_NO2_amount = data.ColumnAmountNO2./DU > -1e10;
data = data(TF_NO2_amount,:);
TF_VcdQualityFlags = data.VcdQualityFlags ~= 0; % see OMI NO2 L2 document
data(TF_VcdQualityFlags,:) =[];
if use_OMI_filter
    TF_cloud = data.CloudFraction < 0.3;
    data = data(TF_cloud,:);
    TF_distance = data.distance < 50000;
    data = data(TF_distance,:);
    % OMI small pixel filter
    %TF_smallpix = data.VZA<=45;
    %data = data(TF_smallpix,:);
end



% OMI mean type filter
TF1 = strcmp(data.mean_type,mean_type);

figure;
hold all;
plot(data.DateDDMMYYYY_Timehhmmss,data.VCD,'.');
plot(data.DateDDMMYYYY_Timehhmmss,data.ndacc_vcd,'.');
plot(data.DateDDMMYYYY_Timehhmmss(TF1,:),data.ColumnAmountNO2(TF1,:)./DU,'s');
plot(data.DateDDMMYYYY_Timehhmmss(TF1,:),data.ColumnAmountNO2Strat(TF1,:)./DU,'d');

ylabel('OMI NO_2 [DU]');
legend('DS','ZS','OMI NO2', 'OMI NO2_S_t_r_a_t');
R1 = corr(data.VCD(TF1,:),data.ColumnAmountNO2(TF1,:)./DU);
disp(['R1 (DS vs. OMI ' mean_type ') = ' num2str(R1)]);

R2 = corr(data.ndacc_vcd(TF1,:),data.ColumnAmountNO2(TF1,:)./DU);
disp(['R2 (ZS vs. OMI ' mean_type ') = ' num2str(R2)]);

%% OMI vs DS 
TF_fig = TF1;
figure;hold all;
x = data.VCD(TF_fig,:);
y = data.ColumnAmountNO2(TF_fig,:)./DU;
%dscatter(x,y);
scatter(x,y,'filled');
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
plot([-10 10],[-10 10],'k');
plot_simple_linear_fit(x,y);
plot_simple_nl_fit(x,y);
ylabel('OMI NO_2 [DU]');
xlabel('DS VCD [DU]');
legend('data density','1-on-1','y = a*x+b', 'y = a*x');
title(mean_type);
R = corr(x,y);
text(0,2,['R = ' num2str(R)]);
grid on;


%% OMI vs ZS 
TF_fig = TF1;
figure;hold all;
x = data.ndacc_vcd(TF_fig,:);
y = data.ColumnAmountNO2(TF_fig,:)./DU;
%dscatter(x,y);
scatter(x,y,'filled');
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
plot([-10 10],[-10 10],'k');
plot_simple_linear_fit(x,y);
plot_simple_nl_fit(x,y);
ylabel('OMI NO_2 [DU]');
xlabel('ZS VCD [DU]');
legend('data density','1-on-1','y = a*x+b', 'y = a*x');
title(mean_type);
R = corr(x,y);
text(0,2,['R = ' num2str(R)]);
grid on;


%% 
function plot_simple_nl_fit(x,y)
modelfun = 'y ~ b1*x';
beta0 = [0];
mdl = fitnlm(x,y,modelfun,beta0);

new_x = [-10;10];
new_y = predict(mdl,new_x);
plot(new_x,new_y,'r');
b1 = mdl.Coefficients.Estimate;
textbp(['y = ' num2str(b1) '*x'],'color','r' );



%% 
function plot_simple_linear_fit(x,y)
mdl = fitlm(x,y,'y~1+x1');
intercept = mdl.Coefficients.Estimate(1);
slop = mdl.Coefficients.Estimate(2);
new_x = [-10;10];
new_y = predict(mdl,new_x);
plot(new_x,new_y,'b');
textbp(['y = ' num2str(slop) '*x + ' num2str(intercept)],'color','b'  );
textbp(['N = ' num2str(numel(x))])