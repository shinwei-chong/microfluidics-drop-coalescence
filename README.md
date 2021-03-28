# Estimating Drop Coalescence Time in Microfluidics
2020/21 MEng Research Project

## Aim
To develop a MATLAB-based tool for processing experimental videos containing drop coalescence events to predict the drop coalescence time.

![coalescence_time_illustration](https://user-images.githubusercontent.com/70296319/112756579-d04a3280-8fdd-11eb-8806-c54b0c225598.JPG)



## Contents
The project repository is split into the following parts:  

**1. video-processing**  
   - extract individual frames from video 
   - image processing and drop detection
   - crop drop images 
   - exports a spreadsheet containing drop properties required for computing coalescence time

   ![bboxvis-gif](https://user-images.githubusercontent.com/70296319/112756335-96c4f780-8fdc-11eb-94ff-ff44d2c5bf07.gif)
   
**2. drop-classification**  
   - training image dataset was increased by performing data augmentation
   - trained SVM and CNN models 
   - CNN model used to classify drop image as one of singlet, doublet or coalesced
   - exports a spreadhseet containing predicted class label for each drop
   
**3. drop-tracking**  
   - tabulated data containing the following columns is required:
   
     | Frame Number  | Drop Number  | centroid x-coordinate | centroid y-coordinate  | Drop Class |  
     | ------------  | -----------  | --------------------  | ---------------------- | ---------- |  
     
   
   - query table to identify coalescing frame number and corresponding initial doublet frame 
   - compute coalescence time   
   
 
   
