function removedMask = removeBackground(grayImage)

    [rows, columns, channels] = size(grayImage);

    if channels > 1
        error("removeBackground: grayImage isn't gray scale")
    end

    % You might be wondering... why use a straight binary filter
    % instead of going for edges?
    % We found that doing edge detection was often unreliable, as the
    % background surfaces - while generally of a uniform colour - had some
    % minor imperfections that would be found as being lines.
    % By using a binary filter, we had much better reliability with getting
    % the area around an object as opposed to random lines that may not be
    % related to the object.

    % Do a gaussian filter to make the image smoothed. This helps get rid of
    % some of the imperfections in the background.
    gaussian = imgaussfilt(grayImage, rows*columns/200000);
    % We can determine if the background is white or black by comparing the
    % mean of the grayed image with the median
    whiteBackground = (quantile(grayImage, 0.5, 'all') > mean(grayImage, 'all'));
    filtered = imbinarize(gaussian, graythresh(gaussian));
    % If we have a white background, we need to flip the binarized image for
    % our filter
    if whiteBackground
        filtered = ~filtered;
    end
    % Fill in the holes in the image
    filtered = imfill(filtered, 'holes');
    % Erode so that points not a part of the main object are removed
    se = strel('disk', 10);
    filtered = imerode(filtered, se);
    % Fill in the holes
    binary = imfill(filtered, 'holes');

    % Do a convex hull so we cover the entire object
    convexHull = bwconvhull(binary);

removedMask = convexHull;
