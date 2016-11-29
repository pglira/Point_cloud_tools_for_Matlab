function objNew = copy(obj)
% COPY Create an indipendent copy of a point cloud object.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% The pointCloud class is a subclass of the handle class, i.e. it is NOT a value
% class. More informations about the difference between handle and value classes
% can be found in [1]. To create an indipendent copy of a point cloud object,
% this method can be used.
% ------------------------------------------------------------------------------
% OUTPUT
% 1 [objNew]
%   Copy of point cloud object.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Copy an object and select a subset of points in the new object.
%   pcOrig = pointCloud('Lion.xyz');
%   pcCopy = pcOrig.copy;
%   % Attention: if instead of the previous line 'pcCopy = pcOrig;' is used,
%   % pcOrig and pcCopy share the same object, i.e. they are NOT indipendent.
%   pcOrig.select('RandomSampling', 10); % select a subset of points in pcOrig
%   pcOrig.info; % in pcOrig only a subset of points is selected
%   pcCopy.info; % in pcCopy still all points are selected
% ------------------------------------------------------------------------------
% REFERENCES
% [1] % https://de.mathworks.com/help/matlab/matlab_oop/comparing-handle-and-value-classes.html
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Reference: https://de.mathworks.com/matlabcentral/newsreader/view_thread/257925

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'COPY'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Copy -------------------------------------------------------------------------

% Deactivate logging
originalLogLevel = msg('O', 'GetLogLevel');
msg('O', 'SetLogLevel', 'off');

% Instantiate new object of the same class
objNew = feval(class(obj), obj.X);

% Copy all non-hidden properties
p = properties(obj);
for i = 1:length(p)
    if ~any(strcmp(p{i}, {'cog' 'lim' 'noPoints'}))
        objNew.(p{i}) = obj.(p{i});
    end
end

% Reactivate logging
msg('O', 'SetLogLevel', originalLogLevel);

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end