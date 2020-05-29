% A function that detects objects in a scene by extracting SURF features from
% a scene image and comparing it to a number of reference images.
function images = detect_objects(hObject, handles)

    set(handles.status_text,'String','Started search...');
    guidata(hObject,handles);
    drawnow();

    Sc_img_gr = rgb2gray(handles.Scene_img);
    Sc_FPoints = detectSURFFeatures(Sc_img_gr);
    [Sc_Feats, Sc_FPoints] = extractFeatures(Sc_img_gr, Sc_FPoints);

    ref_img_struct = handles.train_feats;

    obj_stc = ref_img_struct.objects;

    axes(handles.MainAxes);

    transforms = {};
    masks = {};
    found_images = {};
    all_sc_inlier_pts = {};
    all_obj_inlier_pts = {};
    all_obj_scales = {};
    images = {};

    disp_str = sprintf('Objects found:\n');

    % For each reference object
    for ii = 1:length(obj_stc)
        [found, inlier_points_im, inlier_points_sc, transform, ref_num] = ... 
            search_for_object(Sc_Feats, Sc_FPoints, obj_stc(ii));
        if (found == true)
            % We've found an object! Get the metadata...
            image = imread(obj_stc(ii).images(ref_num).name);
            scale = obj_stc(ii).images(ref_num).scale;
            mask = obj_stc(ii).images(ref_num).mask;
            images = [images {obj_stc(ii).obj_name}]; %#ok<AGROW>
            transforms = [transforms {transform}]; %#ok<AGROW>
            masks = [masks {mask}]; %#ok<AGROW>
            found_images = [found_images {image}]; %#ok<AGROW>
            all_sc_inlier_pts = [all_sc_inlier_pts {inlier_points_sc}]; %#ok<AGROW>
            all_obj_inlier_pts = [all_obj_inlier_pts {inlier_points_im}]; %#ok<AGROW>
            all_obj_scales = [all_obj_scales {scale}]; %#ok<AGROW>


            % always show images of object found if nothing else
            imgOverlay = join_imgs_side(handles.Scene_img, found_images);
            imshow(imgOverlay);
            hold 'on';
            if(handles.show_lines == true)
                % Show the lines between features
                showMatchedFeaturesMulti(handles.Scene_img, found_images, all_sc_inlier_pts, all_obj_inlier_pts, all_obj_scales, masks, transforms);
            end
            if(handles.show_outlines == true)
                % Show the masks used in the reference images
                show_matched_masks(handles.Scene_img, found_images, masks, transforms, all_obj_scales);
            end
            hold 'off';

            disp_str = sprintf('%s - %s\n', disp_str, obj_stc(ii).obj_name);

            set(handles.status_text,'String',disp_str);
            guidata(hObject,handles);
            drawnow();
        end
    end

    disp_str = sprintf('%s finished search\n', disp_str);

    set(handles.status_text,'String',disp_str);
    guidata(hObject,handles);
    drawnow();


