function Im_fill = fill_border_drops(Im)
% Funtion to morphologicallly fill drops at the border  
% 
% ----- Input -----
% Im = binary image to be processed
%
% ----- Output -----
% Im_fill = binary mask of drops at boder of video frame
%
% ----- Ref -----
% [1] How to 'fill' objects at border (where imfill will not work):
% https://blogs.mathworks.com/steve/2013/09/05/defining-and-filling-holes-on-the-border-of-an-image/
% (accessed: 16-Feb-2021)


% Written by: SWC. V1.0, 18-Feb-2021.

A = padarray(Im,[1 1],1,'pre');
A = imclose(A,strel('rectangle',[5 5]));
A_fill = imfill(A,'holes');
A_fill = A_fill(2:end,2:end);

B = padarray(padarray(Im,[1 0],1,'pre'),[0 1],1,'post');
B = imclose(B,strel('rectangle',[5 5]));
B_fill = imfill(B,'holes');
B_fill = B_fill(2:end,1:end-1);

C = padarray(Im,[1 1],1,'post');
C = imclose(C,strel('rectangle',[5 5]));
C_fill = imfill(C,'holes');
C_fill = C_fill(1:end-1,1:end-1);

D = padarray(padarray(Im,[1 0],1,'post'),[0 1],1,'pre');
D = imclose(D,strel('rectangle',[5 5]));
D_fill = imfill(D,'holes');
D_fill = D_fill(1:end-1,2:end);

Im_fill = A_fill | B_fill | C_fill | D_fill; 

end

