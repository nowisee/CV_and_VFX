clc;
clear all;

sigma = 8;

for_theta = 255 * 0.95;
back_theta = 255 * 0.05;

iteration = 10;

epsilon = 0.0001;

trimap = double(imread('toy.png'));
nor_trimap = trimap ./ 255;

img = double(imread('toy.jpg'));
[h w c] = size(img);

f_img = zeros(h, w);
b_img = zeros(h, w);
uk_img = zeros(h, w);

bg = double(imread('bookshelf.jpg'));
res = zeros(h, w, c);

I = eye(3);

%% Calculate Mean Value
f_cnt = 0;
b_cnt = 0;
m_f = zeros(3, 1);
m_b = zeros(3, 1);
for i = 1 : h
    for j = 1 : w
        if trimap(i, j) >= for_theta
            m_f(1) = m_f(1) + img(i, j, 1);
            m_f(2) = m_f(2) + img(i, j, 2);
            m_f(3) = m_f(3) + img(i, j, 3);
            f_cnt = f_cnt + 1;
            f_img(i, j) = 255;
        elseif trimap(i, j) <= back_theta
            m_b(1) = m_b(1) + img(i, j, 1);
            m_b(2) = m_b(2) + img(i, j, 2);
            m_b(3) = m_b(3) + img(i, j, 3);
            b_cnt = b_cnt + 1;
            b_img(i, j) = 255;
        else
            uk_img(i, j) = 255;
        end
    end
end

% subplot(1, 3, 1), imshow(f_img);
% subplot(1, 3, 2), imshow(uk_img);
% subplot(1, 3, 3), imshow(b_img);

%% Making diff_img
m_f = m_f ./ f_cnt;
for i = 1 : h
    for j = 1 : w
        diff_m_f(i, j, 1) = img(i, j, 1) - m_f(1);
        diff_m_f(i, j, 2) = img(i, j, 2) - m_f(2);
        diff_m_f(i, j, 3) = img(i, j, 3) - m_f(3);     
    end
end

m_b = m_b ./ b_cnt;
for i = 1 : h
    for j = 1 : w
        diff_m_b(i, j, 1) = img(i, j, 1) - m_b(1);
        diff_m_b(i, j, 2) = img(i, j, 2) - m_b(2);
        diff_m_b(i, j, 3) = img(i, j, 3) - m_b(3);     
    end
end

% subplot(1, 2, 1), imshow(diff_m_f);
% subplot(1, 2, 2), imshow(diff_b_f);

%% Calculate Covariance Matrix
f_cov_mat = zeros(3, 3);
b_cov_mat = zeros(3, 3);
for i = 1 : h
    for j = 1 : w
        f_tmp = zeros(3, 3);
        b_tmp = zeros(3, 3);
        color = zeros(3, 1);
        if f_img(i, j) == 255
            color(1) = diff_m_f(i, j, 1);
            color(2) = diff_m_f(i, j, 2);
            color(3) = diff_m_f(i, j, 3);
            f_tmp = color * color';
        elseif b_img(i, j) == 255
            color(1) = diff_m_b(i, j, 1);
            color(2) = diff_m_b(i, j, 2);
            color(3) = diff_m_b(i, j, 3);
            b_tmp = color * color';
        end
        f_cov_mat = f_cov_mat + f_tmp;
        b_cov_mat = b_cov_mat + b_tmp;
    end
end
f_cov_mat = f_cov_mat ./ f_cnt;
b_cov_mat = b_cov_mat ./ b_cnt;

%% Calculate Log Likelihood of F, B
% f_log_lhd = -diff_m_f' * inv(f_cov_mat) * diff_m_f / 2;
% b_log_lhd = -diff_m_b' * inv(b_cov_mat) * diff_m_b / 2;

%% Calculate F, B, alpha
alpha = zeros(h, w);
separation_f_img = zeros(h, w, c);
for i = 1 : h
    for j = 1 : w
        p_alpha = nor_trimap(i, j);
        
        if f_img(i, j) == 255
            alpha(i, j) = p_alpha;
            separation_f_img(i, j, :) = alpha(i, j) * img(i, j, :);
            res(i, j, :) = img(i, j, :);
        end
        
        if uk_img(i, j) == 255
            for k = 1 : iteration
                A = zeros(6, 6);
                X = zeros(6, 1);
                b = zeros(6, 1);
                m33 = zeros(3, 3);
                m31 = zeros(3, 1);
                
                color = zeros(3, 1);
                f_color = zeros(3, 1);
                b_color = zeros(3, 1);
                
                color(1) = img(i, j, 1);
                color(2) = img(i, j, 2);
                color(3) = img(i, j, 3);
                
                m33 = inv(f_cov_mat) + I * p_alpha^2 / sigma^2;
                A(1:3, 1:3) = m33;
                
                m33 = I * p_alpha * (1 - p_alpha) / sigma^2;
                A(1:3, 4:6) = m33;
                A(4:6, 1:3) = m33;
                
                m33 = inv(b_cov_mat) + I * (1 - p_alpha)^2 / sigma^2;
                A(4:6, 4:6) = m33;
                
                m31 = inv(f_cov_mat) * m_f + color * p_alpha / sigma^2;
                b(1:3) = m31;
                m31 = inv(b_cov_mat) * m_b + color * (1 - p_alpha) / sigma^2;
                b(4:6) = m31;
                
                X = inv(A) * b;
                
                f_color = X(1:3);
                b_color = X(4:6);
                
                val = dot(color - b_color, f_color - b_color) / (norm(f_color - b_color))^2;
                
                alpha(i, j) = val;
                
                if abs(p_alpha - alpha(i, j)) <= epsilon
                    break;
                end
                
                p_alpha = alpha(i, j);
            end
            
            separation_f_img(i, j, 1) = alpha(i, j) * f_color(1);
            separation_f_img(i, j, 2) = alpha(i, j) * f_color(2);
            separation_f_img(i, j, 3) = alpha(i, j) * f_color(3);

            res(i, j, :) = separation_f_img(i, j, :) + (1 - alpha(i, j)) * bg(i, j, :);
        end
        
        if b_img(i, j) == 255
            res(i, j, :) = bg(i, j, :);
        end
    end
end

res = uint8(res);
figure(1), title('result img'), imshow(res);
%figure(2), title('alpha map'), imshow(uint8(alpha.*255));
