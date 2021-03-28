# Part 3: Frame Correlation and Coalescence Time Calculation
 
The previous steps give the following useful parameters for calculating the drop coalescence time:   
   * drop frame number   
   * drop number   
   * x-coordinate of drop centroid   
   * y-coordinate of drop centroid   
   * predicted drop class   

![drop_properties_table_eg](https://user-images.githubusercontent.com/70296319/112760655-b9144080-8fef-11eb-9cd2-384090f20e94.JPG)

This section is split into two parts:  
   1) identification of all unique coalaescence events in the processed video   
   2) analysis of the coalescence events one at a time, to calculate the corresponding coalescence time  

Decision tree for computing coalescence time of a singlet coalescence event:   

![coalescence_time_calc_flowchart](https://user-images.githubusercontent.com/70296319/112760479-07750f80-8fef-11eb-8ce9-64071096e6f9.JPG)


