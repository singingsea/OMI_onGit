# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 10:46:25 2018

@author: ZhaoX
"""

import pandas as pd
import numpy as np

OMI_csv_data_path = 'C:\\Projects\\OMI\\NO2\\download\\combined_data.csv'
user_lat = 43
user_lon = -75

def OMI_at_a_location(OMI_csv_data_path,user_lat,user_lon):
       
    df = pd.read_csv(OMI_csv_data_path)
    #df= df[df['VcdQualityFlags'] == 0] # only use good quality NO2 data
    #df= df[df['VZA']<= 45] # only use small pixel
    
    latitude = df.Latitude
    longitude = df.Longitude
    distence_f1 = 20000 # in meter
    distence_f2 = 50000 # in meter
       
    #calculation to find nearest point in data to entered location (haversine formula)
    R=6371000#radius of the earth in meters
    lat1=np.radians(user_lat)
    lat2=np.radians(latitude)
    delta_lat=np.radians(latitude-user_lat)
    delta_lon=np.radians(longitude-user_lon)
    a=(np.sin(delta_lat/2))*(np.sin(delta_lat/2))+(np.cos(lat1))*(np.cos(lat2))*(np.sin(delta_lon/2))*(np.sin(delta_lon/2))
    c=2*np.arctan2(np.sqrt(a),np.sqrt(1-a))
    d=R*c
    #gets (and then prints) the x,y location of the nearest point in data to entered location, accounting for no data values
    closest_pix_idx = d == d.min() # get the boolen series of closest pix 
    dis_f1_pix_idx = d < distence_f1 # get the boolen series of pix that within distance f1
    dis_f2_pix_idx = d < distence_f2 # get the boolen series of pix that within distance f2
    
    df_output_closest = df.loc[closest_pix_idx,:] # get the dataframe of closest pix 
    df_output_f1 = df.loc[dis_f1_pix_idx,:] # get the dataframe of pix that within distance f1
    df_output_f2 = df.loc[dis_f2_pix_idx,:] # get the dataframe of pix that within distance f2
    df_output = pd.DataFrame()
    
    if len(df_output_closest) > 0:
        df_output_closest.reset_index(inplace=True,drop=True) # reset index, to make sure we can concat this one with f1 and f2 mean 
        df_output_closest['mean_type'] = 'closest' # make a column to tell the how this data was averaged, eg. closet pix, or within f1, or within f2 distance
        df_output_closest.set_index(['mean_type'],inplace = True)
        df_output_closest['number_of_pix'] = 1 # how many pix used to get this mean value
        df_output_closest['distance'] = d.min() # the mean distance between OMI measurement to the selected location
        df_output_closest['UTC'] = pd.datetime(df_output_closest.Year, df_output_closest.Month, df_output_closest.Day, df_output_closest.Hour, df_output_closest.Minute, df_output_closest.Second) # add a Pandas datetime (UTC)
        df_output = df_output_closest # concat the data
        
    if len(df_output_f1) > 0:
        df_output_f1_mean = df_output_f1.mean() # get the mean of pix that within distance f1 (series)
        df_output_f1_mean = pd.DataFrame(df_output_f1_mean.values.reshape(1,df_output_f1_mean.size),columns=df_output_f1_mean.index) # reformat the series back to dataframe
        df_output_f1_mean['mean_type'] = 'dis_f1'
        df_output_f1_mean.set_index(['mean_type'],inplace = True)
        df_output_f1_mean['number_of_pix'] = sum(dis_f1_pix_idx)
        df_output_f1_mean['distance'] = d[dis_f1_pix_idx].mean()
        if df_output_f1_mean.Year.isnull()[0] & ~df_output_closest.Year.isnull()[0]: # if no measurement were made within f1, then we still assign a time to this part, just using the closest pix
            df_output_f1_mean.Year = df_output_closest.Year[0]         
            df_output_f1_mean.Month = df_output_closest.Month[0]
            df_output_f1_mean.Day = df_output_closest.Day[0]
            df_output_f1_mean.Hour = df_output_closest.Hour[0]
            df_output_f1_mean.Minute = df_output_closest.Minute[0]
            df_output_f1_mean.Second = df_output_closest.Second[0]
        df_output_f1_mean['UTC'] = pd.datetime(df_output_f1_mean.Year, df_output_f1_mean.Month, df_output_f1_mean.Day, df_output_f1_mean.Hour, df_output_f1_mean.Minute, df_output_f1_mean.Second)
        df_output = pd.concat([df_output,df_output_f1_mean]) # concat the data
    
    if len(df_output_f2) > 0:    
        df_output_f2_mean = df_output_f2.mean() # get the mean of pix that within distance f1 (series)
        df_output_f2_mean = pd.DataFrame(df_output_f2_mean.values.reshape(1,df_output_f2_mean.size),columns=df_output_f2_mean.index) # reformat the series back to dataframe
        df_output_f2_mean['mean_type'] = 'dis_f2'
        df_output_f2_mean.set_index(['mean_type'],inplace = True)
        df_output_f2_mean['number_of_pix'] = sum(dis_f2_pix_idx)
        df_output_f2_mean['distance'] = d[dis_f2_pix_idx].mean()
        if df_output_f2_mean.Year.isnull()[0] & ~df_output_closest.Year.isnull()[0]:# if no measurement were made within f2, then we still assign a time to this part, just using the closest pix
            df_output_f2_mean.Year = df_output_closest.Year[0]        
            df_output_f2_mean.Month = df_output_closest.Month[0]
            df_output_f2_mean.Day = df_output_closest.Day[0]
            df_output_f2_mean.Hour = df_output_closest.Hour[0]
            df_output_f2_mean.Minute = df_output_closest.Minute[0]
            df_output_f2_mean.Second = df_output_closest.Second[0]
        df_output_f2_mean['UTC'] = pd.datetime(df_output_f2_mean.Year, df_output_f2_mean.Month, df_output_f2_mean.Day, df_output_f2_mean.Hour, df_output_f2_mean.Minute, df_output_f2_mean.Second)
        df_output = pd.concat([df_output,df_output_f2_mean]) # concat the data
        
    #df_output = pd.concat([df_output_closest,df_output_f1_mean,df_output_f2_mean]) # concat the data
    df_output.reset_index(inplace = True)
    
    return df_output

if __name__ == '__main__':
    OMI_at_a_location(OMI_csv_data_path,user_lat,user_lon)
