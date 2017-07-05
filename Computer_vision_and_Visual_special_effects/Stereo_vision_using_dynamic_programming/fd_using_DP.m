function [ output_args ] = fd_using_DP( input1, input2 )
% input: file path  + file name
% output : 
% ex)depth = find_depth('DB\scence1.jpg', 'DB\scence2.jpg')

img1 = rgb2gray(imread(input1));
img2 = RGB2GRAY(imread(input2));

% h : height, w : width, c : channel
[h w c] = size(img1);

% for normalized result image.
scale = 17;

min = 9999999999;
occlusionvalue = 15;

% scanline_left is needed by DP Table.(image 1=left)
scanline_left = zeros(w, 1, 'uint8');
% scanline_right is needed by DP Table.(image 2=right)
scanline_right = zeros(w, 1, 'uint8');

%make up premap.
premap = zeros(w, w,'int16');
% store to Compute difference from image1 to image2
disparitymap = zeros(w, w,'int16');
% store to result image.
result = zeros(h, w,'uint8');


for i = 1 : h

       scanline_left = img1(i, :);
       scanline_right = img2(i, :);
       
       %problem #1 disparitymap �����Ͻÿ�.
        disparitymap(:, 1) = scanline_left;
        disparitymap(1, :) = scanline_right;

       % make up DP table.
    for k = 2 : w
        for j = 2 : w
            % change disparitymap value(negative) into disparity map
            % value(positive)
             if (disparitymap(j, 1) < 0)
                 disparitymap(j, 1) = disparitymap(j, 1) * -1;
             end
            % change disparitymap value(negative) into disparity map
            % value(positive)
             if (disparitymap(1, k) < 0)
                 disparitymap(1, k) = disparitymap(1, k) * -1;
             end
            % compute the difference of disparity map values.
             val = int16(disparitymap(j, 1) - disparitymap(1, k));
            % change disparitymap value(negative) into disparity map
            % value(positive)
             if (val < 0)
                 val = val * -1;
             end
             
             %problem #2 �밢�� �� min1,���� �� min2, �ϴ� �� min3
             min1 = int16(disparitymap(j-1, k-1) + val);
             %���� �� min2
             min2 = int16(disparitymap(j, k-1) + occlusionvalue);
             %�ϴ� �� min3
             min3 = int16(disparitymap(j-1, k) + occlusionvalue);
             
             %problem #3 if�� ������ �����ÿ�
             %���� ���� �������� �밢���� ���� premap ����
             if (min1 <= min2) && (min1 <= min3)
                 premap(j, k) = 1;
                 disparitymap(j, k) = min1;
             end
             %���� ���� �������� ������ ���� premap ����
             if (min2 <= min1) && (min2 <= min3)
                 premap(j, k) = 2;
                 disparitymap(j, k) = min2;
             end
             %���� ���� �������� �ϴ��� ���� premap ����
             if (min3 <= min1) && (min3 <= min2)
                 premap(j, k) = 3;
                 disparitymap(j, k) = min3;
             end
        end
      end
           P = w;
           Q = w;
           beforestate = 1;
           disparityvalue = 0;
           
           %������ ��θ� ã�� ���ؼ� end(bottom right) -> start(upper left)
           while (Q >= 2 && P >= 2)
               %premap�� 1�̸� �밢�� ���̹Ƿ� 
               if premap(P, Q) == 1
                   result(i, Q) = disparityvalue;
                   %���� ���� 3�� 2�� ��� �� ����
                   if (beforestate == 3 || beforestate == 2)
                      val = P - Q;
                      if val < 0
                         val = val * -1; 
                      end
                      disparityvalue = val;                        
                   end
                   beforestate = 1;
                   P = P-1;
                   Q = Q-1;
               end
               
               if (premap(P, Q) == 2)
                   result(i, Q) = disparityvalue;
                   beforestate = 2;
                   %problem #4 �˸��� ���� �����Ͻÿ�
                   Q = Q-1;
               end
               
               if (premap(P, Q) == 3)
                   result(i, Q) = disparityvalue;
                   beforestate = 3;
                   %problem #5 �˸��� ���� �����Ͻÿ�
                   P = P-1;
               end
           end
           
           i
end

ii = uint8(result*10);

figure, imshow(ii);
end

