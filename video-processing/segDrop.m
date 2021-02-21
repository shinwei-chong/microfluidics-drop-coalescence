function L = segDrop(Im)
% Function to segment drops following background subtraction. 
% 
% ----- Input -----
% Im: background-subtracted video frame 
%
% ----- Output -----
% L: binary mask matrix used to indicate locations of drops

% Written by: SWC. V1.0, 17-Feb-2021.


% tic; 



%%
% ----- binarize image -----
adIm = imadjust(Im); %saturate image
bin  = imbinarize(adIm, graythresh(Im)); % binarize using threshold from Otsu's method
% figure; imshow(bin); 

% !!! FOR C12Tab videos use this: 
% adIm = imadjust(stdfilt(Im)); %filter + saturate image
% thresh = graythresh(Im); %get threshold value using Otsu method 
% bin = imbinarize(adIm, 0.75*thresh); %convert to binary image

%% COMMENTED OUT: 20-Feb-2021. alternative approach to binarisation --> but output image not as 'sharp'
% Aa = imfilter(Im,fspecial('disk',8));
% Ab = imfilter(Im,fspecial('disk',5));
% thresh = graythresh(Aa-Ab);
% Ac = (Aa-Ab)>(thresh.*0.4);
% Ad = imfill(Ac,'holes');
% L = imerode(Ad,strel('diamond',3));
% L = bwareaopen(Ae,150); 
%%

% ----- initial morphological fill -----
bin1 = imclose(bin, strel('disk',2)); %close tiny holes
fill1 = imfill(bin1,'holes'); %fill fully closed drops; only drops not intersecting border will be filled.
% fill1_bord = fill_border_drops(bin); % fill fully closed drops at border
% fill1 = fill1 | fill1_bord;
% figure; imshow(fill1);

% ----- morphological close and fill drops with larger holes in drop outline -----
minA = 50; % anything with area less than this will be treated as noise object
cfill1 = bwareaopen(fill1,minA); 
% figure; imshow(cfill); 

rg = regionprops('table',cfill1,'Area'); %detect ROI
[bwl n] = bwlabel(cfill1,8); %assign label to each detected ROI
% n %debugging: check number of regions detected

segA = 0.2*max(rg.Area); %assume ROIs with area < segA are unfilled due to presence of
% of discontinuity in drop edges.
pos = find(rg.Area < segA); %find ROIs with area < segA

bwl2 = ismember(bwl,pos); %segment out ROIs that need further manipulation (morphological close)

global leadEdge
bwl2(:, 1:leadEdge) = 0; %remove drops outside of main channel

bwl2 = imclose(bwl2,strel('disk',15)); %morphological close 
fill2 = imfill(bwl2,'holes'); %fill fully closed drops (drops at border not filled!)
% figure; imshow(fill2)
fill2_bord = fill_border_drops(bwl2); % fill objects at border 
% figure; imshow(fill2_bord)
fill2 = fill2 | fill2_bord; %resulting filled image
% figure; imshow(fill2);

L = cfill1 | fill2; %combine to form a final mask
% figure; imshow(L); 

% ----- attempt to separate drops that might have been incorrectly fused
% together in previous processing steps -----
L = imerode(L,strel('diamond',3));

%% COMMENTED OUT: 20-Feb-2021. Too difficult to balance between over-eroding and over-dilating 
% L = imdilate(L, strel('diamond',3)); 
% L = imfill(L,'holes'); 
% L = imerode(L, strel('diamond',6));
%%

% toc; 

end

