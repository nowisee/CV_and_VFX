clear all;
clc;

s_img = imread('morph_face1.jpg');
d_img = imread('morph_face2.jpg');

[h w c] = size(s_img);

% t_img = zeros(h, w, c, 'uint8');

total_frame = 30;

fid = fopen('label_point.txt', 'r');
[input cnt] = fscanf(fid, '%d %d\n', [4, inf]);
m = importdata('triangle_label.txt');
cnt = cnt / 4;

s_p(:, 1) = input(1, :);
s_p(:, 2) = input(2, :);

d_p(:, 1) = input(3, :);
d_p(:, 2) = input(4, :);

%compute each target point, each frame
for i = 1 : cnt
    for j = 1 : total_frame
        t_p(i, 1, j) = round(s_p(i, 1) + (d_p(i, 1) - s_p(i, 1)) * j / total_frame);
        t_p(i, 2, j) = round(s_p(i, 2) + (d_p(i, 2) - s_p(i, 2)) * j / total_frame);
    end
end

figure(1);
for j = 1 : total_frame
    j
    for i = 1 : 76
        %target triangle
        out = [t_p(m(i, 1), 1, j) t_p(m(i, 2), 1, j) t_p(m(i, 3), 1, j);
               t_p(m(i, 1), 2, j) t_p(m(i, 2), 2, j) t_p(m(i, 3), 2, j);
               1 1 1];
        %src triangle
        s_in = [s_p(m(i, 1), 1) s_p(m(i, 2), 1) s_p(m(i, 3), 1);
                s_p(m(i, 1), 2) s_p(m(i, 2), 2) s_p(m(i, 3), 2);
                1 1 1];
        %dst triangle
        d_in = [d_p(m(i, 1), 1) d_p(m(i, 2), 1) d_p(m(i, 3), 1);
                d_p(m(i, 1), 2) d_p(m(i, 2), 2) d_p(m(i, 3), 2);
                1 1 1];
        
        %compute min/max w, h of target triangle
        min_w = min(out(1, :)); 
        max_w = max(out(1, :)); 
        min_h = min(out(2, :)); 
        max_h = max(out(2, :)); 
        
        %compute affine matrix
        s_tmp_mat = out * inv(s_in);
        d_tmp_mat = out * inv(d_in);
        s_mat(i, j, :, :) = s_tmp_mat(:, :);
        d_mat(i, j, :, :) = d_tmp_mat(:, :);
        
        %make t_img
        for k = min_h : max_h
            for l = min_w : max_w
                %compute alpha, beta, gamma
                q = (t_p(m(i, 2), 1, j) - t_p(m(i, 1), 1, j)) * (t_p(m(i, 3), 2, j) - t_p(m(i, 1), 2, j)) - (t_p(m(i, 3), 1, j) - t_p(m(i, 1), 1, j)) * (t_p(m(i, 2), 2, j) - t_p(m(i, 1), 2, j));
                
                p = (t_p(m(i, 2), 1, j) - l) * (t_p(m(i, 3), 2, j) - k) - (t_p(m(i, 3), 1, j) - l) * (t_p(m(i, 2), 2, j) - k);
                alpha = p/q;
                
                p = (t_p(m(i, 3), 1, j) - l) * (t_p(m(i, 1), 2, j) - k) - (t_p(m(i, 1), 1, j) - l) * (t_p(m(i, 3), 2, j) - k);
                beta = p/q;
                
                p = (t_p(m(i, 1), 1, j) - l) * (t_p(m(i, 2), 2, j) - k) - (t_p(m(i, 2), 1, j) - l) * (t_p(m(i, 1), 2, j) - k);
                gamma = p/q;
                
                %inverse warping & cross-dissolving
                if alpha >= 0 && beta >= 0 && gamma >= 0
                    target = [l; k; 1];
                    s_inv_warp = inv(s_tmp_mat) * target;
                    d_inv_warp = inv(d_tmp_mat) * target;
                    if s_inv_warp(1) >= 0 && s_inv_warp(2) >= 0 && d_inv_warp(1) >= 0 && d_inv_warp(2) >= 0 && s_inv_warp(1) <= w && s_inv_warp(2) <= h && d_inv_warp(1) <= w && d_inv_warp(2) <= h
                        t_img(k, l, 1) = (1 - j/total_frame) * s_img(ceil(s_inv_warp(2)), ceil(s_inv_warp(1)), 1) + j/total_frame * d_img(ceil(d_inv_warp(2)), ceil(d_inv_warp(1)), 1);
                        t_img(k, l, 2) = (1 - j/total_frame) * s_img(ceil(s_inv_warp(2)), ceil(s_inv_warp(1)), 2) + j/total_frame * d_img(ceil(d_inv_warp(2)), ceil(d_inv_warp(1)), 2);
                        t_img(k, l, 3) = (1 - j/total_frame) * s_img(ceil(s_inv_warp(2)), ceil(s_inv_warp(1)), 3) + j/total_frame * d_img(ceil(d_inv_warp(2)), ceil(d_inv_warp(1)), 3);
                    end
                end
            end
        end
    end
    
    imshow(uint8(t_img));
    hold on;
    f(j) = getframe;
end

movie(f);
movie2avi(f, 'morphing.avi');