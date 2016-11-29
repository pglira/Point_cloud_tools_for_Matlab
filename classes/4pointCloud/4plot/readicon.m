function icon = readicon(p2icon)

[img, map] = imread(p2icon);

icon = ind2rgb(img, map);

% Make white pixels transparent
maskLogical = sum(icon,3) == 3;
maskLogical = repmat(maskLogical, [1, 1, 3]);
icon(maskLogical) = NaN;

end