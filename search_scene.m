function search_scene(ref_img_struct, scene_img_colour)

warning('off','all');

scene_img = rgb2gray(scene_img_colour);

skip_once_found = true;

Sc_FPoints = detectSURFFeatures(scene_img);
[SC_Feats, Sc_FPoints] = extractFeatures(scene_img, Sc_FPoints);

obj_stc = ref_img_struct.objects;

for ii = 1:length(obj_stc)
    fprintf('%s\n',obj_stc(ii).obj_name);
    found_obj = false;
    num_orien = size(obj_stc(ii).images,1);
    num_scales = size(obj_stc(ii).images,2);
    for jj = 1:(num_orien * num_scales)
        if (found_obj == false)
            img_stc = obj_stc(ii).images(jj);
            Pairs = matchFeatures(img_stc.Feats, SC_Feats);
            Matched_P_im = img_stc.FPoints(Pairs(:, 1), :);
            Matched_P_sc =      Sc_FPoints(Pairs(:, 2), :);

            try
                [tform, inlier_points_im, inlier_points_sc] = ...
                    estimateGeometricTransform(Matched_P_im, Matched_P_sc, 'affine', 'MaxNumTrials' ,2000, 'MaxDistance', 10);
            catch Err
                %fprintf('Object not found in scene\n');
                continue
            end
            if (length(Matched_P_im)* 0.2 < length(inlier_points_im) & length(unique(inlier_points_sc.Location(:,1))) > 3 & length(unique(inlier_points_sc.Location(:,2))) > 3)
            %if (length(unique(inlier_points_sc.Location(:,1))) > 3 & length(unique(inlier_points_sc.Location(:,2))) > 3)
                %fprintf('bigest dist between projected points = %3.2f\n', max(max(pdist2(inlier_points_sc.Location,inlier_points_sc.Location))));
                found_obj = true;
                %break
                %remove this in a bit
                figure;
                img = imread(img_stc.name);
                img = imresize(img, img_stc.scale);
                %imshow(img);
                showMatchedFeatures(img, scene_img_colour, inlier_points_im, inlier_points_sc, 'montage');
                title('Matched Points (Inliers Only)');
            else
                %fprintf('Not enough matching points found\n');
            end
        end
    end
    if (found_obj == true)
        fprintf('found %s\n',obj_stc(ii).obj_name);
    else
        fprintf('%s not found\n',obj_stc(ii).obj_name);
    end
end

warning('on','all');