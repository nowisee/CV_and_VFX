clear;

I  = imread('000044_10.png');

A = I(:,:,2);

rotI = A;

%fig1 = imshow(rotI);

BW = edge(rotI,'canny');
figure, imshow(BW);

%----------------------------  ÀýÃë¼±  --------------------------------------

[y, x] = find(BW);
[w, h] = size(BW);

rhoLimit = floor(norm([w h]));
rho = (-rhoLimit:1:rhoLimit);

H = zeros(2*rhoLimit, 180);

for cnt = 1 : length(x)
    cnt2 = 1;
    for theta = -pi/2 : pi/180 : pi/2-pi/180
        rho = round(x(cnt).*cos(theta) + y(cnt).*sin(theta));
        H(rho+rhoLimit, cnt2) = H(rho+rhoLimit, cnt2) + 1;
        cnt2 = cnt2 + 1;
    end
end

theta = rad2deg(-pi/2 : pi/180 : pi/2-pi/180);
rho = -rhoLimit : rhoLimit-1;

figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
        'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(hot);

thresh = ceil(0.25*max(H(:)));

P = houghpeaks(H,5,'threshold', thresh);

x = theta(P(:,2));
y = rho(P(:,1));
plot(x,y,'s','color','black');

lines = houghlines(BW, theta, rho, P,'FillGap',5,'MinLength',7);   



figure, imshow(rotI), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len )
      max_len = len;
      xy_long = xy;
   end
end

plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');