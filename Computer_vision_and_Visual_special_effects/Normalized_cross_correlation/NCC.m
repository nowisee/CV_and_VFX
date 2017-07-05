function [ res ] = NCC(input)

img = imread(input);

%h : height, w : width, c : channel
[h w c] = size(img);
h = round(h/3);
res = zeros(h, w, 3, 'uint8');
r_img = zeros(h, w, 'uint8');
g_img = zeros(h, w, 'uint8');
b_img = zeros(h, w, 'uint8');

for k = 0 : 2
    for i = 1 : h
        for j = 1 : w
            if k == 0
                r_img(i, j) = img(i, j);
            elseif k == 1
                g_img(i, j) = img(i+h, j);
            else
                b_img(i, j) = img(i+2*h, j);
            end
        end
    end
end

figure(1),imshow(img)
figure(2), subplot(3, 1, 1), imshow(r_img);
figure(2), subplot(3, 1, 2), imshow(g_img);                
figure(2), subplot(3, 1, 3), imshow(b_img);

%range is to compute SSD range.
range = 20;

% Window size
window_size = 10;

min_index = zeros(1, 2);

% store to Compute difference of each windows from image1 to image2
diff_arr = zeros(h, w, 2, 'double');

%00017v.jpg case
fixed_x = 200;
fixed_y = 200;

min = 9999999;
for k = fixed_y - range/2 : fixed_y + range/2
    for l = fixed_x - range/2 : fixed_x + range/2
        for n = -window_size : window_size
            for m = -window_size : window_size
                diff_arr(k, l) = diff_arr(k, l) + (r_img(fixed_y+n, fixed_x+m) - g_img(k+n, l+m))^2;
            end
        end
                
        if diff_arr(k, l) < min
            min = diff_arr(k, l);
            min_index(1, 1) = l - fixed_x;
            min_index(1, 2) = k - fixed_y;
        end
    end
end

result(1, 1, 1) = min_index(1, 1);
result(1, 1, 2) = min_index(1, 2);

min = 9999999;
for k = fixed_y - range/2 : fixed_y + range/2
    for l = fixed_x - range/2 : fixed_x + range/2
        for n = -window_size : window_size
            for m = -window_size : window_size
                diff_arr(k, l) = diff_arr(k, l) + (r_img(fixed_y+n, fixed_x+m) - b_img(k+n, l+m))^2;
            end
        end
                
        if diff_arr(k, l) < min
            min = diff_arr(k, l);
            min_index(1, 1) = l - fixed_x;
            min_index(1, 2) = k - fixed_y;
        end
    end
end

result(2, 1, 1) = min_index(1, 1);
result(2, 1, 2) = min_index(1, 2);

for i = 1 : h
    for j = 1 : w
        y1 = i+result(1, 1, 2);
        x1 = j+result(1, 1, 1);
        y2 = i+result(2, 1, 2);
        x2 = j+result(2, 1, 1);
        
        if y1 >= 1 && x1 >= 1 && y2 >= 1 && x2 >=1 && y1 <= h && x1 <= w && y2 <= h && x2 <= w
            res(i, j, 1) = r_img(i, j);
            res(i, j, 2) = g_img(y1, x1);
            res(i, j, 3) = b_img(y2, x2);
        end
    end
end

figure(3), imshow(res);

