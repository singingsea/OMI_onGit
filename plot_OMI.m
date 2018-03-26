function plot_OMI(OMI)
load('C:\Projects\OMI\NO2\OMI_NO2_Downsview.mat');
DU = 2.6870e+16;

data = OMI;
% general filters
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
plot(data.UTC(TF1,:),data.ColumnAmountNO2(TF1,:)./DU,'s');
plot(data.UTC(TF2,:),data.ColumnAmountNO2(TF2,:)./DU,'s');
plot(data.UTC(TF3,:),data.ColumnAmountNO2(TF3,:)./DU,'s');

plot(data.UTC(TF1,:),data.ColumnAmountNO2Strat(TF1,:)./DU,'d');
plot(data.UTC(TF2,:),data.ColumnAmountNO2Strat(TF2,:)./DU,'d');
plot(data.UTC(TF3,:),data.ColumnAmountNO2Strat(TF3,:)./DU,'d');

ylabel('OMI NO_2 [DU]');
legend('NO2 closest','NO2 20km','NO2 50km','NO2_S_t_r_a_t closest','NO2_S_t_r_a_t 20km','NO2_S_t_r_a_t 50km');