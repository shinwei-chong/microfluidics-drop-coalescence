## Script Files  
+ ***Analysis_bgGen_Basic.mlx***  
Compare the background image generated based on median / mode / mean pixel intensity.  
+ ***Analysis_bgGen_Complex.mlx***  
Compare the background image generated based on a more complex statistical approach.  
+ ***Analysis_bgSubtraction.mlx***  
Compare different background subtraction methods (absolute diff. / standard diff. / standard diff. + inversion).  
+ ***Analysis_dropSegmentation.mlx***  
Compare different thresholding & edge detection (Canny, Sobel) methods to binarise image.  

+ ***dropCrop_TEST.mlx***  
Workthrough of the full video pre-processing steps to crop drop images. Also used as debugger. 

## Function Files  
+ ***bgGenBasic.m***  
Function to generate and plot background images using median, mode and mean statistical approach.  
+ ***bgGenCmplx.m***  
Function to generate and plot background images using a more complex statistical approach - 
2 version: i) Original algorithm adopted from Automated Droplet Measurement concept (Chong et al., 2016), 
ii) Modified algorithm to allow application on lower contrast videos (e.g., C12 Tab)  
+ ***fill_border_drops.m***  
Function to apply _imfill()_ function to object touching frame borders. ***(Function file located in video-processing main folder)***  
+ ***segDrop.m***  
Function to create a binary mask indicating location of drops in frame; based on Otsu's method for thresholding. ***(Function file located in video-processing main folder)***  

## Test Cases  
+ **Water-only**  
   **WAT001**: SO5_13umL-7Wat_umL-10kfps x4mag_sh50_C001H001S0006.avi  
   **WAT002**: SO5_13umL-7Wat_umL-10kfps x4mag_sh50_C001H001S0023.avi  
   **WAT003**: SO5_13umL-7Wat_umL-10kfps x4mag_sh50_C001H001S0057.avi  
   **WAT004**: SO5_17umL-13Wat_umL-10kfps x4mag_sh50_C001H001S0016.avi  
   **WAT005**: SO5_17umL-13Wat_umL-10kfps x4mag_sh50_C001H001S0036.avi  
   **WAT006**: SO5_17umL-13Wat_umL-10kfps x4mag_sh50_C001H001S0041.avi

+ **SDS**  
   **SDS001**: SO5cSt 12 uL_23 uL SDS_50 mM 062.avi  
   **SDS002**: SO5cSt 12 uL_23 uL SDS_50 mM 051.avi  
   **SDS003**: SO5cSt 12 uL_23 uL SDS_50 mM 046.avi  
   **SDS004**: SO5cSt 12uL_23 uL SDS_10 mM 018.avi  
   **SDS005**: SO5cSt 12uL_23 uL SDS_10 mM 061.avi  
   **SDS006**: SO5cSt 12uL_23 uL SDS_10 mM 055.avi

+ **Triton**  
   **TRI001**: SO5cSt 12.5uL_21.5 uL TRITON_ 5 mM 032.avi  
   **TRI002**: SO5cSt 16uL_15 uL TRITON_0.5 mM 011.avi  
   **TRI003**: SO5cSt 10uL_12 uL TRITON_0.5 mM 04.avi  
   **TRI004**: SO5cSt 9uL_15 uL TRITON_ 5 mM 016.avi  
   **TRI005**: SO5cSt 14uL_19 uL TRITON_ 50 mM 032.avi  
   **TRI006**: SO5cSt 10uL_12 uL TRITON_ 50 mM 022.avi 

+ **C12 Tab**  
   **C12T001**: SO5cSt 22.5uL__52 uL C12TAB_10mM   PDMS500 10kfps x4mag_sh50_C001H001S0034.avi  
   **C12T002**: SO5cSt 16.5uL__35 uL C12TAB_10mM   PDMS500 10kfps x4mag_sh50_C001H001S0004.avi  
   **C12T003**: SO5cSt 8.5uL__16.3 uL C12TAB_10mM   PDMS500 10kfps x4mag_sh50_C001H001S0013.avi  
   **C12T004**: SO5cSt 12uL_23 uL C12TAB_50mM  17.avi  
   **C12T005**: SO5cSt 12uL_23 uL C12TAB_50mM  27.avi  
   **C12T006**: SO5cSt 8.5uL_16 uL C12TAB_50mM 14.avi  

+ **Dyed-drops**  
   **DYE001**: S.O.5 cSt 17 e  13 DYE -10kfps x4mag_sh50_C001H001S0008.avi  
   **DYE002**: S.O.5 cSt 13 e  7 DYE -10kfps x4mag_sh50_C001H001S0012.avi  
   **DYE003**: 52%Gl_W_0.003_Ink_SO_SPAN80_0.003_2kfps_.avi  
