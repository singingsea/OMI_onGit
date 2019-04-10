function OMI_combined = reformat_Chris_OMI_data()
% simple function that can reformat Chris' OMI data to a similar format
% can be processed by transport code
addpath(genpath('C:\Projects\OMI\OMI_onGit\'));
output_path = 'C:\Projects\OMI\from_Chris\reformat\';
% load Chris' data
%load('C:\Projects\OMI\data\NO2\OFFL\OMIknmidata_no2_GlobalSO2_011_600km_ECCC.mat');
area = 'OilSands';
%area = 'GTA';
for year = 2013:2018
    load(['C:\Projects\OMI\from_Chris\original_data\OMI_NO2_NA_cf0.5_' num2str(year) '_v3.1.mat']);

    OMI = table;

    % read in Chris' data filed
    OMI.lon = data.lon';
    OMI.lat = data.lat';
    OMI.sza = data.sza';
    OMI.vza = data.vza';
    OMI.cldfrac = data.cldfrac';
    % OMI.clp = data.clp';
    OMI.snow = data.snow';
    OMI.pixel = data.pix';
    OMI.albedo = data.alb';

    OMI.ECCC_AMF = data.amf';
    OMI.SP_AMF = data.amf0';
    OMI.no2_strat = data.vcds';
    OMI.no2_trop = data.vcd0';
    OMI.ECCC_NO2 = data.vcd';

    OMI.vmr = data.vmr';
    OMI.vmrGM = data.vmrGM';
    OMI.c2s = data.c2s';


    OMI.u_1000hPa = data.u(6,:)';
    OMI.v_1000hPa = data.v(6,:)';

    OMI.u_950hPa = data.u(5,:)';	
    OMI.v_950hPa = data.v(5,:)';	

    OMI.u_900hPa = data.u(4,:)';	
    OMI.v_900hPa = data.v(4,:)';	

    OMI.u_800hPa = data.u(3,:)';	
    OMI.v_800hPa = data.v(3,:)';	

    OMI.u_700hPa = data.u(2,:)';	
    OMI.v_700hPa = data.v(2,:)';	

    OMI.u_600hPa = data.u(1,:)';	
    OMI.v_600hPa = data.v(1,:)';	


    OMI.mdj = data.mjd';
    [year,month,day,hour,minute,secs,ticks] = mjd2utc(OMI.mdj);
    OMI.utc_time = datetime(year,month,day,hour,minute,secs,ticks);

    
    if strcmp(area,'GTA')
        tf = (OMI.lat >= 41) & (OMI.lat <= 46.5) & (OMI.lon >= -83) & (OMI.lon <= -75.5);
    elseif strcmp(area,'OilSands')
        tf = (OMI.lat >= 54.5) & (OMI.lat <= 60.0) & (OMI.lon >= -117) & (OMI.lon <= -106);
    end
    OMI = OMI(tf,:);
    
    if year == 2013
        OMI_combined = OMI;
    else
        OMI_combined = [OMI_combined;OMI];
    end
end

tf_qa = (OMI_combined.cldfrac <=0.3) & (OMI_combined.pixel >=11) & (OMI_combined.pixel <= 50);
OMI_combined.qa = tf_qa;
tf_qa075 = (OMI_combined.cldfrac <=0.3) & ((OMI_combined.pixel < 11) | (OMI_combined.pixel > 50));
OMI_combined.qa = double(OMI_combined.qa);
OMI_combined.qa(tf_qa075,:) = 0.75;


save([output_path area '_ERA\OMI_reformated'], 'OMI_combined');
