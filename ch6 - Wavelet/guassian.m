img = rgb2gray(imread('..\Images\6\Lena.bmp'));
level = 5;
B = img;
for i=1:5
    figure;
    B = impyramid(B,'reduce');
    imshow(B);
end

