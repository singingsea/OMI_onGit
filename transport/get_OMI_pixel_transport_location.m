function OMI_transport = get_OMI_pixel_transport_location()
% this function need read in the extracted TropOMI data by
% "read_TropOMI_multidays.py", it needs ERA mearged TropOMI data
% this function add up/down wind locations based on wind
addpath(genpath('C:\Users\ZhaoX\Documents\MATLAB\matlab'));
%data_path = 'C:\Projects\TropOMI\data\NO2_output\OFFL\Downsview_ERA\';
%data_path = 'C:\Projects\TropOMI\data\NO2_output\OFFL\Egbert_ERA\';
%output_path = 'C:\Projects\TropOMI\data\NO2_output\OFFL\Egbert_ERA\transport\';

avg_wind = true;% if true, then average wind at frist three pressure levels 
pressure_level = '1000hPa';% only used, if avg_win = false;
delta_t = 1; % trave time in [hour]

% location of interest
% site = 'Downsview';
%site = 'Egbert';
% site = 'FortMcKay';
site = 'StGeorge';
%site = 'FortMcKay_suncrude';


if strcmp(site,'Downsview') | strcmp(site,'Egbert') | strcmp(site,'StGeorge')
    data_path = ['C:\Projects\OMI\from_Chris\reformat\GTA_ERA\'];
else
    data_path = ['C:\Projects\OMI\from_Chris\reformat\OilSands_ERA\'];
end
output_path = ['C:\Projects\OMI\from_Chris\transport\' site '\'];
%output_path = ['C:\Projects\TropOMI\data\NO2_output\OFFL\' site '_ERA\transport\'];
%output_path = ['C:\Projects\TropOMI\data\NO2_output\OFFL\' site '_ERA\transport_0dot5\'];
%output_path = ['C:\Projects\TropOMI\data\NO2_output\OFFL\' site '_ERA\transport_1hr_avgwind\'];
mkdir(output_path);


% default lon/lat information for Pandora site
if strcmp(site,'Downsview')
    user_lat=43.7810; % Downsview
    user_lon=-79.4680;
elseif strcmp(site,'Egbert')
    user_lat=44.2300; 
    user_lon=-79.7800;
elseif strcmp(site,'FortMcKay')
    user_lat=57.1836;
    user_lon=-111.6400;
elseif strcmp(site,'StGeorge')
    user_lat=43.6605;
    user_lon=-79.39860;
elseif strcmp(site,'FortMcKay_suncrude')
    user_lat=57.0333;
    user_lon=-111.6167;  
end



    data = calculate_pixel_up_down_wind_location(data_path,user_lat,user_lon,pressure_level,delta_t,avg_wind);
    
    % use pixel_roation method ---> calcualte wind-rotated new location for
    % all pixels
    data = pixel_rotation(data,user_lat,user_lon);

    
    writetable(data,[output_path 'OMI_transport.csv']);


% save data
OMI_transport = data;
save([output_path 'OMI_transport'],'OMI_transport');

%%
function data = pixel_rotation(data,user_lat,user_lon)
for i =1:height(data)
    %[lat_r,lon_r] = wind_rotation_v2(data.u_wind,data.v_wind,user_lat,user_lon,data.lat,data.lon);
    [lat_r,lon_r,x0,y0,x1,y1] = wind_rotation(data.u_wind(i,:),data.v_wind(i,:),user_lat,user_lon,data.lat(i,:),data.lon(i,:));    
    data.lat_r(i,:) = lat_r;
    data.lon_r(i,:) = lon_r;
    data.x0(i,:) = x0;
    data.y0(i,:) = y0;
    data.x1(i,:) = x1;
    data.y1(i,:) = y1;
end
data.lat_site1 = repmat(user_lat,height(data),1); % add rotation centre location
data.lon_site1 = repmat(user_lon,height(data),1); % add rotation centre location

function data = calculate_pixel_up_down_wind_location(data_path,user_lat,user_lon,pressure_level,delta_t,avg_wind)

%data = importfile_v4([data_path filename]);
%load([data_path 'OMI.mat']);data = OMI;
load([data_path 'OMI_reformated.mat']);data = OMI_combined;


%% test to average the wind
if avg_wind
%     p = 650:50:1000;% pressure levels
%     w=exp(p.*1e-3)./sum(exp(p.*1e-3));% weight function used to average the wind
%     u = w(1).*data.u_650hPa + w(2).*data.u_700hPa + w(3).*data.u_750hPa + w(4).*data.u_800hPa + w(5).*data.u_850hPa + + w(6).*data.u_900hPa + w(7).*data.u_950hPa + w(8).*data.u_1000hPa;
%     v = w(1).*data.v_650hPa + w(2).*data.v_700hPa + w(3).*data.v_750hPa + w(4).*data.v_800hPa + w(5).*data.u_850hPa + + w(6).*data.v_900hPa + w(7).*data.v_950hPa + w(8).*data.v_1000hPa;
     u = (data.u_900hPa + data.u_950hPa + data.u_1000hPa)./3;
     v = (data.v_900hPa + data.v_950hPa + data.v_1000hPa)./3;
else
    % the following line is original wind based on pressure level
    eval(['u = data.u_' pressure_level ';']);% u wind in m/s! 
    eval(['v = data.v_' pressure_level ';']);% v wind in m/s! 
end
%%
%wd = atan2d(u,v);% wind direction [degree]
wd = atan2d(u,v) + 180;% wind direction [degree] <-- to follow the meterological defination; there is a 180 degree offset!
ws = hypot(u,v)/1000*60*60;% wind speed [km/hr]
wd = rem(360+wd, 360);% wind direction in range of [0 360]
wd_opp = rem(wd+180,360);% the opposite direction of wind! will be used to calculate the upwind location

transport_d = ws.*delta_t;% horizontal transport distance [km]

distUnits = 'km';% this unit is used for earth radius
% Convert input distance to earth degrees (Lat, Lon are typicaly given in degrees)
arclen = rad2deg(transport_d/earthRadius(distUnits)); % get the arc length of the horizontal transport
pixel_lat = data.lat;
pixel_lon = data.lon;
[trans_lat_upw,trans_lon_upw] = reckon(pixel_lat, pixel_lon,arclen,wd_opp);% get the new lat and lon --> up wind
[trans_lat_dnw,trans_lon_dnw] = reckon(pixel_lat, pixel_lon,arclen,wd);% get the new lat and lon--> down wind

data.trans_lat_upw = trans_lat_upw;% the new lat of the pixel --> up wind direction
data.trans_lon_upw = trans_lon_upw;% the new lon of the pixel --> up wind direction
data.trans_lat_dnw = trans_lat_dnw;% the new lat of the pixel --> down wind direction
data.trans_lon_dnw = trans_lon_dnw;% the new lon of the pixel --> down wind direction

[arclen_upw,az_upw] = distance(user_lat,user_lon,trans_lat_upw,trans_lon_upw);% get the arc length and angle between site and "transported pixel" --> up wind direction
[arclen_dnw,az_dnw] = distance(user_lat,user_lon,trans_lat_dnw,trans_lon_dnw);% get the arc length and angle between site and "transported pixel" --> down wind direction
[arclen_2,az_2] = distance(user_lat,user_lon,data.lat,data.lon);% get the arc length and angle between site and "original pixel"
data.distence2stn_trans_upw = deg2rad(arclen_upw).*earthRadius(distUnits);% distance between station and "transported pixel" --> up wind direction
data.distence2stn_trans_dnw = deg2rad(arclen_dnw).*earthRadius(distUnits);% distance between station and "transported pixel" --> down wind direction
data.distence2stn_original = deg2rad(arclen_2).*earthRadius(distUnits);% distance between station and "original pixel"

% save the calculated wind information
data.u_wind = u;% [m/s]
data.v_wind = v;% [m/s]
data.windspeed = ws; % [km/hr]
data.winddirection = wd;% [degree]
data.transport_distance = transport_d; % [km]



%d = get_distance(user_lat,user_lon,trans_lat,trans_lon);


function d = get_distance(user_lat,user_lon,lat,lon)
% sub function to calculate distance
R=6371000;%radius of the earth in meters
lat1=degtorad(user_lat);
lat2=degtorad(lat);
delta_lat=degtorad(lat-user_lat);
delta_lon=degtorad(lon-user_lon);
%a=(sin(delta_lat/2))*(sin(delta_lat/2))+(cos(lat1))*(cos(lat2))*(sin(delta_lon/2))*(sin(delta_lon/2));
a=(sin(delta_lat./2)).*(sin(delta_lat./2))+(cos(lat1)).*(cos(lat2)).*(sin(delta_lon./2)).*(sin(delta_lon./2));
c=2.*asin(sqrt(a));
d=R.*c;