# Part 3: Frame Correlation and Drop Tracking 

This section focuses on: 
* tabulating relevant drop parameters required, then 
* querying table to identify the coalescence frame and corresponding initial doublet formation frame. 
* Finally, the coalescence time can be computed.  

Proposed workflow (WORK IN PROGRESS):  
<img src="https://drive.google.com/uc?export=view&id=1wcietq-Nsedbjzo2_QkUyTxgAUNwFn2U">



## Test Script
* ***droptracking_test.mlx***  
   Test code for drop tracking. So far have tabulated drop parameters, next step is to write algorithm for 'backtracking' step.
   
## Associated Data Files    
* ***1.jpg***  
Used for testing operation with single frame

* ***extractedFrames_1***  
Used for testing operation for full video. Folder contains **all** extracted frames from video: ***SO5_17umL-13Wat_umL-10kfps x4mag_sh50_C001H001S0016.avi***.  
NOTE: video too large to be uploaded so will need to be downloaded separately (available at Nina's shared drive)

## Associated Output Files
* ***test001_datatable***  
Data table exported from operation with full video (drop class labels randomly assigned at this stage, as not integrated with machine learning classification model yet)

* ***test001_datatable***  
Data table manually labelled with correct labels. Will be used to develop query algorithm
