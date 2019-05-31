close all;



%% 1 input file
I = imread('cars/car1.jpg');
imshow(I);
%imwrite(I,"kaur/1.jpg");
%% 2 rgb2gray

Igray = rgb2gray(I);
%imwrite(Igray,"kaur/2.jpg");
%% 3 noise removal 

noisy = imnoise(Igray, 'salt & pepper', 0.01);

[m,n] = size(noisy);
filtered_image = zeros(m,n);
filtered_image = uint8(filtered_image);

for i = 1:m
    for j = 1:n
        xmin = max(1, i-1);
        xmax = min(m, i+1);
        ymin = max(1, j-1);
        ymax = min(n, j+1);
        temp = noisy(xmin:xmax, ymin:ymax);
        filtered_image(i,j) = median(temp(:));
    end
end

figure(1)
set(gcf, 'Position', get(0,'Screensize'));
imshow(filtered_image);
%imwrite(filtered_image,"kaur/3.jpg");


%% 4 contrast enhacement with AHE
A = filtered_image;
imhist(A);
B = histeq(A);
C = adapthisteq(B);
figure;
imshow(C);

%imwrite(C,"kaur/4.jpg");

%% 5 Morphological Opening and Image Subtraction Operations:
close all;
%open
se = strel('diamond',50);     %%%%%%%CHANGE
opened_image = imopen(C,se);
imshow(opened_image);

%%
%imwrite(opened_image,'kaur/5.jpg');

sub = imsubtract(C, opened_image);

imshow(sub),title('after subtraction');
%imwrite(sub,"kaur/6.jpg");

%%
% 6 binarization
gt = graythresh(sub);
bin = imbinarize(sub,gt);
imshow(bin);
%imwrite(bin,"kaur/7.jpg");

%% 7 sobel mask edge detection
close all;
bindb1 = double(bin);
maskx = [-1 -2 -1; 0 0 0; 1 2 1];
[r,c] = size(bin);
out = zeros(r-3, c-3);
for idx = 1:(r-3)
    for jdx = 1:(c-3)
        if idx == 37 && jdx == 28
            w = 2;
        end
        binsquare = bindb1(idx:(idx+2), jdx:(jdx+2));
        res = maskx.*binsquare;
        out(idx, jdx) = sum(sum(res));
        
    end
end
GX = out;

%imwrite(GX,"kaur/8.jpg");
masky = [-1 0 1; -2 0 2; -1 0 1];
for idx = 1:(r-3)
    for jdx = 1:(c-3)
        
        binsquare = bindb1(idx:(idx+2), jdx:(jdx+2));
        res = masky.*binsquare;
        out(idx, jdx) = sum(sum(res));
        
    end
end
GY = out;

%imwrite(GY,"kaur/9.jpg");
G = sqrt(GX.^2 + GY.^2);
imshow(G);
%imwrite(G, "kaur/10.jpg");
%%
close all;
%% 8 candidate plate area detection

se_dilate = strel('disk',1);
dilated_image = imdilate(G, se_dilate);
%imwrite(dilated_image,"kaur/11.jpg");
filled = imfill(dilated_image, 'holes');
%imwrite(filled, "kaur/12.jpg");
se_open = strel('disk',18);
opened_image1 = imopen(filled, se_open);
%imwrite(opened_image1,"kaur/13.jpg");
erode_image1 = imerode(opened_image1, se_open);
imshow(erode_image1);
%imwrite(erode_image1,"kaur/14.jpg");

%% 9 actual number plate extraction
im = erode_image1;
Iprops=regionprops(im,'BoundingBox','Area', 'Image');
area = Iprops.Area;
count = numel(Iprops);
maxa= area;
boundingBox = Iprops.BoundingBox;
for i=1:count
   if maxa<Iprops(i).Area
       maxa=Iprops(i).Area;
       boundingBox=Iprops(i).BoundingBox;
   end
end  
im = imcrop(Igray, boundingBox);
imshow(im);
%imwrite(im,"kaur/16.jpg");




%% 10 enhance ment of number plate
close all;
target = im;
target = imbinarize(target);


s_d = strel('disk',1);      
d1 = imdilate(target, s_d);
%imwrite(d1,"kaur/17.jpg");

e1 = imerode(d1, s_d);
%imwrite(e1,"kaur/18.jpg");

op1 = imopen(e1, s_d);
%imwrite(op1,"kaur/19.jpg");

cl1 = imclose(op1, s_d);
%imwrite(cl1,"kaur/20.jpg");

new = cl1;

target1 = imcomplement(new);
imshow(target1);

%imwrite(target1,"kaur/21.jpg");

%% 11 segmentation

final = target1;


[height, width] = size(final);
Iprops = regionprops(final,'BoundingBox','Area', 'Image');
count = numel(Iprops);
myPlateNumber=[]; 
for i=1:count
   ow = length(Iprops(i).Image(1,:));
   oh = length(Iprops(i).Image(:,1));
   if ow<(height/2) && oh>(height/3)
       letter=readLetter(Iprops(i).Image);
       figure; imshow(Iprops(i).Image);
       myPlateNumber = [myPlateNumber letter]; 
   end
end





