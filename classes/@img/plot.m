function plot(obj)

% Start ------------------------------------------------------------------------

procHierarchy = {'IMG' 'PLOT'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Image label = ''%s''', obj.label));

% Plot -------------------------------------------------------------------------

imshow(obj.file);
hold on;

% Image observations
plot(obj.x, -obj.y, 'r.'); % minus!!!!

% Principal point
if ~isempty(obj.x0) && ~isempty(obj.y0)
    plot(obj.x0, -obj.y0, 'y+', 'MarkerSize', 20);
end


% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end