function removedMask = removeBackground(grayImage)

    [rows, columns, channels] = size(grayImage);

    if channels > 1
        error("removeBackground: grayImage isn't gray scale")
    end

    gaussian = imgaussfilt(grayImage, rows*columns/200000);
    whiteBackground = (quantile(grayImage, 0.5, 'all') > mean(grayImage, 'all'));
    filtered = imbinarize(gaussian, graythresh(gaussian));
    if whiteBackground
        filtered = ~filtered;
    end
    filtered = imfill(filtered, 'holes');
    se = strel('disk', 10);
    filtered = imerode(filtered, se);
    binary = imfill(filtered, 'holes');

    convexHull = bwconvhull(binary);

removedMask = convexHull;