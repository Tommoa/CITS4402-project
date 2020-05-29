% A function that reads in a training image, removes the background from the
% image, finds the SURF features in the image and loads relevant information
% into a structure that is then returned.
function Train_Feats = read_in_training_img(img_name)

%Scales = [1,0.75,0.5,0.25];
Scales = [1,0.5];

Im = imread(fullfile(img_name)) ;
Im = rgb2gray(Im);
% If we don't remove the background from the image, we found that you would
% very often end up with features that were not a part of the main object. As
% such, we remove everything that's not in the mask from removeBackground
fullmask = removeBackground(Im);
Im = bsxfun(@times, Im, cast(fullmask, 'like', Im));

for ii = 1:(length(Scales))
    Im_scale = Scales(ii);
    Im2 = imresize(Im,Im_scale);
    mask = imresize(fullmask, Im_scale);
    %mask = removeBackground(Im2);
    %Im2 = bsxfun(@times, Im2, cast(mask, 'like', Im2));

    FPoints = detectSURFFeatures(Im2);
    [Feats, FPoints] = extractFeatures(Im2, FPoints);

    s(ii).name = img_name;
    s(ii).scale = Im_scale;
    s(ii).FPoints = FPoints;
    s(ii).Feats = Feats;
    s(ii).mask = mask;
end

Train_Feats = s;



