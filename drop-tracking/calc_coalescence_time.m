function calc_coalescence_time()
%SUMMARY: function to identify coalescence events and compute the corresponding 
% coalescence times from tabulated drop parameters.
%
% USER NOTES: 
% 1) For each video, tabulated drop data should be in .xlsx format and 
%    contain the following columns:
%   - frame number 
%   - drop number 
%   - x-coordinate of centroid
%   - y-coordinate of centroid
%   - ML predicted drop class (1 = coalesced, 2 = doublet, 3 = singlet)
% 2)Use dropCropMULTI.m script file (pre-processing step) to generate
%   spreadsheet containing frame number, drop number, x-coordinate of
%   centroid and y-coordinate of centroid. Use ClassifyFrames.m script file 
%   (ML image classfication step) to generate spreadsheet containing
%   predicted drop class. Then, will need to manually combine both
%   spreadsheet to be used with this function file.
% 3)Frame rate (fps) needs to be manually defined - variable is found towards end of script
%   Default value: 30 fps 
%
%
% HIGH-LEVEL WORKFLOW: 
% 1)Determine all predicted points of coalescence and separate into
%   individual coalescence event
% 2)For each identified coalescence event, start from the final frame in
%   which coalescence is detected, map back to previous frames and stop when
%   drop is identified as a singlet. 
%   Underpinning principle: coalesced drops must have previously been a
%   doublet, which were in turn formed from single drops.


% Written by: SWChong, 06-Mar-2021. V1.1 

%% read all .xlsx files in the filepath

xcel_idx = dir('*.xlsx.'); 

%% start of process 
for i = 1: numel(xcel_idx) %loop through each excel spreadsheet in directory
    
    tic; % start timer 
    
    %% ===== read table =====
    xcel_name = xcel_idx(i).name; %get file name
%     xcel_name = 'test002_TRITON_datatable_v2.xlsx'; %model data for
%     script development 
    disp(['Processing: ', xcel_name])
    
    tab = readtable(xcel_name, "VariableNamingRule","preserve"); 
%     size(tab) %%%troubleshoot: print table size

    %% ===== find 'coalescing' drops (predicted class == 1) =====
    pos = find(tab.Class == 1); %NOTE:column must be named 'Class'
    
    %%||- GATE -||: stop code if no coalesced drops found
    if pos == [];
        disp('No coalescence event found!'); 
        continue 
    end
    
    %create new table of 'coalescing' drops
    coal_drops = tab(pos,:); 
    
    %% ===== separate the different coalescence events =====
    % for when there are multiple coalescence events identified in a video
    
    % calculate euclidean distance of drops between frames 
    centroidVec = [coal_drops.xCentroid coal_drops.yCentroid];
    diff2 = (centroidVec(2:end, :) - centroidVec(1:end-1, :)).^2;
    euclid_dist = sqrt(sum(diff2,2)); %%%troubleshoot: print distance to check
    
    % find index to split table (into separate coalescence events)
    % by inspection, a drop travels less than 1 pix per frame
    uniq_idx = find(euclid_dist > 2); %RUN MORE TESTS IF HAVE TIME: is this robust enough?
    uniq_idx = [1 uniq_idx+1]; %manipulation step (prep for for loop)
    numUniq = length(uniq_idx); %number of unique coalescence events
    
    uniq_coal = cell(numUniq,1); %preallocate dimensions 
    for j = 1:numUniq
        %create cell array that contains tables; each cell begining with
        %index unique_idx(j) of 'coal_drops' table, ending at idx(j+1)
        
        if j ~= numUniq %if not last pass
            uniq_coal{j,:} = coal_drops(uniq_idx(j):uniq_idx(j+1)-1, :);
        else 
            uniq_coal{j,:} = coal_drops(uniq_idx(j):end, :);
        end
    end
    
    %% ===== perform backracking search for each coalescence event =====
    
    %preallocate vectors 
    frame = cell(numUniq, 1); %frame number
    coord = cell(numUniq, 1); %x & y coordinates of drop centroid
    drop_class = cell(numUniq, 1); %drop class 
    
    for k = 1:numUniq
        disp(sprintf('----- Coalescence event #%d -----',k))
        
        z = 1; %initiate counter
    
        %get starting point for search 
        frame{k}(z) = uniq_coal{k}{end,1}; %1st col: frame num 
        coord{k}(z,:) = uniq_coal{k}{end,3:4}; %3rd col: x-coord; 4th col: y-coord
        drop_class{k}(z) = uniq_coal{k}{end,5}; %5th col: drop class
        
        %%===== find first frame of coalescence =====
        %keep going back one frame until it is no longer a coalescence drop
        while drop_class{k} == 1
            frame{k}(z+1) = frame{k}(z) - 1; %get previous frame number
            
            %||--GATE--||: Algorithm will stop search when
            %there are no more frames to backtrack to!
            if frame{k}(z+1) == 0
                fprintf('Doublet already formed before start of video; \nDoublet formation frame could not be identified! \n');
                break 
            end
                        
            drop_info = tab(tab.("Frame#") == frame{k}(z+1), :); %get information of all drops in that frame
            
            %calculate euclidean distance 
            drop_diff2 = (coord{k}(z,:) - drop_info{:, 3:4}).^2; 
            drop_euclid = sqrt(sum(drop_diff2, 2)); 
            [minDist, idx] = min(drop_euclid); %get index of closest drop
            
            match_drop = drop_info(idx,:); %get information of matching drop 
            drop_class{k}(z+1) = match_drop.Class; 
            coord{k}(z+1,:) = [match_drop.xCentroid match_drop.yCentroid];
            z = z+1; %increase counter
        end
        
%         % skip this coalescence event and go to next one
%         if frame{k}(z+1) == 0     
%             continue
%         end
        
%         [frame' coord' drop_clas']


        %%||- GATE - ||: Make sure it is a 'true' coalescence event 
        % presume that  drop must be a doublet (class = 2) in the frame
        % before initial coalescence frame.
        % so, if drop was thought to have gone directly from singlet (class
        % = 3) to coalesced (class = 1), then remove from analysis.
        if drop_class{k}(end) ~= 2  %if drop in last frame before initial coalescence is NOT doublet
            disp('This might be a false coalescence event - not analysed');
            continue 
        end 
        
        
        coalescence_frame = frame{k}(end) + 1       
        
        
        %%===== find corresponding doublet formation frame =====
        %keep going back one frame until drop is no longer a doublet 
        while drop_class{k} ~= 3
            frame{k}(z+1) = frame{k}(z) - 1; %get previous frame number
            
            if frame{k}(z+1) == 0
                fprintf('Doublet already formed before start of video; \nDoublet formation frame could not be identified! \n');
                break 
            end
            
            drop_info = tab(tab.("Frame#") == frame{k}(z+1), :); %get information of all drops in that frame
            
            %calculate euclidean distance
            drop_diff2 = (coord{k}(z,:) - drop_info{:, 3:4}).^2;
            drop_euclid = sqrt(sum(drop_diff2, 2));
            [minDist, idx] = min(drop_euclid); %get index of closest drop
            
            match_drop = drop_info(idx,:); %get information of matching drop
            drop_class{k}(z+1) = match_drop.Class;
            coord{k}(z+1,:) = [match_drop.xCentroid match_drop.yCentroid];
            z = z+1; %increase counter
            
            
        end
        
        if frame{k}(end) >= 1
            doublet_formation_frame = frame{k}(end) + 1 
            
        %%===== calculate coalescence time =====
            framerate = 30; %<------- user-defined value
            coalescence_time = (coalescence_frame - doublet_formation_frame)/ framerate
            
            full_search_table = array2table([frame{k}' coord{k} drop_class{k}'],...
                'VariableNames',{'Frame#', 'x-coord', 'y-coord', 'drop class'}) 
        end
        
        
    end
    
    toc; %stop timer
end

end

