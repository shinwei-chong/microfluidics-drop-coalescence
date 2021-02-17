function R = bgGenCmplx(vid_file,n)
% Extract background image of an input video. Background image will be
% generated using a modified statistical approach, and based on a user-defined
% number of randomly selected frames. 
%
%   ----- Algorithms -----
%   i) Original version: Directly adopted from ADM concept
%   ii) Modified version: Better detection for movies with varying
%   contrast/ brightness across frame
%   *** NOTE: Choose 1 and comment out the other before running! ***
%
%   ----- Input -----
%   vid_file: video file name <char>
%   n: number of frames used for background generation <double>
%
%   ----- Output -----
%   cmplx_bg: background generated 
%
%   ----- Ref -----
%   [1] Chong et al. (2016) Automated droplet measuremetn (ADM): an
%   enhanced video processing software for rapid droplet measurements.
%   Microfluid Nanofluid.
%   [2] How to 'fill' objects at border (where imfill will not work):
%   https://blogs.mathworks.com/steve/2013/09/05/defining-and-filling-holes-on-the-border-of-an-image/
%   (accessed: 16-Feb-2021)

%   Written by: SWC. V1.1, 16-Feb-2021.


% read video 
vid = VideoReader(vid_file); 

% create index of frames to be used for background generation operation
idx = randperm(vid.NumFrames, n); % randomly select n unique frames 

disp(['Processed video: ', vid_file])

%% Original version
%  Suitable for WAT. Varying results for SDS, Tri, DYE, but much better
%  compared to 'basic' statistical methods.
%  NOT suitable for C12Tab

% first, find median pixel value across n randomly selected frames
frameMat = uint8(zeros(vid.Height,vid.Width,n)); %initialise empty matrix 
tic;

for i = 1:n
    frame = read(vid, idx(i)); %read frame 
    frameMat(:,:,i) = frame; %add frame to matrix 
end 

bg = median(frameMat,3); %median
% bg = mean(frameMat,3,'native'); %mean
Imin = double(min(bg,[],'all')); %get min pixel value
Imax = double(max(bg,[],'all')); %get max pixel value

% then, iteratively reduce background noise
% f = randperm(vid.NumFrames,3*n); % randomly select another n unique frames
f = round(linspace(1,vid.NumFrames,n)); 

Al2 = (245*(double(bg)-Imin))/(Imax-Imin) + 10;
R = bg;

for nf = 1:length(f)
    F = read(vid, f(nf));
    Fl2 = (245*(double(F)-Imin))/(Imax-Imin) + 10;
    
    D = 255.* Fl2 ./ Al2;
    D(Al2 <= 0 | Fl2 > Al2) = 255;
    D(Fl2 < 0) = 0;
%     D = mat2gray(D);
    D = rescale(D);
    
    B1 = imbinarize(D);
    B2 = imcomplement(B1);
%     figure; imshow(B2);
    
    B22 = imdilate(B2,strel('disk',7));
    B22 = imclose(B22,strel('disk',7));
%     figure; imshowpair(B2,B22);
    

    B2_fill = imfill(B22,'holes');
    % fill objects at border
    B2_fill_a = padarray(B22,[1 1],1,'pre'); 
    B2_fill_a_filled = imfill(B2_fill_a,'holes');
    B2_fill_a_filled = B2_fill_a_filled(2:end,2:end);
    
    B2_fill_b = padarray(padarray(B22,[1 0],1,'pre'),[0 1],1,'post');
    B2_fill_b_filled = imfill(B2_fill_b,'holes');
    B2_fill_b_filled = B2_fill_b_filled(2:end,1:end-1);
    
    B2_fill_c = padarray(B22,[1 1],1,'post');
    B2_fill_c_filled = imfill(B2_fill_c,'holes');
    B2_fill_c_filled = B2_fill_c_filled(1:end-1,1:end-1);
    
    B2_fill_d = padarray(padarray(B22,[1 0],1,'post'),[0 1],1,'pre');
    B2_fill_d_filled = imfill(B2_fill_d,'holes');
    B2_fill_d_filled = B2_fill_d_filled(1:end-1,2:end);

    B2_fill = B2_fill | B2_fill_a_filled | B2_fill_b_filled | B2_fill_c_filled | B2_fill_d_filled;
    
%     B2_fill = bwconvhull(B22,'object');
%     B2_fill = bwareaopen(B2_fill,800);


    A2 = regionprops('table',B2_fill,'BoundingBox');
%     se = strel('disk', round(0.3*min(A2.BoundingBox(:,3))));
    B2_dilate = imdilate(B2_fill,strel('disk',0));
%     figure; imshowpair(B2_fill, B2_dilate);
    M2 = uint8(double(R).*double(B2_dilate));
    
    B1_dilate = imcomplement(B2_dilate);
    M1 = uint8(double(B1_dilate).*double(F));

    
    R = M1+M2;
    
    
%     figure; montage({M1, M2, R},'Size',[1,3]);
end

toc;

%% Modified version: Attempt to adapt for movies with varying brightness across frame
% % Suitable for WAT, DYE. 
% % Most suitable algorithm for C12Tab, however, still not perfect.
% % Mixed results for TRI & SDS videos --> further evaluation required.
% 
% tic;
% 
% frameMat = uint8(zeros(vid.Height, vid.Width, 40)); %original
% frameMat2 = zeros(vid.Height, vid.Width, 40); %filtered
% 
% for i = 1:n
%     frame = read(vid, idx(i)); %read frame 
%     frameMat(:,:,i) = frame; %add frame to matrix 
%     
%     adframe = imadjust(stdfilt(im2double(frame)));
%     frameMat2(:,:,i) = adframe; %add frame to matrix
% end 
% 
% % initial background image
% bg = median(frameMat,3); 
% adbg = median(frameMat2,3);
% 
% Imin = double(min(adbg,[],'all')); %get min pixel value
% Imax = double(max(adbg,[],'all')); %get max pixel value
% 
% % then, iteratively reduce background noise
% f = randperm(vid.NumFrames,n); % randomly select another n unique frames
% 
% R = bg;
% 
% for nf = 1:length(f)
%     F = read(vid, f(nf));
%     adF = imadjust(stdfilt(im2double(F)));
%     
%     D = imadjust(imsubtract(adF,adbg));
%     that = imtophat(D,strel('diamond',10));
%     bhat = imbothat(D,strel('diamond',10));
%     adD = D+that-bhat;
%     adD(adD<0) = 0; 
%     adD(adD>1) = 1;
%     
%     B1 = imbinarize(adD);
% %     B2 = imcomplement(B1);
% %     figure; imshow(B1);
%     B1 = imdilate(B1,strel('disk',7));
%     B1 = imclose(B1,strel('disk',7));
% %     figure; imshow(B1);
% 
%     B2_fill = imfill(B1,'holes');
%     
%     % fill objects at border
%     B2_fill_a = padarray(B1,[1 1],1,'pre'); 
%     B2_fill_a_filled = imfill(B2_fill_a,'holes');
%     B2_fill_a_filled = B2_fill_a_filled(2:end,2:end);
%     
%     B2_fill_b = padarray(padarray(B1,[1 0],1,'pre'),[0 1],1,'post');
%     B2_fill_b_filled = imfill(B2_fill_b,'holes');
%     B2_fill_b_filled = B2_fill_b_filled(2:end,1:end-1);
%     
%     B2_fill_c = padarray(B1,[1 1],1,'post');
%     B2_fill_c_filled = imfill(B2_fill_c,'holes');
%     B2_fill_c_filled = B2_fill_c_filled(1:end-1,1:end-1);
%     
%     B2_fill_d = padarray(padarray(B1,[1 0],1,'post'),[0 1],1,'pre');
%     B2_fill_d_filled = imfill(B2_fill_d,'holes');
%     B2_fill_d_filled = B2_fill_d_filled(1:end-1,2:end);
% 
%     B2_fill = B2_fill | B2_fill_a_filled | B2_fill_b_filled | B2_fill_c_filled | B2_fill_d_filled;
% 
% %     B2_fill = bwconvhull(B1,'object');
%     B2_dilate = imdilate(B2_fill,strel('disk',0));
%     M2 = uint8(double(B2_dilate).*double(R));
%     
%     B1_dilate = imcomplement(B2_dilate);
%     M1 = uint8(double(F).*double(B1_dilate));
%     
%     R = M1+M2;
%     
% %     figure; montage({M1, M2, R},'Size',[1,3]);
% end
% 
% toc;

end

