function L = segDrop(Im)
% Function to segment drops following background subtraction. 
% 
% ----- Input -----
% Im: background-subtracted video frame 
%
% ----- Output -----
% L: binary mask matrix used to indicate locations of drops

% Written by: SWC. V1.0, 17-Feb-2021.

%%
tic; 

adIm = imadjust(stdfilt(Im)); %enhance contrast 
thresh = graythresh(Im); %get threshold value using Otsu method 
bin = imbinarize(adIm, 0.75*thresh); %convert to binary image

fill1 = imfill(bin,'holes'); %fill fully closed drops; only drops not intersecting border will be filled.
% fill1_bord = fill_border_drops(bin); % fill fully closed drops at border
% fill1 = fill1 | fill1_bord;
% figure; imshow(fill1);

minA = 50; % anything with area less than this will be treated as noise object
cfill1 = bwareaopen(fill1,minA); 

rg = regionprops('table',cfill1,'Area'); %detect ROI

[bwl n] = bwlabel(cfill1,8); %assign label to each detected ROI
% n %debugging: check number of regions detected
 

pos = find(rg.Area < 2000); %find ROIs that have holes so have not been filled; 
% based on general observation that filled drops are >2000 pix2. 
% Note however, some un-closed drops have area > 2000 pix2
bwl2 = ismember(bwl,pos); %segment out ROIs that need further manipulation (morphological close)
bwl2 = imclose(bwl2,strel('disk',20)); %morphological close 
fill2 = imfill(bwl2,'holes'); %fill fully closed drops (drops at border not filled!)
% figure; imshow(fill2)
fill2_bord = fill_border_drops(bwl2); % fill objects at border 
% figure; imshow(fill2_bord)
fill2 = fill2 | fill2_bord; %resulting filled image
% figure; imshow(fill2);

L = fill1 | fill2; %combine to form a final mask
% figure; imshow(L); 

L = imerode(L,strel('diamond',3));
% L = imdilate(L, strel('diamond',3)); 
% L = imfill(L,'holes'); 
% L = imerode(L, strel('diamond',6));

toc; 

%% alternative approach to binarisation --> but output image not as 'sharp'
% Aa = imfilter(Im,fspecial('disk',8));
% Ab = imfilter(Im,fspecial('disk',5));
% thresh = graythresh(Aa-Ab);
% Ac = (Aa-Ab)>(thresh.*0.4);
% Ad = imfill(Ac,'holes');
% L = imerode(Ad,strel('diamond',3));
% L = bwareaopen(Ae,150); 

end

