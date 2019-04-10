# -*- coding: utf-8 -*-
"""
Created on Thu Apr  5 10:42:32 2018

@author: ZhaoX
"""

# -*- coding: utf-8 -*-
"""
Created on Wed Mar 21 10:12:55 2018

@author: ZhaoX
"""

#!/usr/bin/python 	 
import h5py
import numpy as np
import sys
import time
import calendar
import os
import pandas as pd

from read_OMI_at_a_location import OMI_at_a_location

#OMI_data_path = 'C:\\Projects\\OMI\\NO2\\download2\\'# this is all Toronto data 2015-2017
OMI_data_path = 'C:\\Projects\\OMI\\NO2\\Fort_McKay_download2\\'# this is all Fort McKay data 2013-2017
#OMI_data_path = 'C:\\Projects\\OMI\\NO2\\test\\'
#user_lat = 43.781 # Toronto
#user_lon = -79.468 # Toronto
user_lat = 57.1836 # Fort McKay
user_lon = -111.64
process_all_files = True
os.chdir(OMI_data_path)

#This finds the user's current path so that all hdf4 files can be found
try:
	fileList=open(OMI_data_path + 'fileList.txt','r')
except:
	print('Did not find a text file containing file names (perhaps name does not match)')
	sys.exit()
    
df = pd.DataFrame() 
j = 1
#loops through all files listed in the text file
for FILE_NAME in fileList:
	FILE_NAME=FILE_NAME.strip()
	if process_all_files == False:
		user_input=input('\nWould you like to process\n' + FILE_NAME + '\n\n(Y/N)')
	else:
		user_input = 'Y'
            
	if(user_input == 'N' or user_input == 'n'):
		print('Skipping...')
		continue
	else:
		try: 
			file = h5py.File(FILE_NAME, 'r')   # 'r' means that hdf5 file is open in read-only mode
		except:
			print('Failed to open file"' + FILE_NAME + '" skipping...')
			continue          
		#checks if the file contains NO2 or SO2 data, and reacts accordingly
		if 'NO2' in FILE_NAME:
			print('This is an OMI NO2 file. Saving... ')
			#utilizes a python dictionary to determine the variable specified by user input
			SDS=dict([(1,'ColumnAmountNO2'),(2,'ColumnAmountNO2Std'),
             (3,'VcdQualityFlags'),
             (4,'ColumnAmountNO2Strat'),(5,'ColumnAmountNO2StratStd'),
             (6,'ColumnAmountNO2Trop'),(7,'ColumnAmountNO2TropStd'),
             (8,'CloudFraction'),(9,'CloudFractionStd'),
             (10,'CloudPressure'),(11,'CloudPressureStd'),])
			#this is how you access the data tree in an hdf5 file
			dataFields=file['HDFEOS']['SWATHS']['ColumnAmountNO2']['Data Fields']
			#for key in dataFields:
			#Y    print(key, dataFields[key].shape)
			geolocation=file['HDFEOS']['SWATHS']['ColumnAmountNO2']['Geolocation Fields']
		elif 'SO2' in FILE_NAME:
			print('This is an OMI SO2 file. Saving... ')
			SDS=dict([(1,'ColumnAmountSO2_PBL'),(2,'ColumnAmountO3'),(3,'QualityFlags_PBL')])
			dataFields=file['HDFEOS']['SWATHS']['OMI Total Column Amount SO2']['Data Fields']
			geolocation=file['HDFEOS']['SWATHS']['OMI Total Column Amount SO2']['Geolocation Fields']
		else:
			print('The file named :',FILE_NAME, ' is not a valid OMI file. \n')
			#if the program is unable to determine that it is an OMI SO2 or NO2 file, then it will skip to the next file
			continue
		
		#get lat and lon info as vectors
		lat=geolocation['Latitude'][:].ravel()
		lon=geolocation['Longitude'][:].ravel()
		Fov75Area=geolocation['FoV75Area'][:].ravel()# get Fov info. from geolocation
		VZA=geolocation['ViewingZenithAngle'][:].ravel()# get viewing zenith angle info. from geolocation
		SolarZenithAngle=geolocation['SolarZenithAngle'][:].ravel()# 
		GroundPixelQualityFlags=geolocation['GroundPixelQualityFlags'][:].ravel()# The ground pixel quality flag contains information about the nature of the surface within the omi fov, including water and snow/ice cover.
		#get scan time and turn it into a vector
		scan_time=geolocation['Time'][:].ravel()
		
		#creates arrays the same size as scan time to receive time attributes
		year=np.zeros(scan_time.shape[0])
		month=np.zeros(scan_time.shape[0])
		day=np.zeros(scan_time.shape[0])
		hour=np.zeros(scan_time.shape[0])
		min=np.zeros(scan_time.shape[0])
		sec=np.zeros(scan_time.shape[0])
		
		#gets date info for each pixel to be saved later
		for i in range(scan_time.shape[0]):
			temp=time.gmtime(scan_time[i-1]+calendar.timegm(time.strptime('Dec 31, 1992 @ 23:59:59 UTC', '%b %d, %Y @ %H:%M:%S UTC')))
			year[i-1]=temp[0]
			month[i-1]=temp[1]
			day[i-1]=temp[2]
			hour[i-1]=temp[3]
			min[i-1]=temp[4]
			sec[i-1]=temp[5]		
		
		#Begin saving to an output array
		#end=8+len(SDS)#this is the number of columns needed (based on number of SDS read)
		end=10+len(SDS)#this is the number of columns needed (based on number of SDS read)
		output=np.array(np.zeros((year.shape[0]*60,end)))
		#print(output.shape)
		output[0:,0]=year[:].repeat(60)
		output[0:,1]=month[:].repeat(60)
		output[0:,2]=day[:].repeat(60)
		output[0:,3]=hour[:].repeat(60)
		output[0:,4]=min[:].repeat(60)
		output[0:,5]=sec[:].repeat(60)
		output[0:,6]=lat[:]
		output[0:,7]=lon[:]
		output[0:,8]=Fov75Area[:].repeat(len(year))# add Fov information
		output[0:,9]=VZA[:]# add viewing zenith angle information
        
		
		#list for the column titles (because you can't combine string values and float values into a single array)
		tempOutput=[]
		tempOutput.append('Year')
		tempOutput.append('Month')
		tempOutput.append('Day')
		tempOutput.append('Hour')
		tempOutput.append('Minute')
		tempOutput.append('Second')
		tempOutput.append('Latitude')
		tempOutput.append('Longitude')
		tempOutput.append('Fov75Area')
		tempOutput.append('VZA')
		
		#This for loop saves all of the SDS in the dictionary at the top (dependent on file type) to the array (with titles)
		#for i in range(8,end):
		for i in range(10,end):        
			#SDS_NAME=SDS[(i-7)] # The name of the sds to read
			SDS_NAME=SDS[(i-9)] # The name of the sds to read            
			#get current SDS data, or exit program if the SDS is not found in the file
			try:
				sds=dataFields[SDS_NAME]
			except:
				print('Sorry, your OMI hdf5 file does not contain the SDS:',SDS_NAME,'. Please try again with the correct file type.')
				sys.exit()
			#get attributes for current SDS
			scale=sds.attrs['ScaleFactor']
			fv=sds.attrs['_FillValue']
			mv=sds.attrs['MissingValue']
			offset=sds.attrs['Offset']
			#get SDS data as a vector
			data=sds[:].ravel()
			#The next few lines change fill value/missing value to NaN so that we can multiply valid values by the scale factor, then back to fill values for saving
			data=data.astype(float)
			data[data==float(fv)]=np.nan
			data[data==float(mv)]=np.nan
			data=(data-offset)*scale
			data[np.isnan(data)]=fv
			#the SDS and SDS name are saved to arrays which will be written to the .txt file
			#print(data.shape)
			#print(output.shape)
			output[0:,i]=data
			tempOutput.append(SDS_NAME)
			
		#changes list to an array so it can be stacked	
		tempOutput=np.asarray(tempOutput)
		#This stacks the titles on top of the data
		output=np.row_stack((tempOutput,output))
		#save the new array to a text file, which is the name of the HDF4 file .txt instead of .hdf
		#print(output[0,:].shape[0])
		nlines=output.shape[0]
		#np.savetxt('{0}.txt'.format(FILE_NAME[:-4]),output.reshape(output.shape[::-1]),fmt='%s',delimiter=',', newline='\n')
		outfilename=FILE_NAME[:-4]+'.txt'
		outfile=open(outfilename,'w')
		for i in range(0,nlines):    
			tarray=','.join(output[i,:])
			outfile.write(tarray)
			outfile.write('\n')            
			
		#outfile.write('hello')
		outfile.close()
        
		file.close()
      
      
      # save data to dataframe
      # read the saved txt file, and then get data from given location
		df_at_a_location_single_file = OMI_at_a_location( OMI_data_path + outfilename ,user_lat,user_lon)
      # read the saved txt file
		df_single_file = pd.read_csv(OMI_data_path + outfilename)
		if j == 1:    
			df = df_single_file
			df_at_a_location = df_at_a_location_single_file
			j += 1
		else:
			df = pd.concat([df,df_single_file])# this is the combined data file
			if len(df_at_a_location_single_file) > 0:
				df_at_a_location = pd.concat([df_at_a_location,df_at_a_location_single_file])  # this is the combined data at single location
		print('\nFiles' + outfilename +'have been saved successfully.')
      
print('\nAll files have been saved successfully.')
df.to_csv(OMI_data_path + 'combined_data_pixinfo3.csv', index = False)
#df_at_a_location.to_csv(OMI_data_path + 'combined_data_at_a_location_pixinfo3_onlysmallpix.csv', index = False)       
df_at_a_location.to_csv(OMI_data_path + 'combined_data_at_a_location_pixinfo3.csv', index = False)       