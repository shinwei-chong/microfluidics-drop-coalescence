# Part 1: Video Processing

## Summary  
This section focuses on processing raw experimental videos to prepare data for machine learning classification model, and consists of 2 main steps:  
* extracting individual video frames from an input video   
* applying a series of image processing steps to each frame to detect and crop drops  

Sequence of image processing steps (where multiple options are possible in a given step, the default option is highlighted by the red dotted lines):  
A) start by loading an original video frame image to be processed  
B) a background image is pre-generated using a numnber of frames across the video  
C) the background image is subtracted from the original video frame  
D) the image is converted into a binary image  
E) a series of mathematical morphological operations are performed to create a binary mask indicating the area of the drops  
F) the drops are detected using computer vision methods and their centroid and bounding drop properties are obtained; these will be used to define the crop area of the drops  

![image_processing_workflow](https://user-images.githubusercontent.com/70296319/112761178-ea8e0b80-8ff1-11eb-8220-24f702797875.JPG)


## Main Scripts   
+ ***dropCropMULTI.m***  
   Script to process videos and generate cropped drop images (default dimensioins: 128x128 pix<sup>2</sup>) as input to machine learning model.  

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


