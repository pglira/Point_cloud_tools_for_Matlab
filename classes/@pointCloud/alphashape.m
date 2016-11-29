function obj = alphashape(obj, r, varargin)
% ALPHASHAPE Planar alpha shape of point cloud.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% This function computes the planar alpha shape with specified radius of a point
% cloud. The alpha shape is saved to the property 'hull' of the point cloud.
% ------------------------------------------------------------------------------
% INPUT
% 1 r
%     Alpha shape radius.
%
% 2 ['NthPoi', nthPoi]
%     Only every nthPoi point of the point cloud is used for the computation of
%     the alpha shape. This option can also be helpful to eliminate outliers.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Compute the alpha shape of a point cloud with radius = 20.
%     X = [rand(1000,1)*100 rand(1000,1)*50 rand(1000,1)];
%     pc = pointCloud(X, 'pc');
%     pc = pc.alphashape(10);
%     pc.plot;
%     plot(pc.hull(:,1), pc.hull(:,2), 'r', 'LineWidth', 2)
%
% 2 Accelerated computation of the alpha shape by selecting a subset of points.
%   (continuation of example 1)
%     pc = pc.alphashape(10, 'NthPoi', 2);
% ------------------------------------------------------------------------------
% pg@geo.tuwien.ac.at
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired(  'r'        , @(x) isnumeric(x) && x>0);
p.addParameter('NthPoi', 1, @(x) isnumeric(x) && x>0);
p.parse(r, varargin{:});
p = p.Results;
% Clear required input to avoid confusion
clear r

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'ALPHASHAPE'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label: ''%s''', obj.label));
msg('V', p.r, 'IN: alpha shape radius');

% Alpha shape ------------------------------------------------------------------

% Just use planar coordinates
X = obj.X(1:p.NthPoi:end,1:2);

% Eliminate multiple points
X = unique(X, 'rows');

% Delaunay triangulation
dt = delaunayTriangulation(X);

% Circumradius of all simplices
[~, rcc] = circumcenter(dt);

% Create (non delaunay) triangulation without simplices with circumradius < r
t = triangulation(dt(rcc < p.r, :), dt.Points(:,1:2));

% Facets referenced by only one simplex
[~, alphaShape] = freeBoundary(t);

% Add first point to the end so that polygon is closed
alphaShape(end+1,:) = alphaShape(1,:);

% Convert polygon contour to clockwise vertex ordering
[alphaShapeCw(:,1), alphaShapeCw(:,2)] = poly2cw(alphaShape(:,1), alphaShape(:,2));

% Save as object property
obj.hull = alphaShapeCw;

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

end