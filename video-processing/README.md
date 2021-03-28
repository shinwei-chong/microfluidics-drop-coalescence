# Part 1: Video Processing

This section focuses on processing raw experimental videos to prepare data for machine learning classification model.  

## Main Scripts   
+ ***dropCropMULTI.m***  
   Script to process videos and generate cropped drop images (default dimensioins: 128128 pix<sup>2</sup>) as input to machine learning model.  

+ ***bboxVis.m***  
   Script to process videos and generate a new video with bounding boxes visualised.  
   Example output [here](https://drive.google.com/file/d/1jf9_tMAYZ_aVIAc4yB-KxjehLqjHWsHe/view?usp=sharing).  
   Output from processing a series of test cases (videos of drops with different surfactant types)
 found in zipped folders on GoogleDrive [here](https://drive.google.com/drive/folders/1VXOg2uKROwx4l2nFKGY9KS2UDEXZLQVh?usp=sharing)

## Function Files   
+ ***bgGenBasic.m***  
   Generate background image based on basic statistical approach (median/ mode/ mean)  
   
+ ***bgGenCmplx.m***  
   Generate background image based on a modified statistical approach. Adopted from: Automated Droplet Measurement (ADM) Concept. Chong et al., 2016.  
   
+ ***fill_border_drops.m***  
   Fill objects touching the frame border (as could not be done just by applying _imfill( )_).  
   
+ ***segDrop.m***  
   Segment drops from a frame, creating a binary mask to indictate location of drops.


