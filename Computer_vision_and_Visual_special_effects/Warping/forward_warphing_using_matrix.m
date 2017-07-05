clc;
clear all;

img = imread('seaside.jpg');

[h w c] = size(img);

x_scale = 0.5;
y_scale = 2;
scl_mat = [x_scale 0; 0 y_scale];
inv_scl_mat = [1/x_scale 0; 0 1/y_scale];

x_trans = 40;
y_trans = 20;
trans_mat = [1 0 x_trans; 0 1 y_trans; 0 0 1];

theta = 45;
rad = theta * 3.141592 / 180;
rot_mat = [cos(rad) -sin(rad); sin(rad) cos(rad)];
inv_rot_mat = [cos(rad) sin(rad); -sin(rad) cos(rad)];

x_min = 0;
y_min = 0;

for i = 1 : h
    for j = 1 : w
        input = [j; i];
        output = scl_mat * input;
        scl_img(round(output(2, 1)), round(output(1, 1)), :) = img(i, j, :);
        
        output = rot_mat * input;
        rot_x = round(output(2, 1));
        if rot_x < x_min
            x_min = rot_x;
        end
        
        rot_y = round(output(1, 1));
        if rot_y < y_min
            y_min = rot_y;
        end
        
        input = [j; i; 1];
        output = trans_mat * input;
        trans_img(output(2, 1), output(1, 1), :) = img(i, j, :);
    end
end

for i = 1 : h
    for j = 1 : w
        input = [j; i];
        output = rot_mat * input;
        rot_x = round(output(2, 1));
        rot_y = round(output(1, 1));
        rot_img(rot_x - x_min + 1, rot_y - y_min + 1, :) = img(i, j, :);
    end
end

subplot(1, 4, 1), imshow(img), title('original');
subplot(1, 4, 2), imshow(scl_img), title('scale');
subplot(1, 4, 3), imshow(rot_img), title('rotation');
subplot(1, 4, 4), imshow(trans_img), title('translation');