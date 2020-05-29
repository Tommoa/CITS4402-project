function varargout = ComputerVisionProjectGUI(varargin)
% ComputerVisionProjectGUI MATLAB code for ComputerVisionProjectGUI.fig
%      ComputerVisionProjectGUI, by itself, creates a new ComputerVisionProjectGUI or raises the existing
%      singleton*.
%
%      H = ComputerVisionProjectGUI returns the handle to a new ComputerVisionProjectGUI or the handle to
%      the existing singleton*.
%
%      ComputerVisionProjectGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ComputerVisionProjectGUI.M with the given input arguments.
%
%      ComputerVisionProjectGUI('Property','Value',...) creates a new ComputerVisionProjectGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ComputerVisionProjectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ComputerVisionProjectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ComputerVisionProjectGUI

% Last Modified by GUIDE v2.5 28-May-2020 16:03:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ComputerVisionProjectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ComputerVisionProjectGUI_OutputFcn, ...
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


% --- Executes just before ComputerVisionProjectGUI is made visible.
function ComputerVisionProjectGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ComputerVisionProjectGUI (see VARARGIN)

% Choose default command line output for ComputerVisionProjectGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ComputerVisionProjectGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ComputerVisionProjectGUI_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_feature_struct.
function load_feature_struct_Callback(hObject, ~, handles)
% hObject    handle to load_feature_struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Load pre-evaluated set of SURF features, masks and image meta data

%specify .mat file location
[Feat_struct_name, Feat_struct_dir] = uigetfile('*.mat', 'Select feature structure .mat file');
%load into structure
S = load(fullfile(Feat_struct_dir, Feat_struct_name));
%pass loaded structure to handles object
handles.train_feats = S;

% inform user that structure has been loaded
set(handles.status_text,'String','loaded reference images data');
guidata(hObject,handles);
drawnow();

% --- Executes on button press in read_in_training_imgs.
function read_in_training_imgs_Callback(hObject, ~, handles)
% hObject    handle to read_in_training_imgs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%select directory of reference images
% each folder of images will be run through extracting SURF features,
% calculating object masks and recording image file meta data

%specify reference image directory
selpath = uigetdir;
% this process can be slow to inform user that it has started and is
% operating
set(handles.status_text,'String','loading training images...');
guidata(hObject,handles);
drawnow();

% process directory and store results in handles structure
handles.train_feats = read_in_training_dir(selpath);

% inform user once finished
set(handles.status_text,'String','training images loaded');
guidata(hObject,handles);


% --- Executes on button press in SaveModel.
function SaveModel_Callback(hObject, ~, handles)
% hObject    handle to SaveModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%function to save model currently store in handles object to .mat file

%user specifies file location and name
[file, path] = uiputfile('*.mat');
%matlab can only save a standalone variable not a field of a structure
%directly so copy model to it's own vairable
train_feats = handles.train_feats;
%save model, specifying variable name. Matlab will not save large files for
%old versions of save method. Specify to use version 7.3 or above to save
%large structure
save(fullfile(path,file), '-struct', 'train_feats','-v7.3');
%inform user that model has been saved
disp_str = sprintf('Model saved as "%s"', fullfile(path,file));
set(handles.status_text,'String',disp_str);
guidata(hObject,handles);
drawnow();

% --- Executes on button press in load_scene.
function load_scene_Callback(hObject, ~, handles)
% hObject    handle to load_scene (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%load scne image to isolate objects in

%user specifies location of scene image
[Scene_img_name, Scene_img_dir] = uigetfile({'*.*'}, 'Select an image');  %User selects image file
Scene_img_path = fullfile(Scene_img_dir,Scene_img_name);
handles.Scene_img = imread(Scene_img_path);               %Read image from filepath
axes(handles.MainAxes);                                 %link method axes
imshow(handles.Scene_img);                               %load image on axes

guidata(hObject,handles);

% --- Executes on button press in find_objects.
function find_objects_Callback(hObject, ~, handles)
% hObject    handle to find_objects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%search for objects in image

%disable wanrings during operation as Matlab raises warnings when objects
%can't be found but in this case this is expected
warning('off','all');
%pass handles to method so it can access features structure and scene
%image. pass hObject so method can update staus box for user to see object
%found
detect_objects(hObject, handles);
warning('on','all'); %re-enable warnings

% --- Executes on button press in lines_toggle.
function lines_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to lines_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lines_toggle

%checkbox for if lines shouldbe drawn between matched SURF points
handles.show_lines = get(hObject,'Value');
guidata(hObject,handles);

% --- Executes on button press in outline_toggle.
function outline_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to outline_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of outline_toggle

%checkbox for if object outline masks should be overlayed
handles.show_outlines = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function lines_toggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lines_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%initialize if lines shouldbe drawn between matched SURF points when GUI
%opened
handles.show_lines = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function outline_toggle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outline_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%initialize if object outline masks should be overlayed when GUI opened
handles.show_outlines = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes on button press in Search_through_all_scenes.
function Search_through_all_scenes_Callback(hObject, eventdata, handles)
% hObject    handle to Search_through_all_scenes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%search through directory of all scene iage one by one and compare found
%images to text file listed object known to be in image and report result
%to user in data output box

%select path for directory of folder of different difficulty scene images
selpath = uigetdir;

%this process can be slow to make sure to inform user that it has started
set(handles.data_collection_output,'String','Reading in Scene images');
guidata(hObject,handles);
drawnow();

%store structure of features and meta data of scene images in handles
handles.Scene_Img_Struct = read_in_scene_dir(selpath);

%inform user that scne eimages have been processed
set(handles.data_collection_output,'String','Scene images loaded');
guidata(hObject,handles);
drawnow();

EachDiffObjectsFound = {};  %fprmatted cell array of all objects foudn in each image for each difficulty
Difficulties = {};          %hold string of each diffulty scne eimage being processed

%loop through each folder of different difficulty images
for each_diff = 1:length(handles.Scene_Img_Struct)
    DataOutput = {};
    difficulty = handles.Scene_Img_Struct(each_diff).difficulty;    %store difficulty
    images = handles.Scene_Img_Struct(each_diff).images;            %store all scene images for difficulty
    names = handles.Scene_Img_Struct(each_diff).im_names;           %store names of all scene images for difficulty
    %loop thtough each image in difficulty
    for each_img = 1:length(images)
        handles.Scene_img = images{each_img};                       %pass image to handles
        [pth,img_name,ext] = fileparts(names{each_img});            %get name of image without extention
        LineOutput = {img_name};
     	
        % Returns the names of the images found
        FoundImages = detect_objects(hObject, handles); %#ok<NASGU>
        LineOutput = [LineOutput, FoundImages];                     %created formatted cell array of objects found
        DataOutput = [DataOutput, {LineOutput}]; %#ok<AGROW>        %save to full data output cell array
    end
    EachDiffObjectsFound = [EachDiffObjectsFound; {DataOutput}]; %#ok<AGROW>
    Difficulties = [Difficulties; difficulty]; %#ok<AGROW>
end

disp_str = "";
%check results against known objects in images for each difficulty
for ii = 1:length(EachDiffObjectsFound)
    EachDiffObjectsFound{ii};
    answerFile = sprintf('Scene_Objects-%s.txt',Difficulties{ii});  %load answer file in main directory of GUI code. answer file has specific syntax name
    [true_pos, total, false_pos] = checkScore(EachDiffObjectsFound{ii}, answerFile);

    %grow string of results to show to user
    disp_str = sprintf('%s %s: %i/%i correctly found. %i false positive search\n', disp_str, Difficulties{ii},true_pos, total, false_pos);   
end

%display results to user
set(handles.data_collection_output,'String',disp_str);
guidata(hObject,handles);
drawnow();



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over lines_toggle.
function lines_toggle_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to lines_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
