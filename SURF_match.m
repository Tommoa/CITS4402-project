function SURF_match(img1, img2)

img_size = [800,1200];

Ia = imread(fullfile(img1)) ;
Ia = rgb2gray(Ia);
%Ia = imresize(Ia,img_size);
Ia = imresize(Ia,.3);
Ib = imread(fullfile(img2)) ;
Ib = rgb2gray(Ib);
%Ib = imresize(Ib, img_size);

figure;
imshow(Ia);
title('Image 1');

figure;
imshow(Ib);
title('Image 2');

Points_a = detectSURFFeatures(Ia);
Points_b = detectSURFFeatures(Ib);

figure;
imshow(Ia);
title('300 Strongest Feature Points from Image 1');
hold on;
plot(selectStrongest(Points_a, 300));

figure;
imshow(Ib);
title('300 Strongest Feature Points from Image 2');
hold on;
plot(selectStrongest(Points_b, 300));

[Feat_a, Points_a] = extractFeatures(Ia, Points_a);
[Feat_b, Points_b] = extractFeatures(Ib, Points_b);

Pairs = matchFeatures(Feat_a, Feat_b);

Matched_P_a = Points_a(Pairs(:, 1), :);
Matched_P_b = Points_b(Pairs(:, 2), :);
figure;
showMatchedFeatures(Ia, Ib, Matched_P_a, ...
    Matched_P_b, 'montage');
title('Putatively Matched Points (Including Outliers)');

[tform, inlier_points_a, inlier_points_b] = ...
    estimateGeometricTransform(Matched_P_a, Matched_P_b, 'affine');

figure;
showMatchedFeatures(Ia, Ib, inlier_points_a, ...
    inlier_points_b, 'montage');
title('Matched Points (Inliers Only)');