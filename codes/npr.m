close all;

%% 1 input
I = imread('car1.jpg');
I = imresize(I, [480 NaN]);
imshow(I);
%imwrite(I, "own/1. original.jpg");


% 2 normal to grayscale 
%g = rgb2gray(I);
%imshow(g);
g = conSt(I);
g = uint8(g);

imshow(g);
se = strel('diamond',50); 
g = imtophat(g, se);
imshow(g);

%imwrite(Igray, "own/2. grayscaled.jpg");
%%
%{ 
3 noise 

%%NOISE REMOVAL 
noisy = imnoise(g, 'salt & pepper', 0.01);%adding noise
%%removing noise
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
%subplot(131), imshow(I),title('Original');
%subplot(132), imshow(noisy),title('noisy image');
%subplot(133), imshow(filtered_image),title('Output of median filter');
%imwrite(noisy, "own/3. noisy.jpg");
%imwrite(filtered_image, "own/4. output of median filter.jpg");
%Igray = filtered_image

%}

%% 4 SOBEL EDGE DETECTION
close all;
sobel_img = edge(g, 'sobel');
imshow(sobel_img);
%imwrite(sobel_img, "own/5. output of sobel.jpg");

G = sobel_img;
%G = imfill(G);
%imshow(G);
%% 5 candidate plate area detection
se_dilate = strel('disk',4); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dilated_image = imdilate(G, se_dilate);
%imwrite(dilated_image, "own/6. after dilation.jpg");
imshow(dilated_image);
filled = imfill(dilated_image, 'holes');
%imwrite(filled, "own/7. after filling holes.jpg");
imshow(filled);

%%
se_open = strel('disk', 19); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opened_image1 = imopen(filled, se_open);
imshow(opened_image1);
%imwrite(opened_image1, "own/8. after open operation.jpg");
%%
se_erode = strel('disk', 19); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
erode_image1 = imerode(opened_image1, se_erode);
imshow(erode_image1);%%shada box
%imwrite(erode_image1, "own/9. after erosion.jpg");




%% 6 ACTUAL NUMBER PLATE AREA EXTRACTION
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

im = imcrop(g, boundingBox);
imshow(im);

%imwrite(im, "own/10. extracted plate.jpg");

%%
% 7 extracted plate region enhancement
close all;
%resize number plate to 240 NaN
resized = imresize(im, [240 NaN]);
%imshow(resized);
%imwrite(resized, "own/11. extracted plate resized.jpg");


target = resized;
target = imbinarize(target);
imshow(target);
%imwrite(target, "own/12. binary image.jpg");
%%
s_d = strel('disk',0);      %%%%%%%CHANGE
d1 = imdilate(target, s_d);
%imshow(d1);
%imwrite(d1,"kaur/17.jpg");


e1 = imerode(d1, s_d);
%imshow(e1);
%imwrite(e1,"kaur/18.jpg");

 
op1 = imopen(e1, s_d);
%imshow(op1);
%imwrite(op1,"kaur/19.jpg");



cl1 = imclose(op1, s_d);
%imshow(cl1);
%imwrite(cl1,"kaur/20.jpg");
%%

target1 = imcomplement(cl1);
imshow(target1);
%imwrite(target1, "own/13. after complement.jpg");


%selecting the large components
N = target1;
cc = bwconncomp(N); 
stats = regionprops(cc, 'MajorAxisLength', 'MinorAxisLength', 'Area'); 
idx = find([stats.MajorAxisLength] < 300 & [stats.MinorAxisLength] > 7 & [stats.Area]>300); %%%%%%%CHANGE
BW2 = ismember(labelmatrix(cc), idx); 
%imshow(BW2);
%imwrite(BW2, "own/14. erase out the small components.jpg");



%% 8 segmentation

% CHARACTER SEGMENTATION & READING
close all;
imshow(BW2);
final = BW2;
[height, width] = size(final);
Iprops = regionprops(final,'BoundingBox','Area', 'Image');
count = numel(Iprops);
myPlateNumber=[]; % Initializing the variable of number plate string.
for i=1:count
   ow = length(Iprops(i).Image(1,:));
   oh = length(Iprops(i).Image(:,1));
   if ow<(height/2) && oh>(height/3)
       letter=readLetter(Iprops(i).Image); % Reading the letter corresponding the binary image 'N'.
       figure; imshow(Iprops(i).Image);
       myPlateNumber = [myPlateNumber letter]; % Appending every subsequent character in myPlateNumber variable.
   end
end





