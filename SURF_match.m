function SURF_match(img1, img2, img1_scale)

%img_size = [800,1200];

Ia = imread(fullfile(img1)) ;
Ia = rgb2gray(Ia);
%Ia = imresize(Ia,img_size);
Ia = imresize(Ia,img1_scale);
Ib = imread(fullfile(img2)) ;
Ib = rgb2gray(Ib);
%Ib = imresize(Ib, img_size);

%{
figure;
imshow(Ia);
title('Image 1');

figure;
imshow(Ib);
title('Image 2');
%}

Points_a = detectSURFFeatures(Ia);
Points_b = detectSURFFeatures(Ib);

%{
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
%}

[Feat_a, Points_a] = extractFeatures(Ia, Points_a);
[Feat_b, Points_b] = extractFeatures(Ib, Points_b);

Pairs = matchFeatures(Feat_a, Feat_b);

Matched_P_a = Points_a(Pairs(:, 1), :);
Matched_P_b = Points_b(Pairs(:, 2), :);
figure;
showMatchedFeatures(Ia, Ib, Matched_P_a, Matched_P_b, 'montage');
title('Putatively Matched Points (Including Outliers)');

try
    [tform, inlier_points_a, inlier_points_b] = ...
        estimateGeometricTransform(Matched_P_a, Matched_P_b, 'affine', 'MaxNumTrials' ,2000, 'MaxDistance', 10);
    if (size(inlier_points_a,1) > 4 )
        figure;
        showMatchedFeatures(Ia, Ib, inlier_points_a, inlier_points_b, 'montage');
        title('Matched Points (Inliers Only)');
    else
        fprintf('Not enough matching points found\n');
    end
catch Err
    fprintf('Object not found in scene\n');
end

%output = inlier_points_a;