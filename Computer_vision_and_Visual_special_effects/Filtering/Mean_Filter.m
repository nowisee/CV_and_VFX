function result = Mean_Filter(img, F_SIZE)

[h w] = size(img);
result = zeros(h, w, 'uint8');

Mean_F = ones(F_SIZE);
Mean_F = Mean_F./(F_SIZE * F_SIZE);

h_len = floor(F_SIZE/2);

for i = h_len+1 : h - h_len
    for j = h_len+1 : w - h_len
        temp = 0;
        
        for k = -h_len : h_len
            for l = -h_len : h_len
                temp = temp + img(i+k, j+l) * Mean_F(k+h_len+1, l+h_len+1);
            end
        end
        
        result(i, j) = temp;
    end
end

end