% A function that reads a number of training images from a directory of
% of training images and returns a structure that contains all the information
% for the various training images.
function Train_Feats = read_in_training_dir(tr_dir_path)

tr_dir = dir(tr_dir_path);

s = struct;
% We start from 3 because of `.` and `..`
for ii = 3:length(tr_dir)
    obj_dir = dir(fullfile(tr_dir_path,tr_dir(ii).name));
    s(ii-2).obj_name = tr_dir(ii).name;
    s(ii-2).images = [];
    for jj = 3:length(obj_dir)
        im_struct = read_in_training_img(fullfile(obj_dir(jj).folder, obj_dir(jj).name));
        s(ii-2).images = [s(ii-2).images ; im_struct];
    end
end

Train_Feats = struct;
Train_Feats.dir_path = tr_dir_path;
Train_Feats.objects = s;
