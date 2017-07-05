clc;
clear all;

step = 100;

img1 = imread('cross1.jpg');
img2 = imread('cross2.jpg');

for T = 1 : step
    t_img = (1-T/step)*img1 + T/step*img2;
    imshow(t_img);
    drawnow;
end