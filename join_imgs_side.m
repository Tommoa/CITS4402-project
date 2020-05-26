function joined_img = join_imgs_side(Scene_img, Object_Images)

    num_objs = length(Object_Images);
    obj_im = Object_Images;
    
    for ii = 1:num_objs
        obj_im{ii} = imresize(obj_im{ii},1/num_objs);
    end
    
    obj_col_img = [];
    for ii = 1:num_objs
        obj_col_img = [obj_col_img; obj_im{ii}];
    end
    
    padded_height = max(size(Scene_img,1), size(obj_col_img,1));
    
    sc_pad = max(0,padded_height - size(Scene_img,1));
    Scene_img = padarray(Scene_img, [sc_pad 0], 0, 'post');
    
    obj_col_pad = max(0,padded_height - size(obj_col_img,1));
    obj_col_img = padarray(obj_col_img, [obj_col_pad 0], 0, 'post');
    
    joined_img = [Scene_img obj_col_img];
end