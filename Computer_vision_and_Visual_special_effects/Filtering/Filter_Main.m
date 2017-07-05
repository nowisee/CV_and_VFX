function [result1 result2 result3] = Filter_Main

img = imread('lena_N.jpg');
F_SIZE = 3;
sigma = 1;

result1 = Mean_Filter(img, F_SIZE);
result2 = Median_Filter(img, F_SIZE);
result3 = Gaussian_Filter(img, F_SIZE, sigma);

subplot(2,2,1), imshow(img), title('Input Image');
subplot(2,2,2), imshow(result1), title('Mean Filter');
subplot(2,2,3), imshow(result2), title('Median Filter');
subplot(2,2,4), imshow(result3), title('Gaussian Filter');
