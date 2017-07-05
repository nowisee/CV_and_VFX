img = imread('image.jpg');
%img = imread('sky2.jpg');

pre_img = img;

[h w c] = size(img);

dx = 300;
dy = 0;

figure(1), imshow(img);

%% seam carving _ x diretion
for t = 1 : dx
    % Set pre_image
    if t ~= 1
        pre_img = zeros(h, w+1-t, c);
        pre_img = res;
    end
    
    % make energy image
    gray = rgb2gray(pre_img);
    
    energy = zeros(h, w+1-t);

    energy = energy + abs(filter2([1 0 -1], gray(:,:))) + abs(filter2([1;0;-1], gray(:,:)));
    
%   figure(2), imshow(uint8(energy));
         
    board = zeros(h, w+1-t);
    isSeam = zeros(h, w+1-t, 'uint8');
    res = zeros(h, w-t, c, 'uint8');

    % accumulate energy following algorithm
    for i = 1 : h
        for j = 1 : w+1-t
            if i == 1
                board(i, j) = energy(i, j);
            else
                if j == 1
                    minval = min(board(i-1, j), board(i-1, j+1));
                elseif j == w+1-t
                    minval = min(board(i-1, j-1), board(i-1, j));
                else
                    minval = min(board(i-1, j-1), board(i-1, j));
                    minval = min(minval, board(i-1, j+1));
                end
                
                board(i, j) = energy(i, j) + minval;
            end
        end
    end
    
    % find start position 
    minval = min(board(h,:));
    location = find(board(h,:) == minval);
    [x, y] = size(location);

    l = location(1, 1);
    
    % find seam
    for i = h : -1 : 1
        if i == h
            isSeam(i, l) = 1;          
        elseif i < h
            if l == 1
                tmp = [ board(i, l), board(i, l+1) ];
                [ T, idx ] = min(tmp);
                if idx == 1
                    isSeam(i, l) = 1;
                else
                    isSeam(i, l+1) = 1;
                    l = l + 1;
                end
            elseif l > 1 && l < w+1-t
                tmp = [ board(i, l-1), board(i, l), board(i, l+1) ];
                [ T, idx ] = min(tmp);
                if idx == 1
                    isSeam(i, l-1) = 1;
                    l = l - 1;       
                elseif idx == 2
                    isSeam(i, l) = 1;
                else
                    isSeam(i, l+1) = 1;
                    l = l + 1;
                end 
            else
                tmp = [ board(i, l-1), board(i, l) ];
                [ T, idx ] = min(tmp);
                if idx == 1
                    isSeam(i, l-1) = 1;
                    l = l - 1;
                else
                    isSeam(i, l) = 1;
                end
            end
        end
    end

    figure(3), imshow(uint8(isSeam.*255));
    
    % resize image
    for i = 1 : h
        [ T, idx ] = max(isSeam(i, :));
        res(i, (1:idx-1), :) = pre_img(i, (1:idx-1), :);
        res(i, (idx:w-t), :) = pre_img(i, (idx+1:w+1-t), :);
    end

    figure(4), imshow(res);
end

%% seam carving _ y diretion

[h2 w2 c2] = size(res);
pre_img = zeros(h2, w2, c2);
pre_img = res;

for t = 1 : dy
    % Set pre_image
    if t ~= 1
        pre_img = zeros(h2+1-t, w2, c2);
        pre_img = res;
    end
    
    % make energy image
    gray = rgb2gray(pre_img);
    
    energy = zeros(h2+1-t, w2);

    energy = energy + abs(filter2([1 0 -1], gray(:,:))) + abs(filter2([1;0;-1], gray(:,:)));
    
%      figure(2), imshow(uint8(energy));
         
    board = zeros(h2+1-t, w2);
    isSeam = zeros(h2+1-t, w2, 'uint8');
    res = zeros(h2-t, w2, c2, 'uint8');

    % accumulate energy following algorithm
    for j = 1 : w2
        for i = 1 : h2+1-t
            if j == 1
                board(i, j) = energy(i, j);
            else
                if i == 1
                    minval = min(board(i, j-1), board(i+1, j-1));
                elseif i == h2+1-t
                    minval = min(board(i-1, j-1), board(i, j-1));
                else
                    minval = min(board(i-1, j-1), board(i, j-1));
                    minval = min(minval, board(i+1, j-1));
                end
                
                board(i, j) = energy(i, j) + minval;
            end
        end
    end
    
    % find start position 
    minval = min(board(:,w2));
    location = find(board(:,w2) == minval);
    [x, y] = size(location);

    l = location(1, 1);
    
    % find seam
    for i = w2 : -1 : 1
        if j == w2
            isSeam(l, w2) = 1;          
        elseif i < w2
            if l == 1
                tmp = [ board(l, i), board(l+1, i) ];
                [ T, idx ] = min(tmp);
                if idx == 1
                    isSeam(l, i) = 1;
                else
                    isSeam(l+1, i) = 1;
                    l = l + 1;
                end
            elseif l > 1 && l < h2+1-t
                tmp = [ board(l-1, i), board(l, i), board(l+1, i) ];
                [ T, idx ] = min(tmp);
                if idx == 1
                    isSeam(l-1, i) = 1;
                    l = l - 1;       
                elseif idx == 2
                    isSeam(l, i) = 1;
                else
                    isSeam(l+1, i) = 1;
                    l = l + 1;
                end 
            else
                tmp = [ board(l-1, i), board(l, i) ];
                [ T, idx ] = min(tmp);
                if idx == 1
                    isSeam(l-1, i) = 1;
                    l = l - 1;
                else
                    isSeam(l, i) = 1;
                end
            end
        end
    end

    figure(3), imshow(uint8(isSeam.*255));
    
    % resize image
    for i = 1 : w2
        [ T, idx ] = max(isSeam(:, i));
        res((1:idx-1), i, :) = pre_img((1:idx-1), i, :);
        res((idx:h2-t), i, :) = pre_img((idx+1:h2+1-t), i, :);
    end

    figure(4), imshow(res);
end

imwrite(res, 'SeamCarvingResult.jpg', 'jpg');