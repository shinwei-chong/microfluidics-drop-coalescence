+ ***background_generation_test.m***  
   initial script to visualise different background generation methods.
   
+ ***extractVidFrames.m***  
   Function to extract frames from a video (used in V1.0 bboxVis and dropcropMULTI)  
   
+ ***createVid.m***  
   Function file to create a new video from a folder of frames (used in V1.0 dropcropMULTI). 

+ ***preprocessing_workflow_InitialTEST.mlx***  
    Initial test of image processing steps on (pre-)extracted video frames (image binarisation), then obtaining information on the bounding box of drops.  

+ ***vidFramePreprocess.m***   
   Function to pre-process individual video frame and draw bounding boxes over identified drops. Output is a lablled image which will be saved in a user-defined directory. Used in preprocessing V1.0.

+ ***labeldrops_TEST.mlx*** 
   Combine video frames extraction function with image processing workflow, so code can run directly given a user-input video. Final output is a video with bounding boxes overlaid onto the footage.
   
+ ***dropCrop.mlx***  
   test drop cropping code on a full video (preprocessing V1.0)  
   **Associated function files**: extractVidFrames; Process4Crop; imgCrop

+ ***debugging29Jan_dropCropMULTI.mlx***  
   live script to document debugging of code for drop cropping (preprocessing V1.0).  
   **Associated data**: 1.jpg; 3456.jpg 

+ ***test_objectremoval.mlx***  
   quick test on code for object removal & some quick test to tabulate drop parameters (for application in drop-tracking scripts)  
 
   


  
   

   




