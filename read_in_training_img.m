function Train_Feats = read_in_training_img(img_name)

Scales = [0.25,0.5,0.75,1];

Im = imread(fullfile(img_name)) ;
Im = rgb2gray(Im);

for ii = 1:(length(Scales))
    Im_scale = Scales(ii);
    Im2 = imresize(Im,Im_scale);

    FPoints = detectSURFFeatures(Im2);
    [Feats, FPoints] = extractFeatures(Im2, FPoints);

    s(ii).name = img_name;
    s(ii).scale = Im_scale;
    s(ii).FPoints = FPoints;
    s(ii).Feats = Feats;
end

Train_Feats = s;



