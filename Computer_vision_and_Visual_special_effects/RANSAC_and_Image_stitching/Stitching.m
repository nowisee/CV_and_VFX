clc;
clear all;

img1 = imread('mountain1.ppm');
img2 = imread('mountain2.ppm');

[h1 w1 c1] = size(img1);
[h2 w2 c2] = size(img2);

fid = fopen('match-mountain.txt', 'r');
[input count] = fscanf(fid, '%d %d\n', [4, inf]);
p_num = count/4;

load('homography.mat');

inv_H = inv(real_H);

for i = 1 : h2
    for j = 1 : w2
        input = [j; i; 1];
        output = inv_H * input;
        
        res(round(output(2)), round(output(1)), :) = img2(i, j, :);
    end
end

for i = 1 : h1 - 2
    for j = 1 : w1 - 2
        val = res(i, j, 1) + res(i, j, 2) + res(i, j, 3);
        
        if val ~= 0
            res(i, j, :) = 0.5*res(i, j, :) + 0.5*img1(i, j, :);
        else
            res(i, j, :) = img1(i, j, :);
        end
    end
end

figure(1), imshow(res);

[h w c] = size(res);

for i = 1 : h
    val = res(i, 1, 1) + res(i, 1, 2) + res(i, 1, 3);
    
    if val == 0
       max_y = i;
       break;
    end
end

for i = 1 : h
    val = res(i, w, 1) + res(i, w, 2) + res(i, w, 3);
    
    if val ~= 0
       min_y = i;
       break;
    end
end
        
for i = 1 : w
    val = res(h, i, 1) + res(h, i, 2) + res(h, i, 3);
    
    if val ~= 0
       max_x = i;
       break;
    end
end 
        
cut_res = zeros(max_y-min_y+1, max_x, 3, 'uint8');

for i = min_y : max_y
    for j = 1 : max_x
        cut_res(i-min_y+1, j, :) = res(i, j, :);
    end
end

figure(2), imshow(cut_res);