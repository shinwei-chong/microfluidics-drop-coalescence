# Part 1: Video Processing

This section focuses on processing raw experimental videos to prepare data for machine learning classification model.  

## Test Scripts  
+ ***preprocessing_workflow_InitialTEST.mlx***  
   Initial test of image processing steps on extracted video frames. 


## Main Scripts  
+ ***dropCropMULTI.m***  
   'Plug-and-play' script to process videos. Each video processed will generate two output folders - 
   one containing full extracted frames, 
   the other containing individual cropped drop images (default dimensioins: 128x128 pix<sup>2</sup>) ready for machine learning model.
