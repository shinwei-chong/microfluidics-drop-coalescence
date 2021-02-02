# Estimating Droplet Coalescence Time in Microfluidics
2020/21 MEng Research Project

## Aim
To develop a MATLAB-based tool for processing experimental videos containing droplet coalescence events to predict the droplet coalescence time.

## Contents
The project repository will be split into the following parts:  

**1. video-processing**  
   - extract individual frames from video 
   - image processing and drop detection
   - automated drop image cropping (useful for generating data for machine learning model training)
   
**2. drop-classification**  
   - (WORK IN PROGRESS..)
   
**3. drop-tracking**  
   - tabulate a series of drop parameters for each drop in **all** frames. Proposed table format:  
   
     | Frame Number  | Drop Number  | x-coordinate  | Drop Class |
     | ------------  | -----------  | ------------  | ---------- |  
   
   - query complete table to identify coalescing frame number and corresponding initial doublet frame
   - compute coalescence time
   
   
