# Part 1: Video Processing

This section focuses on processing raw experimental videos to prepare data for machine learning classification model.  

## Test Scripts - contain notes and visualisation of processing steps  
+ ***preprocessing_workflow_InitialTEST.mlx***  
   Initial test of image processing steps on (pre-)extracted video frames (image binarisation), then obtaining information on the bounding box of drops.    

+ ***labeldrops_TEST.mlx***  
   Combine video frames extraction function with image processing workflow, so code can run directly given a user-input video. Final output is a video with bounding boxes overlaid onto the footage.  

+ ***dropCrop_TEST.mlx***  
   Shows step-by-step the processing and cropping of drop images. Also used as debugger.

## Function Files - used in test scripts  
+ ***extractVidFrames.m***  
   Extract and save video frames in a new folder

+ ***vidFramePreprocess.m***  
   Process video frames to detect drops (ROIs). Bounding boxes are then overlaid onto original frames, 
   which are then saved to a new folder.

+ ***createVid.m***  
   Generate a new video from a folder of video frames. 

## Main Scripts - complete scripts for deployment  
+ ***dropCropMULTI.m***  
   'Plug-and-play' script to process videos and generate cropped drop images (default dimensioins: 128x128 pix<sup>2</sup>) ready for machine learning model.  
   Example output folder (naming convention: framenumber_dropnumber):  
   <img src="https://drive.google.com/uc?export=view&id=1NIE_mHDYfKwMYoeB8Z60xxdlIwrCD4TP" width="716.5" height="512.5">

+ ***bboxVis.m***  
   'Plug-and-play' script to process videos and generate a new video with bounding boxes visualised.  
   Example output [here](https://drive.google.com/file/d/1jf9_tMAYZ_aVIAc4yB-KxjehLqjHWsHe/view?usp=sharing)
