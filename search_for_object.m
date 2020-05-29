% A function searchs for an object within a scene and returns whether or not
% it is in the scene (found), what any inlier feature points are, the transform
% required to turn the object in the scene back to the reference image
% and the identifier of the reference image that was used.
function [found, inlier_points_im, inlier_points_sc, tform, reference_num] = search_for_object(Sc_Feats, Sc_FPoints, Object_struct)

warning('off','all');

found = false;
reference_num = 1;

num_orien = size(Object_struct.images,1);
num_scales = size(Object_struct.images,2);

% For each orientation and scale of the reference images
for jj = 1:(num_orien * num_scales)
    if (found == false)
        img_stc = Object_struct.images(jj);
        Pairs = matchFeatures(img_stc.Feats, Sc_Feats);
        Matched_P_im = img_stc.FPoints(Pairs(:, 1), :);
        Matched_P_sc =      Sc_FPoints(Pairs(:, 2), :);

        % If we find an affine tranformation, then its likely that we've
        % found an image in the scene, so we can return it.
        try
            [tform, inlier_points_im, inlier_points_sc] = ...
                estimateGeometricTransform(Matched_P_im, Matched_P_sc, 'affine', 'MaxNumTrials' ,1000, 'MaxDistance', 7);
        catch Err
            %fprintf('Object not found in scene\n');
            continue
        end

        num_unique = 4;
        % If the number of unique points found is below a threshold,
        % then its likely that we've not found an object, and instead have
        % just found a similar point
        if (length(unique(inlier_points_sc.Location(:,1))) > num_unique & length(unique(inlier_points_sc.Location(:,2))) > num_unique)
            x1 = unique(inlier_points_sc.Location(:,1));
            x2 = unique(inlier_points_sc.Location(:,2));
            for i = 2:length(x1)
                d = sqrt((x1(1,1)-x1(i,1))^2+(x2(1,1)-x2(i,1))^2);
                if(d>100 && d<3000)
                    reference_num = jj;
                    found = true;
                    return
                end
            end
        else
            % Not enough matching points found
        end
    end
end
