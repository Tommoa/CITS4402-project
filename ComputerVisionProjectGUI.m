function varargout = ProjectGUI(varargin)
% PROJECTGUI MATLAB code for ProjectGUI.fig
%      PROJECTGUI, by itself, creates a new PROJECTGUI or raises the existing
%      singleton*.
%
%      H = PROJECTGUI returns the handle to a new PROJECTGUI or the handle to
%      the existing singleton*.
%
%      PROJECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECTGUI.M with the given input arguments.
%
%      PROJECTGUI('Property','Value',...) creates a new PROJECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProjectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProjectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProjectGUI

% Last Modified by GUIDE v2.5 27-May-2020 16:50:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProjectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProjectGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ProjectGUI is made visible.
function ProjectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProjectGUI (see VARARGIN)

% Choose default command line output for ProjectGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ProjectGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProjectGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_feature_struct.
function load_feature_struct_Callback(hObject, eventdata, handles)
% hObject    handle to load_feature_struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Feat_struct_name, Feat_struct_dir] = uigetfile('*.mat', 'Select feature structure .mat file');

S = load(fullfile(Feat_struct_dir, Feat_struct_name), 'train_feats');

handles.train_feats = S.train_feats;

set(handles.status_text,'String','loaded reference images data');
guidata(hObject,handles);
drawnow();

% --- Executes on button press in read_in_training_imgs.
function read_in_training_imgs_Callback(hObject, eventdata, handles)
% hObject    handle to read_in_training_imgs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir;

set(handles.status_text,'String','loading training images...');
guidata(hObject,handles);
drawnow();

handles.train_feats = read_in_training_dir(selpath);

set(handles.status_text,'String','training images loaded');

guidata(hObject,handles);


% --- Executes on button press in SaveModel.
function SaveModel_Callback(hObject, eventdata, handles)
% hObject    handle to SaveModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uiputfile;

train_feats = handles.train_feats;

save(fullfile(path,file), 'train_feats');

disp_str = sprintf('Model saved as "%s"', fullfile(path,file));

set(handles.status_text,'String',disp_str);
guidata(hObject,handles);
drawnow();

% --- Executes on button press in load_scene.
function load_scene_Callback(hObject, eventdata, handles)
% hObject    handle to load_scene (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Scene_img_name, Scene_img_dir] = uigetfile({'*.*'}, 'Select an image');  %User selects image file
Scene_img_path = fullfile(Scene_img_dir,Scene_img_name);
handles.Scene_img = imread(Scene_img_path);               %Read image from filepath
axes(handles.MainAxes);                                 %link method to left axes
imshow(handles.Scene_img);                               %load image of left axes

guidata(hObject,handles);

% --- Executes on button press in find_objects.
function find_objects_Callback(hObject, eventdata, handles)
% hObject    handle to find_objects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

warning('off','all');

set(handles.status_text,'String','Started search...');
guidata(hObject,handles);
drawnow();

Sc_img_gr = rgb2gray(handles.Scene_img);
Sc_FPoints = detectSURFFeatures(Sc_img_gr);
[Sc_Feats, Sc_FPoints] = extractFeatures(Sc_img_gr, Sc_FPoints);

ref_img_struct = handles.train_feats;

obj_stc = ref_img_struct.objects;

handles.objects_found_stc = [];
handles.objects_point_mathes = struct;

jj = 1;

transforms = {};
masks = {};
found_images = {};
all_sc_inlier_pts = {};
all_obj_inlier_pts = {};
all_obj_scales = {};

disp_str = sprintf('Objects found:\n');

for ii = 1:length(obj_stc)
    [found, inlier_points_im, inlier_points_sc, transform, ref_num] = ... 
        search_for_object(Sc_Feats, Sc_FPoints, obj_stc(ii));
    if (found == true)
        handles.objects_found_stc(jj).obj_name      = obj_stc(ii).obj_name;
        handles.objects_found_stc(jj).inlier_pts_sc = inlier_points_sc;
        handles.objects_found_stc(jj).inlier_pts_im = inlier_points_im;
        handles.objects_found_stc(jj).tform         = transform;
        handles.objects_found_stc(jj).ref_num       = ref_num;
        
        image = imread(obj_stc(ii).images(ref_num).name);
        handles.objects_found_stc(jj).image         = image;
        
        scale = obj_stc(ii).images(ref_num).scale;
        handles.objects_found_stc(jj).scale         = scale;

        mask = obj_stc(ii).images(ref_num).mask;

        img = image;
        transforms = [transforms {transform}];
        masks = [masks {mask}];
        found_images = [found_images {img}];
        all_sc_inlier_pts = [all_sc_inlier_pts {inlier_points_sc}];
        all_obj_inlier_pts = [all_obj_inlier_pts {inlier_points_im}];
        all_obj_scales = [all_obj_scales {scale}];
        
        axes(handles.MainAxes);
        
        % always show images of object found if nothing else
        imgOverlay = join_imgs_side(handles.Scene_img, found_images);
        imshow(imgOverlay);
        hold 'on';
        if(handles.show_lines == true)
            showMatchedFeaturesMulti(handles.Scene_img, found_images, all_sc_inlier_pts, all_obj_inlier_pts, all_obj_scales, masks, transforms);
        end
        if(handles.show_outlines == true)
            %
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

% --- Executes on button press in lines_toggle.
function lines_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to lines_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lines_toggle

handles.show_lines = get(hObject,'Value');
guidata(hObject,handles);

% --- Executes on button press in outline_toggle.
function outline_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to outline_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of outline_toggle

handles.show_outlines = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function lines_toggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lines_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.show_lines = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function outline_toggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outline_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.show_outlines = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in Search_through_all_scenes.
function Search_through_all_scenes_Callback(hObject, eventdata, handles)
% hObject    handle to Search_through_all_scenes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir;

set(handles.data_collection_output,'String','Reading in Scene images');
guidata(hObject,handles);
drawnow();

handles.Scene_Img_Struct = read_in_scene_dir(selpath);

set(handles.data_collection_output,'String','Scene images loaded');
guidata(hObject,handles);
drawnow();

EachDiffObjectsFound = {};
Difficulties = {};

for each_diff = 1:length(handles.Scene_Img_Struct)
    DataOutput = {};
    difficulty = handles.Scene_Img_Struct(each_diff).difficulty;
    images = handles.Scene_Img_Struct(each_diff).images;
    names = handles.Scene_Img_Struct(each_diff).im_names;
    for each_img = 1:length(images)
        handles.Scene_img = images{each_img};
        [pth,img_name,ext] = fileparts(names{each_img});
        LineOutput = {img_name};
        
        %start modified version of isolate objects
        warning('off','all');
        set(handles.status_text,'String','Started search...');
        guidata(hObject,handles);
        drawnow();
        Sc_img_gr = rgb2gray(handles.Scene_img);
        Sc_FPoints = detectSURFFeatures(Sc_img_gr);
        [Sc_Feats, Sc_FPoints] = extractFeatures(Sc_img_gr, Sc_FPoints);

        ref_img_struct = handles.train_feats;

        obj_stc = ref_img_struct.objects;

        handles.objects_found_stc = [];
        handles.objects_point_mathes = struct;

        jj = 1;

        found_images = {};
        all_sc_inlier_pts = {};
        all_obj_inlier_pts = {};
        all_obj_scales = {};
        masks = {};
        transforms = {};

        disp_str = sprintf('Objects found:\n');

        for ii = 1:length(obj_stc)
            [found, inlier_points_im, inlier_points_sc, transform, ref_num] = ... 
                search_for_object(Sc_Feats, Sc_FPoints, obj_stc(ii));
            if (found == true)
                LineOutput = [LineOutput, obj_stc(ii).obj_name];
                handles.objects_found_stc(jj).obj_name      = obj_stc(ii).obj_name;
                handles.objects_found_stc(jj).inlier_pts_sc = inlier_points_sc;
                handles.objects_found_stc(jj).inlier_pts_im = inlier_points_im;
                handles.objects_found_stc(jj).tform         = transform;
                handles.objects_found_stc(jj).ref_num       = ref_num;

                image = imread(obj_stc(ii).images(ref_num).name);
                handles.objects_found_stc(jj).image         = image;

                scale = obj_stc(ii).images(ref_num).scale;
                handles.objects_found_stc(jj).scale         = scale;

                mask = obj_stc(ii).images(ref_num).mask;

                img = image;
                found_images = [found_images {img}];
                masks = [masks {mask}];
                transforms = [transforms {transform}];
                all_sc_inlier_pts = [all_sc_inlier_pts {inlier_points_sc}];
                all_obj_inlier_pts = [all_obj_inlier_pts {inlier_points_im}];
                all_obj_scales = [all_obj_scales {scale}];

                axes(handles.MainAxes);

                % always show images of object found if nothing else
                imgOverlay = join_imgs_side(handles.Scene_img, found_images);
                imshow(imgOverlay);
                hold 'on';
                if(handles.show_lines == true)
                    showMatchedFeaturesMulti(handles.Scene_img, found_images, all_sc_inlier_pts, all_obj_inlier_pts, all_obj_scales, masks, transforms);
                end
                if(handles.show_outlines == true)
                    %
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
        LineOutput;
        DataOutput = [DataOutput, {LineOutput}];
    end
    EachDiffObjectsFound = [EachDiffObjectsFound; {DataOutput}];
    Difficulties = [Difficulties; difficulty];
end

disp_str = "";
for ii = 1:length(EachDiffObjectsFound)
    EachDiffObjectsFound{ii};
    answerFile = sprintf('Scene_Objects-%s.txt',Difficulties{ii});
    [true_pos, total, false_pos] = checkScore(EachDiffObjectsFound{ii}, answerFile);
    %temp = num2cell([20,25,3]);
    %[true_pos,total,false_pos] = deal(temp{:});
    
    disp_str = sprintf('%s %s: %i/%i correctly found. %i false positive search\n', disp_str, Difficulties{ii},true_pos, total, false_pos);   
end

set(handles.data_collection_output,'String',disp_str);
guidata(hObject,handles);
drawnow();

