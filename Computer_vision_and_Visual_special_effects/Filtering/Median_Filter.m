function result = Median_Filter(img, F_SIZE)

[h w] = size(img);
result = zeros(h, w, 'uint8');

t_arr = zeros(1, F_SIZE*F_SIZE);

h_len = floor(F_SIZE/2);
mda_index = ceil(F_SIZE*F_SIZE / 2);

for i = h_len+1 : h - h_len
    for j = h_len+1 : w - h_len
        cnt = 1;
        
        for k = -h_len : h_len
            for l = -h_len : h_len
                t_arr(1, cnt) = img(i+k, j+l);
                cnt = cnt + 1;
            end
        end
        
        t_arr = sort(t_arr);
        
        result(i, j) = t_arr(mda_index);
    end
end

end