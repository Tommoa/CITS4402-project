function Scenes_Img_Struct = read_in_scene_dir(sc_dir_path)

diff_dir = dir(sc_dir_path);

s = struct;
for ii = 3:length(diff_dir)
    sc_dir = dir(fullfile(sc_dir_path,diff_dir(ii).name));
    s(ii-2).difficulty = diff_dir(ii).name;
    s(ii-2).images = {};
    s(ii-2).im_names = {};
    for jj = 3:length(sc_dir)
        image = imread(fullfile(sc_dir(jj).folder, sc_dir(jj).name));
        name = sc_dir(jj).name;
        s(ii-2).images = [s(ii-2).images {image}];
        s(ii-2).im_names = [s(ii-2).im_names {name}];
    end 
end

Scenes_Img_Struct = s;

end
