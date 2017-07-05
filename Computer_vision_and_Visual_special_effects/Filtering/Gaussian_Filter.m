function result = Gaussian_Filter(img, F_SIZE, sigma)

PI = 3.141592;

[h w] = size(img);
result = zeros(h, w, 'uint8');

Gaussian_F = zeros(F_SIZE);

h_len = floor(F_SIZE/2);

for k = -h_len : h_len
	for l = -h_len : h_len
        Gaussian_F(k+h_len+1, l+h_len+1) = 1 / (2*PI*(sigma*sigma)) * exp(-1*(k*k+l*l)/(2*sigma*sigma));
	end
end

for i = h_len+1 : h - h_len
    for j = h_len+1 : w - h_len
        temp = 0;
        
        for k = -h_len : h_len
            for l = -h_len : h_len
                temp = temp + img(i+k, j+l) * Gaussian_F(k+h_len+1, l+h_len+1);
            end
        end
        
        result(i, j) = temp;
    end
end

end