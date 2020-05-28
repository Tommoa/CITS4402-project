function show_matched_masks(scene_image, object_images, masks, transforms, scales)
    colours = ['r','g','b','c','m','y','k','w'];

    num_objs = length(object_images);
    each_obj_h = size(scene_image,1)/num_objs;
    for ii = 1:num_objs
        colour = colours(1 + mod(ii-1, length(colours)));
        I1 = scene_image;
        I2 = object_images{ii};
        offset1 = fliplr([0 0]);
        offset2 = fliplr([(ii-1)*each_obj_h 0]);
        offset2 = offset2 + fliplr([0 size(scene_image,2)]);

        scale = scales{ii};
        scale2 = size(I2,1)/size(I1,1)*num_objs;

        current_mask = bwboundaries(masks{ii});
        current_mask = current_mask{1};
        current_mask = fliplr(current_mask);
        % Test masks
        test_mask = bwboundaries(masks{ii});
        test_mask = fliplr(test_mask{1});
        test_mask = transformPointsForward(transforms{ii}, test_mask);
        test_mask = bsxfun(@plus, test_mask, offset1);
        p = patch(test_mask(:, 1), test_mask(:, 2), colour);
        p.FaceVertexAlphaData = 0.3;
        p.FaceAlpha = 'flat';

        % For the training images
        current_mask = bsxfun(@rdivide, current_mask, scale);
        current_mask = bsxfun(@rdivide, current_mask, scale2);
        current_mask = bsxfun(@plus, current_mask, offset2);
        p = patch(current_mask(:, 1), current_mask(:, 2), colour);
        p.FaceVertexAlphaData = 0.3;
        p.FaceAlpha = 'flat';
    end
