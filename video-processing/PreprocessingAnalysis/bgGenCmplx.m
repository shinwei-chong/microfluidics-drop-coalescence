function R = bgGenCmplx(vid_file,n,method)
% Extract background image of an input video. Background image will be
% generated using a modified statistical approach, and based on a user-defined
% number of randomly selected frames. 
%
%   ----- Algorithms -----
%   i) Standard (Original) version: Directly adopted from ADM concept.
%   Recommended for:WAT.
%   Suitable for: TRI, SDS, DYE.
%   ii) Modified version: Better detection for movies with varying
%   contrast/ brightness across frame. 
%   Recommended for: C12Tab.
%   Suitable for: WAT, TRI, SDS.
%
%   ----- Input -----
%   vid_file: video file name <char>
%   n: number of frames used for background generation <double>
%   method: 'standard' for original algorithm / 'modified' for adapted
%   version <char>
%
%   ----- Output -----
%   cmplx_bg: background generated 
%
%   ----- Ref -----
%   [1] Chong et al. (2016) Automated droplet measuremetn (ADM): an
%   enhanced video processing software for rapid droplet measurements.
%   Microfluid Nanofluid.

%   Written by: SWC. V1.2, 17-Feb-2021.
%%

% read video 
vid = VideoReader(vid_file); 

% create index of frames to be used for background generation operation
idx = randperm(vid.NumFrames, n); % randomly select n unique frames 

disp(['Processed video: ', vid_file])

%%

switch method
 
 % -------------------------- ORIGINAL -------------------------------
    case 'original'
    %  Suitable for WAT. Varying results for SDS, Tri, DYE, but much better
    %  compared to 'basic' statistical methods.
    %  NOT suitable for C12Tab
        
        disp('Using standard algorithm...'); 
    
        % --- first, find median pixel value across n randomly selected frames
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

        % --- then, iteratively reduce background noise
        f = randperm(vid.NumFrames,3*n); % randomly select another n unique frames
%         f = round(linspace(1,vid.NumFrames,n)); % choose linearly spaced frames

        Al2 = (245*(double(bg)-Imin))/(Imax-Imin) + 10; 
        R = bg; %background image

        for nf = 1:length(f)
            F = read(vid, f(nf));
            Fl2 = (245*(double(F)-Imin))/(Imax-Imin) + 10;
    
            D = 255.* Fl2 ./ Al2; %background division performed (instead of background subtraction)
            D(Al2 <= 0 | Fl2 > Al2) = 255;
            D(Fl2 < 0) = 0;
%             D = mat2gray(D);
            D = rescale(D);
    
            B1 = imbinarize(D);
            B2 = imcomplement(B1);
%           figure; imshow(B2);
    
            B22 = imdilate(B2,strel('disk',7));
            B22 = imclose(B22,strel('disk',7));
%           figure; imshowpair(B2,B22);
    
            B2_fill = imfill(B22,'holes'); % fill objects other than those touching border
            B2_fill_bord = fill_border_drops(B22); % fill objects at border
            B2_fill =  B2_fill | B2_fill_bord; % final filled image
           
%             A2 = regionprops('table',B2_fill,'BoundingBox');
%             se = strel('disk', round(0.3*min(A2.BoundingBox(:,3))));
%             B2_dilate = imdilate(B2_fill,strel('disk',0));
%             figure; imshowpair(B2_fill, B2_dilate);
            
            M2 = uint8(double(R).*double(B2_fill));

            B1_fill = imcomplement(B2_fill);
            M1 = uint8(double(B1_fill).*double(F));


            R = M1+M2; %updated background image

%             figure; montage({M1, M2, R},'Size',[1,3]);
        end

        toc;

% ------------------------------ MODIFIED ------------------------------        
    case 'modified'
    % Modified version: Attempt to adapt for movies with varying brightness across frame
    % Suitable for WAT, DYE. 
    % Most suitable algorithm for C12Tab, however, still not perfect.
    % Mixed results for TRI & SDS videos --> further evaluation required.

        
        disp('Using modified algorithm...'); 
        
        frameMat = uint8(zeros(vid.Height, vid.Width, 40)); %original
        frameMat2 = zeros(vid.Height, vid.Width, 40); %filtered
        
        tic;
        
        for i = 1:n
            frame = read(vid, idx(i)); %read frame 
            frameMat(:,:,i) = frame; %add original frame to matrix 

            adframe = imadjust(stdfilt(im2double(frame)));
            frameMat2(:,:,i) = adframe; %add filtered frame to matrix
        end 

        % ----- initial background image
        bg = median(frameMat,3); 
        adbg = median(frameMat2,3);

        Imin = double(min(adbg,[],'all')); %get min pixel value
        Imax = double(max(adbg,[],'all')); %get max pixel value

        % ----- then, iteratively reduce background noise
        f = randperm(vid.NumFrames,n); % randomly select another n unique frames
%         f = round(linspace(1,vid.NumFrames,n)); % choose linearly spaced
%         frames. 
        
        R = bg;%initial background

        for nf = 1:length(f)
            F = read(vid, f(nf));
            adF = imadjust(stdfilt(im2double(F))); % filter and saturate

            D = imadjust(imsubtract(adF,adbg)); %background subtraction
            % try to further enhance contrast
            that = imtophat(D,strel('diamond',10));
            bhat = imbothat(D,strel('diamond',10));
            adD = D+that-bhat;
            adD(adD<0) = 0; 
            adD(adD>1) = 1;

            B1 = imbinarize(adD);
        %     B2 = imcomplement(B1);
        %     figure; imshow(B1);
            B1 = imdilate(B1,strel('disk',7));
            B1 = imclose(B1,strel('disk',7));
        %     figure; imshow(B1);

            B2_fill = imfill(B1,'holes');
            B2_fill_bord = fill_border_drops(B1); % fill objects at border
            B2_fill =  B2_fill | B2_fill_bord; % final filled image

            M2 = uint8(double(B2_fill).*double(R));

            B1_fill = imcomplement(B2_fill);
            M1 = uint8(double(F).*double(B1_fill));

            R = M1+M2;

        %     figure; montage({M1, M2, R},'Size',[1,3]);
        end

        toc;

end


end
