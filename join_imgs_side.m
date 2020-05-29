% A utility function to join some number of object images to a scene image
% on the right hand side.
function joined_img = join_imgs_side(Scene_img, Object_Images)

    num_objs = length(Object_Images);
    obj_im = Object_Images;
    
    obj_col_img = [];
    % For each object...
    for ii = 1:num_objs
        try
            % Append the image to a number of other images
            obj_col_img = [obj_col_img; obj_im{ii}];
        catch
            % if it fails, then just display the image
            % Only likely reason for failure is different number of columns
            size(obj_col_img)
            size(obj_im{ii})
            figure;
            imshow(obj_col_img);
            figure;
            imshow(obj_im{ii});
            return;
        end
    end
    
    scale = size(Scene_img,1) / size(obj_col_img,1);
    
    % Scale the object images to the size of the scene image
    obj_col_img = imresize(obj_col_img, scale);
    
    % Pad the height if we need to
    padded_height = max(size(Scene_img,1), size(obj_col_img,1));
    
    sc_pad = max(0,padded_height - size(Scene_img,1));
    Scene_img = padarray(Scene_img, [sc_pad 0], 0, 'post');
    
    obj_col_pad = max(0,padded_height - size(obj_col_img,1));
    obj_col_img = padarray(obj_col_img, [obj_col_pad 0], 0, 'post');
    
    % Return the joined image
    joined_img = [Scene_img obj_col_img];
end
