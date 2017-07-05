clc;
clear all;
close all;

imgNum = 5;
imageName = {'Set5/5-2.jpg', 'Set5/5-3.jpg', 'Set5/5-5.jpg', 'Set5/5-1.jpg', 'Set5/5-4.jpg'};

Image = imread(imageName{1});

HEIGHT = 280;
WIDTH = 320;

% Image Resize & Extract Features
Image = imresize(Image, [HEIGHT, WIDTH]);
imageSize = size(Image);
gray = rgb2gray(Image);
pts = detectHarrisFeatures(gray);
[features, valid_pts] = extractFeatures(gray, pts);

% Initialize Homography Matrix
tforms(imgNum) = projective2d(eye(3));
H(imgNum) = projective2d(eye(3));

%% Bubble Sorting Image Seqence using x coordinate of matchPoints
for i = 1 : imgNum-1
    Image = imread(imageName{i});

    Image = imresize(Image, [HEIGHT, WIDTH]);
    imageSize = size(Image);
    gray = rgb2gray(Image);
    pts = detectHarrisFeatures(gray);
    [features, valid_pts] = extractFeatures(gray, pts);
    
    for j = i+1 : imgNum
        prev_valid_pts = valid_pts;
        prev_features = features;

        prevImage = Image;
        Image = imread(imageName{j});
        Image = imresize(Image, [HEIGHT, WIDTH]);
        gray = rgb2gray(Image);

        pts = detectHarrisFeatures(gray);
        [features, valid_pts] = extractFeatures(gray, pts);

        indexPairs = matchFeatures(features, prev_features);

        matched_pts = valid_pts(indexPairs(:,1),:);
        prev_matched_pts = prev_valid_pts(indexPairs(:,2),:);
        
        sum1 = sum(indexPairs(:,1));
        sum2 = sum(indexPairs(:,2));

        if sum1 > sum2
           temp = imageName{i};
           imageName{i} = imageName{j};
           imageName{j} = temp;
        end
    end
end

%% Estimate Homography
Image = imread(imageName{1});
Image = imresize(Image, [HEIGHT, WIDTH]);
imageSize = size(Image);
gray = rgb2gray(Image);
pts = detectHarrisFeatures(gray);
[features, valid_pts] = extractFeatures(gray, pts);

tforms(imgNum) = projective2d(eye(3));
H(imgNum) = projective2d(eye(3));
    
for n = 2 : imgNum
    prev_valid_pts = valid_pts;
    prev_features = features;

    prevImage = Image;
    Image = imread(imageName{n});
    Image = imresize(Image, [HEIGHT, WIDTH]);
    gray = rgb2gray(Image);

    pts = detectHarrisFeatures(gray);
    [features, valid_pts] = extractFeatures(gray, pts);

    indexPairs = matchFeatures(features, prev_features);

    matched_pts = valid_pts(indexPairs(:,1),:);
    prev_matched_pts = prev_valid_pts(indexPairs(:,2),:);

    matched_loc = zeros(matched_pts.Count, 3);
    prev_matched_loc = zeros(matched_pts.Count, 3);
        
    for i = 1 : matched_pts.Count   
        matched_loc(i, 1) = round(matched_pts.Location(i, 2));
        matched_loc(i, 2) = round(matched_pts.Location(i, 1));
        matched_loc(i, 3) = 1;
        prev_matched_loc(i, 1) = round(prev_matched_pts.Location(i, 2));
        prev_matched_loc(i, 2) = round(prev_matched_pts.Location(i, 1));
        prev_matched_loc(i, 3) = 1;

        Image(matched_loc(i, 1), matched_loc(i, 2), :) = [255,0,0];
        Image(matched_loc(i, 1)+1, matched_loc(i, 2), :) = [255,0,0];
        Image(matched_loc(i, 1), matched_loc(i, 2)+1, :) = [255,0,0];
        Image(matched_loc(i, 1)+1, matched_loc(i, 2)+1, :) = [255,0,0];

        prevImage(prev_matched_loc(i, 1), prev_matched_loc(i, 2), :) = [0,0,255];
        prevImage(prev_matched_loc(i, 1)+1, prev_matched_loc(i, 2), :) = [0,0,255];
        prevImage(prev_matched_loc(i, 1), prev_matched_loc(i, 2)+1, :) = [0,0,255];
        prevImage(prev_matched_loc(i, 1)+1, prev_matched_loc(i, 2)+1, :) = [0,0,255];
    end

    H(n-1) = RANSAC(matched_loc, prev_matched_loc, matched_pts.Count);

    tforms(n) = estimateGeometricTransform(matched_pts, prev_matched_pts,... 
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
end

%% Image Stitching
for n = 1 : imgNum
    if n ~= 1
        Image = imread(imageName{1});
        [xlim(n,:), ylim(n,:)] = outputLimits(tforms(n), [1 imageSize(2)], [1 imageSize(1)]);
        
        xMin = min([1; xlim(:)]);
        xMax = max([imageSize(2); xlim(:)]);

        yMin = min([1; ylim(:)]);
        yMax = max([imageSize(1); ylim(:)]);
        
        width = round(xMax - xMin + prev_matched_loc(i, 2) - matched_loc(i, 2));
        height = round(yMax - yMin + prev_matched_loc(i, 1) - matched_loc(i, 1));
    else
        xMin = 0;
        xMax = imageSize(2);

        yMin = 0;
        yMax = imageSize(1);
        
        width = imageSize(2);
        height = imageSize(1);
    end    
    
    panoramaImage = zeros([height width 3], 'like', Image);

    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
        'MaskSource', 'Input port');

    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);

    for i = 1:n
        I = imread(imageName{i});
        I = imresize(I, [HEIGHT, WIDTH]);

        temp_tform = tforms(i);
       
        for j = i-1 : -1 : 1
            temp_tform.T = tforms(j).T * temp_tform.T;
        end
        
        warpedImage = imwarp(I, temp_tform, 'OutputView', panoramaView);
        
        panoramaImage = step(blender, panoramaImage, warpedImage, warpedImage(:,:,1));
    end
    
    Image = panoramaImage;
    
    if n == 5
        t3 = invert(tforms(3));
        t2 = invert(tforms(2));
        t1 = invert(tforms(1));
        
        temp_tform2 = temp_tform;
        temp_tform.T = t2.T ;
        temp_tform3 = temp_tform;
        
        imageSize = size(Image);
        [xlim(n,:), ylim(n,:)] = outputLimits(temp_tform, [1 imageSize(2)], [1 imageSize(1)]);
        
        xMin = min([1; xlim(:)]);
        xMax = max([imageSize(2); xlim(:)]);

        yMin = min([1; ylim(:)]);
        yMax = max([imageSize(1); ylim(:)]);
        
        width = round(xMax - xMin);
        height = round(yMax - yMin);
        
        panoramaImage = zeros([height width 3], 'like', Image);

        blender = vision.AlphaBlender('Operation', 'Binary mask', ...
            'MaskSource', 'Input port');

        xLimits = [xMin xMax];
        yLimits = [yMin yMax];
        panoramaView = imref2d([height width], xLimits, yLimits);

        warpedImage = imwarp(Image, temp_tform, 'OutputView', panoramaView);

        panoramaImage = step(blender, panoramaImage, warpedImage, warpedImage(:,:,1));
        
        Image = panoramaImage;
    end
    
    figure(1), imshow(panoramaImage);
end