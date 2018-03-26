function check_ZS_DS_skyimager_OMI()
load('C:\Projects\Zenith_NO2\matlab2.mat');

DU = 2.6870e+16;


% general filters
TF_OMI = isnan(data.ColumnAmountNO2);
data(TF_OMI,:) =[];
TF_NO2_amount = data.ColumnAmountNO2./DU > -1e10;
data = data(TF_NO2_amount,:);
TF_cloud = data.CloudFraction < 0.3;
data = data(TF_cloud,:);
TF_distance = data.distance < 50000;
data = data(TF_distance,:);


TF1 = strcmp(data.mean_type,"closest");
TF2 = strcmp(data.mean_type,"dis_f1");
TF3 = strcmp(data.mean_type,"dis_f2");

figure;
hold all;
plot(data.DateDDMMYYYY_Timehhmmss,data.VCD,'.');
plot(data.DateDDMMYYYY_Timehhmmss,data.ndacc_vcd,'.');
plot(data.DateDDMMYYYY_Timehhmmss(TF1,:),data.ColumnAmountNO2(TF1,:)./DU,'s');
plot(data.DateDDMMYYYY_Timehhmmss(TF2,:),data.ColumnAmountNO2(TF2,:)./DU,'s');
plot(data.DateDDMMYYYY_Timehhmmss(TF3,:),data.ColumnAmountNO2(TF3,:)./DU,'s');

plot(data.DateDDMMYYYY_Timehhmmss(TF1,:),data.ColumnAmountNO2Strat(TF1,:)./DU,'d');
plot(data.DateDDMMYYYY_Timehhmmss(TF2,:),data.ColumnAmountNO2Strat(TF2,:)./DU,'d');
plot(data.DateDDMMYYYY_Timehhmmss(TF3,:),data.ColumnAmountNO2Strat(TF3,:)./DU,'d');

ylabel('OMI NO_2 [DU]');
legend('DS','ZS','NO2 closest','NO2 20km','NO2 50km','NO2_S_t_r_a_t closest','NO2_S_t_r_a_t 20km','NO2_S_t_r_a_t 50km');
R1 = corr(data.VCD(TF1,:),data.ColumnAmountNO2(TF1,:)./DU);
disp(['R1 = ' num2str(R1)]);
R2 = corr(data.VCD(TF2,:),data.ColumnAmountNO2(TF2,:)./DU);
disp(['R2 = ' num2str(R2)]);
R3 = corr(data.VCD(TF3,:),data.ColumnAmountNO2(TF3,:)./DU);
disp(['R3 = ' num2str(R3)]);

%% OMI vs DS (closest)
TF_fig = TF1;
figure;hold all;
x = data.VCD(TF_fig,:);
y = data.ColumnAmountNO2(TF_fig,:)./DU;
dscatter(x,y);
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
plot([-10 10],[-10 10],'k');
plot_simple_linear_fit(x,y);
plot_simple_nl_fit(x,y);
ylabel('OMI NO_2 [DU]');
xlabel('DS VCD [DU]');
legend('data density','1-on-1','y = a*x+b', 'y = a*x');
title('closest');
R = corr(x,y);
text(0,2,['R = ' num2str(R)]);
grid on;

%% OMI vs DS (dis f1)
TF_fig = TF2;
figure;hold all;
x = data.VCD(TF_fig,:);
y = data.ColumnAmountNO2(TF_fig,:)./DU;
dscatter(x,y);
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
plot([-10 10],[-10 10],'k');
plot_simple_linear_fit(x,y);
plot_simple_nl_fit(x,y);
ylabel('OMI NO_2 [DU]');
xlabel('DS VCD [DU]');
legend('data density','1-on-1','y = a*x+b', 'y = a*x');
title('dis f1');
R = corr(x,y);
text(0,2,['R = ' num2str(R)]);
grid on;

%% OMI vs DS (dis f2)
TF_fig = TF3;
figure;hold all;
x = data.VCD(TF_fig,:);
y = data.ColumnAmountNO2(TF_fig,:)./DU;
dscatter(x,y);
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
plot([-10 10],[-10 10],'k');
plot_simple_linear_fit(x,y);
plot_simple_nl_fit(x,y);
ylabel('OMI NO_2 [DU]');
xlabel('DS VCD [DU]');
legend('data density','1-on-1','y = a*x+b', 'y = a*x');
title('dis f2');
R = corr(x,y);
text(0,2,['R = ' num2str(R)]);
grid on;

%% OMI vs ZS (closest)
TF_fig = TF1;
figure;hold all;
x = data.ndacc_vcd(TF_fig,:);
y = data.ColumnAmountNO2(TF_fig,:)./DU;
dscatter(x,y);
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
plot([-10 10],[-10 10],'k');
plot_simple_linear_fit(x,y);
plot_simple_nl_fit(x,y);
ylabel('OMI NO_2 [DU]');
xlabel('ZS VCD [DU]');
legend('data density','1-on-1','y = a*x+b', 'y = a*x');
title('closest');
R = corr(x,y);
text(0,2,['R = ' num2str(R)]);
grid on;

%% OMI vs ZS (dis f1)
TF_fig = TF2;
figure;hold all;
x = data.ndacc_vcd(TF_fig,:);
y = data.ColumnAmountNO2(TF_fig,:)./DU;
dscatter(x,y);
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
plot([-10 10],[-10 10],'k');
plot_simple_linear_fit(x,y);
plot_simple_nl_fit(x,y);
ylabel('OMI NO_2 [DU]');
xlabel('ZS VCD [DU]');
legend('data density','1-on-1','y = a*x+b', 'y = a*x');
title('dis f1');
R = corr(x,y);
text(0,2,['R = ' num2str(R)]);
grid on;

%% OMI vs ZS (dis f2)
TF_fig = TF3;
figure;hold all;
x = data.ndacc_vcd(TF_fig,:);
y = data.ColumnAmountNO2(TF_fig,:)./DU;
dscatter(x,y);
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
plot([-10 10],[-10 10],'k');
plot_simple_linear_fit(x,y);
plot_simple_nl_fit(x,y);
ylabel('OMI NO_2 [DU]');
xlabel('ZS VCD [DU]');
legend('data density','1-on-1','y = a*x+b', 'y = a*x');
title('dis f2');
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
plot(new_x,new_y);


%% 
function plot_simple_linear_fit(x,y)
mdl = fitlm(x,y,'y~1+x1');
intercept = mdl.Coefficients.Estimate(1);
slop = mdl.Coefficients.Estimate(2);
new_x = [-10;10];
new_y = predict(mdl,new_x);
plot(new_x,new_y);