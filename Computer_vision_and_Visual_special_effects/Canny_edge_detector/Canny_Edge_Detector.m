% img = imread('lena_N.jpg');
img = imread('CameraMan.jpg');

[h w c] = size(img);

if c == 3
    img = rgb2gray(img);
end

g_mask_size = 3;
sigma = 1;

gf_img = Gaussian_Filter(img, g_mask_size, sigma);

[h w] = size(gf_img);

result = zeros(h, w, 'uint8');

sobel_size = 3;
sobel_x = [1 0 -1 ; 2 0 -2 ; 1 0 -1];
sobel_y = [1 2 1 ; 0 0 0 ; -1 -2 -1];

h_len = floor(sobel_size/2);

sx_img = zeros(h, w, 'uint8');
sy_img = zeros(h, w, 'uint8');

for i = h_len+1 : h - h_len
    for j = h_len+1 : w - h_len
        sx_img(i, j) = abs(floor(sum(sum(double(gf_img(i-1:i+1, j-1:j+1)).*sobel_x))/4));
        sy_img(i, j) = abs(floor(sum(sum(double(gf_img(i-1:i+1, j-1:j+1)).*sobel_y))/4));
    end
end

mgtd = sqrt(double(sx_img).*double(sx_img) + double(sy_img).*double(sy_img));
ori = atan(double(sy_img)./double(sx_img));

figure(1), imshow(uint8(mgtd));

temp = 0;
cnt = 0;
dir = zeros(h, w);

for i = h_len + 1 : h - h_len
    for j = h_len + 1 : w - h_len
        if -0.4142 < ori(i, j) && ori(i, j) <= 0.4142
            dir(i, j) = 0;
            hor = 1;
            ver = 0;
        elseif 0.4142 < ori(i, j) && ori(i, j) < 2.4142
            dir(i, j) = 1;
            hor = 1;
            ver = 1;
        elseif abs(ori(i, j)) >= 2.4142
            dir(i, j) = 2;
            hor = 0;
            ver = 1;
        elseif -2.4142 < ori(i, j) && ori(i, j) <= 0.4142
            dir(i, j) = 3;
            hor = 0;
            ver = -1;
        end
        
        if mgtd(i, j) > mgtd(i+ver, j+hor) && mgtd(i, j) > mgtd(i-ver, i-hor)
            result(i, j) = mgtd(i, j);
            temp = temp + mgtd(i, j);
            cnt = cnt + 1;
        end
    end
end

temp = temp / cnt;
high = temp * 1.5;
low = temp * 0.5;

region = zeros(3);

figure(2), imshow(result);

for i = h_len + 1 : h - h_len
    for j = h_len + 1 : w - h_len
        if result(i, j) < low
            result(i, j) = 0;
        elseif low < result(i, j) && result(i, j) < high
            region = result(i-h_len:i+h_len, j-h_len:j+h_len);

            if max(max(region)) >= high
            else result(i, j) = 0;
            end
        end
    end
end

figure(3),
subplot(1, 2, 1), imshow(img), title('Input Image');
subplot(1, 2, 2), imshow(result), title('Output Image(Hysteresis)');