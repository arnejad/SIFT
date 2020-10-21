
%EXAMPLE

I = imread("lena.jpg");
I = im2double(I);
I = imresize(I, 0.5);

[PoIs, descs] = sift(I);

figure(1);
subplot(1,2,1)
imshow(I);
hold on
scatter( PoIs(:,2), PoIs(:,1), 10, 'filled')
hold off
title("Keypoints' locations")

subplot(1,2,2)
imshow(I);
hold on
angs=0:10:359;
for i=1:size(PoIs,1)
    for j=1:36
        if PoIs(i,j+2) ~= 0
            quiver(PoIs(i,2),PoIs(i,1), cos(angs(j))*PoIs(i,j+2)*200, sin(angs(j))*PoIs(i,j+2)*200,'r')
        end
    end
end
title("keypoints' orientations")
