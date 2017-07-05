clc;
clear all;

img = imread('seaside.jpg');

[h w c] = size(img);

x_scale = 0.5;
y_scale = 2;

x_trans = 40;
y_trans = 20;

theta = 45;
rad = theta * 3.141592 / 180;

x_min = 0;
y_min = 0;

for i = 1 : h
    for j = 1 : w
        scl_img(round(i*y_scale), round(j*x_scale), :) = img(i, j, :);
        
        rot_x = round(j*cos(rad) - i*sin(rad));
        if rot_x < x_min
            x_min = rot_x;
        end
        
        rot_y = round(j*sin(rad) + i*cos(rad));
        if rot_y < y_min
            y_min = rot_y;
        end
        
        trans_img(i+y_trans, j+x_trans, :) = img(i, j, :);
    end
end

for i = 1 : h
    for j = 1 : w
        rot_x = round(j*cos(rad) - i*sin(rad));
        rot_y = round(j*sin(rad) + i*cos(rad));
        rot_img(rot_y - y_min + 1, rot_x - x_min + 1 , :) = img(i, j, :);
    end
end

figure(1),
subplot(1, 4, 1), imshow(img), title('original');
subplot(1, 4, 2), imshow(scl_img), title('scale');
subplot(1, 4, 3), imshow(rot_img), title('rotation');
subplot(1, 4, 4), imshow(trans_img), title('translation');

[h2 w2 c2] = size(scl_img);
if mod(h, 2) ~= 0
    h2 = h2 - 1;
end
if mod(w, 2) ~= 0
    w2 = w2 - 1;
end

for i = 1 : h2
    for j = 1 : w2
        scl_img(i, j, :) = img(ceil(i/y_scale), ceil(j/x_scale), :);
    end
end

[h2 w2 c2] = size(rot_img);

for i = 1 : h2
    for j = 1 : w2
        rot_x = round((i+y_min-1)*cos(rad) + (j+x_min-1)*sin(rad));
        rot_y = round(-(j+x_min-1)*sin(rad) + (i+y_min-1)*cos(rad));
        if 0 < rot_x && rot_x <= w && 0 < rot_y && rot_y <= h
            rot_img(i, j, :) = img(rot_y, rot_x, :);
        end
    end
end

figure(2),
subplot(1, 3, 1), imshow(img), title('original');
subplot(1, 3, 2), imshow(scl_img), title('inv scale');
subplot(1, 3, 3), imshow(rot_img), title('inv rotation');