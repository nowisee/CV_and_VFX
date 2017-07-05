clc;
clear all;

threshold = 30;

img1 = imread('mountain1.ppm');
img2 = imread('mountain2.ppm');

[h w c] = size(img1);

RED = [255 0 0];
GREEN = [0 255 0];
BLUE = [0 0 255];

res = zeros(h, 2*w, 3, 'uint8');

ref_img1 = img1;
ref_img2 = img2;

fid = fopen('match-mountain.txt', 'r');
[input count] = fscanf(fid, '%d %d\n', [4, inf]);
p_num = count/4;

ref_A(1, :) = input(2, :);
ref_A(2, :) = input(1, :);
ref_A(3, :) = 1;

ref_B(1, :) = input(4, :);
ref_B(2, :) = input(3, :);
ref_B(3, :) = 1;

max_inlier = 0;

input = input';

for i = 1 : p_num;
    img1(input(i,1), input(i,2), :) = RED;
    img1(input(i,1)+1, input(i,2), :) = RED;
    img1(input(i,1)+1, input(i,2)+1, :) = RED;
    img1(input(i,1), input(i,2)+1, :) = RED;
    
    img2(input(i,3), input(i,4), :) = BLUE;
    img2(input(i,3)+1, input(i,4), :) = BLUE;
    img2(input(i,3)+1, input(i,4)+1, :) = BLUE;
    img2(input(i,3), input(i,4)+1, :) = BLUE;
end

%figure(1), imshow(img1);
%figure(2), imshow(img2);

for T = 1 : 500
    ran = [];
    ran(1) = round(4*rand(1)+1);
    
    for i = 2 : 4
        ran(i) = round( (p_num - 1)*rand(1) + 1 );
    end
    
    A = [input(ran(1), 2),input(ran(1), 1), 1 ;
         input(ran(2), 2),input(ran(2), 1), 1 ;
         input(ran(3), 2),input(ran(3), 1), 1 ;
         input(ran(4), 2),input(ran(4), 1), 1 ;];
    B = [input(ran(1), 4),input(ran(1), 3), 1 ;
         input(ran(2), 4),input(ran(2), 3), 1 ;
         input(ran(3), 4),input(ran(3), 3), 1 ;
         input(ran(4), 4),input(ran(4), 3), 1 ;];
     
     A = A';
     B = B';
     
     inv_A = inv(A*A');
     H = B * A' * inv_A;
     
     a = size(ref_A);
     
     if(a(2) == 3)
         ref_A = ref_A';
     end
     
     real_B = H*ref_A;
     
     ref_A = ref_A';
     ref_B = ref_B';
     real_B = real_B';
     
     inlier = 0;
     outlier = 0;
     
     for i = 1 : p_num;
         b = size(ref_B);
         
         if(b(1) == 3)
             ref_B = ref_B';
         end
         
         error = (ref_B(i, 1) - real_B(i, 1))^2 + (ref_B(i, 2) - real_B(i, 2))^2;
         
         if error < threshold
             inlier = inlier + 1;
         else
             outlier = outlier + 1;
         end
     end
     
     if max_inlier < inlier
         real_H = H;
         max_inlier = inlier;
     end
end

B = real_H * ref_A'; 

for i = 1 : h
    for j = 1 : 2*w
        for k = 1 : 3
            if j <= w
                res(i, j, k) = img1(i, j, k);
            else
                res(i, j, k) = img2(i, j-w, k);
            end
        end
    end
end

inlier = 0;
outlier = 0;

for i = 1 : p_num
    b1 = size(B);
    
    if(b1(1) == 3)
        B = B';
    end
    
    error = (ref_B(i, 1) - B(i, 1))^2 + (ref_B(i, 2) - B(i, 2))^2;
    
    if error < threshold
        inlier = inlier + 1;
        
        img1(ref_A(i, 2),ref_A(i, 1), :) = GREEN;
        img1(ref_A(i,2)+1, ref_A(i,1), :) = GREEN;
        img1(ref_A(i,2)+1, ref_A(i,1)+1, :) = GREEN;
        img1(ref_A(i,2), ref_A(i,1)+1, :) = GREEN;
        
        res(ref_A(i, 2),ref_A(i, 1), :) = [0 255  0];
        res(ref_A(i,2)+1, ref_A(i,1), :) = GREEN;
        res(ref_A(i,2)+1, ref_A(i,1)+1, :) = GREEN;
        res(ref_A(i,2), ref_A(i,1)+1, :) = GREEN;
        
        img2(round(B(i,2)), round(B(i,1)), :) = GREEN;
        img2(round(B(i,2)+1), round(B(i,1)), :) = GREEN;
        img2(round(B(i,2)+1), round(B(i,1)+1), :) = GREEN;
        img2(round(B(i,2)), round(B(i,1)+1), :) = GREEN;
        
        res(round(B(i,2)), round(B(i,1))+w, :) = GREEN;
        res(round(B(i,2)+1), round(B(i,1))+w, :) = GREEN;
        res(round(B(i,2)+1), round(B(i,1)+1)+w, :) = GREEN;
        res(round(B(i,2)), round(B(i,1)+1)+w, :) = GREEN;
        
        l_point(1) = ref_A(i, 1);
        l_point(2) = ref_A(i, 2);
        r_point(1) = round(B(i, 1)) + w;
        r_point(2) = round(B(i, 2));
        
        a = (r_point(2) - l_point(2)) / (r_point(1) - l_point(1));
        b = r_point(2) - a*r_point(1);
        
        for j = l_point(1) : r_point(1)
            res(round(a*j+b), j, 1) = 255;
            res(round(a*j+b), j, 2) = 255;
            res(round(a*j+b), j, 3) = 0;
        end
    else
        outlier = outlier + 1;
    end
end

inlier
outlier

figure(3), imshow(res);

save('homography.mat', 'real_H');