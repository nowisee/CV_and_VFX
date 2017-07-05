img = imread('lena_N.jpg');

[h w c] = size(img);

if c == 3
    img = rgb2gray(img);
end

t_img = double(img)/255;


theta = 0.5


G = fspecial('gaussian', [5 5], 1);
sobel_x = [-2 -1 0 1 2];
sobel_y = [-2 ; -1 ; 0 ; 1 ; 2];

Ix = filter2(sobel_x, t_img);
Iy = filter2(sobel_y, t_img);

Ix2 = Ix.*Ix;
Iy2 = Iy.*Iy;
Ixy = Ix.*Iy;

Sx2 = filter2(G, Ix2);
Sy2 = filter2(G, Iy2);
Sxy = filter2(G, Ixy);

R = zeros(h, w);

MAXR = 0;
for i = 1 : h
    for j = 1 : w
        AC = [Ix2(i, j) Ixy(i, j) ; Ixy(i, j) Iy(i, j)];
        
        R(i, j) = det(AC) - 0.05 * TRACE(AC) * TRACE(AC);
        if R(i, j) > MAXR
            MAXR = R(i, j);
        end
    end
end

region = zeros(5);
result = zeros(h, w);

for i = 3 : h-2
    for j = 3 : w-2
        region = R(i-2:i+2, j-2:j+2);
        
        if max(max(region)) == R(i, j)
            if R(i, j) > theta * MAXR
                result(i, j) = 1;
            end
        end
    end
end

[posc, posr] = find(result == 1);
imshow(img);
hold on;
plot(posr, posc, 'r+');
