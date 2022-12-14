%%%%%%%%%%%%%%%%%% Image Stitching Using Feature Extraction and Corner Detection and Correlation Technique 
clc; clear all; close all;
im1=imread('..\Images\7\panaroma\c1.jpg');
im2=imread('..\Images\7\panaroma\c2.jpg');

methd = 'BRISK';

%%%%%%%%%%%Gray Scale Conversion for image registeration as described in paper
im1_gray = im2double(rgb2gray(im1));
im2_gray = im2double(rgb2gray(im2));

figure; 
subplot (1,2,1); imshow(im1);title('RGB Image 1');
subplot (1,2,2); imshow(im2); title('RGB Image 2');
   
% determining the size of image matrices
[row_im1,col_im1]= size (im1_gray);
[row_im2,col_im2]= size (im2_gray);
% Equalizing the dimensions of images matrices
% Select the image with the fewest rows and fill in enough empty rows to make it the same height as the other image.

if (row_im1 < row_im2)
     im1_gray(row_im2,1) = 0;
else
     im2_gray(row_im1,1) = 0;
end
%%%%%%Using SURF Points detection for matching features%%%%%%%%%%%%%%%%%%%%%
points_im1 = feval(['detect', methd,'Features'],im1_gray);
points_im2 = feval(['detect', methd,'Features'],im2_gray);

[feats_im1, vpoints_im1] = extractFeatures(im1_gray, points_im1, method=methd);
[feats_im2, vpoints_im2] = extractFeatures(im2_gray, points_im2, method=methd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Find matching points between two feats%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
indexPairs = matchFeatures(feats_im1, feats_im2, 'Method', 'Threshold');
matchedPoints_A = vpoints_im1(indexPairs(:,1),:);
matchedPoints_B =  vpoints_im2(indexPairs(:,2),:);
  
figure;bx = axes;
showMatchedFeatures(im1_gray,im2_gray,matchedPoints_A,matchedPoints_B,'montage','Parent',bx); legend(bx, 'Matched points 1 with outliers','Matched points 2 with outliers');
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%% Using RANSAC OUTLIER ELIMINATION Technique%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                         %%%% fundamental matrix is epipole
         
[TForms, Inlier_Pts_1, Inlier_Pts_2] = estimateGeometricTransform(  matchedPoints_A,  matchedPoints_B,'similarity');
figure;bx = axes;
showMatchedFeatures(im1_gray,im2_gray,Inlier_Pts_1,Inlier_Pts_2,'montage','Parent',bx); legend(bx, 'Matched points for Image 1 without Outlier ','Matched points for Image 2 without outlier ');
            
 %%%%%%%%%%%%%%%%%%Image Stitching and Mosaicing %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% Rounding of the indexes/loctaion of pixel values of matched inlier points of both images   %%%%%%%
RND_Inlier_Pts_1= round(Inlier_Pts_1.Location);
RND_Inlier_Pts_2= round(Inlier_Pts_2.Location);
% 
% %%% Since Matlab read images by row x column pattern  so finding nth row and column for first inlier points for both images %%%
%  
Min_INLPTS_1= min(RND_Inlier_Pts_1);
Min_INLPTS_2= min(RND_Inlier_Pts_2);
 
%%%% Assigning the minimum index of row and coloumn for the said images inlier points%%%%%%%
%%%% Reversing the order of matrix obtained during Outlier elimmination %%%%%%%%%%%%
%%%% As it locates the pixel values of images as column into row pattern when we used outlier elimination paptern%%%%  
min_y1 = Min_INLPTS_1(1,2);
min_x1 = Min_INLPTS_1(1,1);

min_y2 = Min_INLPTS_2(1,2);
min_x2 = Min_INLPTS_2(1,1);
  
  %%%%%% Assigning test images for the final concatenation of images %%%%%%
FinalImage1 = im1(:,1:min_x1,:);

if (min_y1 > min_y2)
    FinalImage2 =im1((min_y1-min_y2):row_im2,min_x2:col_im2 , :);
else 
    FinalImage2 =im2((min_y2-min_y1):row_im2,min_x2:col_im2 , :);
end
   
%   %%%%%%%%%% Equalizing the rows of Images%%%%%%%%
[ROW_T1,COL_T1]= size ( FinalImage1);
[ROW_T2,COL_T2]= size ( FinalImage2);
  
if (ROW_T1 > ROW_T2)
    FinalImage1 = FinalImage1(1:ROW_T2,:,:);
else
    FinalImage2 = FinalImage2(1:ROW_T1,:,:);
end
    
%%%%%%%%% Concatenating the images %%%%%%%%%
StitchedImage = [FinalImage1, FinalImage2];
      
 %%%%%%%%%Displaying of final images %%%%%%%%
figure; 
subplot (1,2,1); imshow(im1_gray);title('Test Image 1');
subplot (1,2,2); imshow(im2_gray); title('Test Image 2');

figure; 
imshow(StitchedImage); title('Stitched Image');