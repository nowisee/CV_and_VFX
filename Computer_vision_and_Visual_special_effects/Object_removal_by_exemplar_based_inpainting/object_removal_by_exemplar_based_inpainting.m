clc;
clear all;
close all;

ori_img = imread('bungee0.png');
fill_img = imread('bungee1.png');
res_img = ori_img;

SRC = 0;
TARGET = 1;

ITERATION = 500;

laplacian_mat = [1 1 1; 1 -8 1; 1 1 1];
patch_size = 9;

[h w c] = size(ori_img);

fill_map = ones(h, w);
isContour = zeros(h, w);

for i = 1 : h
    for j = 1 : w
        if ori_img(i, j, :) == fill_img(i, j, :)
            fill_map(i, j) = SRC;
        end
    end
end

src_map = ~fill_map;

% imshow(res_img);
iteration = 1600;

for T = 1 : iteration    
    isContour = zeros(h, w);
    
    for i = 1 : h-2
        for j = 1 : w-2
            convolution = fill_map(i:i+2, j:j+2) .* laplacian_mat(:, :);
            val = sum(sum(convolution));

            if val > 0
                isContour(i, j) = 1;
            end
        end
    end

    % imshow(isContour);

    b_check = false;
    for j = 1 : w-4
        for i = 1 : h-4
            if isContour(i, j) == 1
                patch = res_img(i-4:i+4, j-4:j+4, :);
                toFill = fill_map(i-4:i+4, j-4:j+4);
                toFill = toFill';

                %Hq = minH,maxH,minW,maxW
                Hq = bestexemplarhelper(h, w, patch_size, patch_size, double(res_img), double(patch), logical(toFill'), logical(src_map));
                
                for k = -4 : 4
                    for l = -4 : 4
                        if toFill(5+k, 5+l) == TARGET
                            res_img(i+k, j+l, :) = ori_img(Hq(1)+4+k, Hq(3)+4+l, :);
                            fill_map(i+k, j+l) = SRC;
                        end
                    end
                end
                
                b_check = true;
            end
            
            if b_check
                break;
            end
        end
        
        if b_check
            break;
        end;
    end

    imshow(res_img);
end