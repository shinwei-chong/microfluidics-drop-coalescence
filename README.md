# Estimating Droplet Coalescence Time in Microfluidics
2020/21 MEng Research Project

## Aim
To develop a MATLAB-based tool for processing experimental videos containing droplet coalescence events to predict the droplet coalescence time.

## Contents
The project repository will be split into the following parts (folders):  

**1. video-processing**  
   - extract individual frames from video 
   - image processing and drop detection
   - automated drop image cropping (useful for generating data for machine learning model training)
   
**2. drop-classification**  
   - (WORK IN PROGRESS)
   
**3. drop-tracking**  
   - tabulate a series of drop parameters for each drop in **all** frames. Proposed table format:  
   
     | Frame Number  | Drop Number  | x-coordinate  | Drop Class |
     | ------------  | -----------  | ------------  | ---------- |  
   
   - query complete table to identify coalescing frame number and corresponding initial doublet frame (WORK IN PROGRESS)  
   - compute coalescence time  (WORK IN PROGRESS)  
   
 
 _NOTE: the 'Obsolete' folder in the repo is just to provide a place to store my junk files. SWC._
   
   
## Data files  
Some scripts, particularly the .mlx scripts, require data files/ folders to run.  
Where possible, the data has been uploaded to the relevant sub-folders in this repository. However,
some files/ folders are simply too large to be uploaded, so will have to be downloaded from [here](https://drive.google.com/drive/folders/1VXOg2uKROwx4l2nFKGY9KS2UDEXZLQVh?usp=sharing) instead. These will have been indicated in the relevant scripts.  

Troubleshooting: if the code fails to run, please check if the name of data files/ folders that are in your directory match that in the script.
   
   
   
