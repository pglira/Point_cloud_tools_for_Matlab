function obj = createRaster(obj, varargin)
% CREATERASTER Create raster from point cloud.

% Input parsing ----------------------------------------------------------------

validRasterValue = {'average' 'linear' 'mask' 'plane'};

p = inputParser;
p.addParameter('CellSize'     , 1        , @(x) isnumeric(x) && x>0);
p.addParameter('RasterValue'  , 'average', @(x) any(strcmpi(x, validRasterValue)));
p.addParameter('SearchRadius' , 3        , @(x) isnumeric(x) && x>0); % for 'RasterValue' 'average' and 'plane'
p.parse(varargin{:});
p = p.Results;

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'RASTER'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));
msg('I', procHierarchy, sprintf('IN: RasterValue = ''%s''', p.RasterValue));
msg('V', p.CellSize, 'IN: CellSize', 'Prec', 2);
if any(strcmpi(p.RasterValue, {'average' 'plane'}))
    msg('V', p.SearchRadius, 'IN: SearchRadius', 'Prec', 2);
end

% Create query points ----------------------------------------------------------

% Origin (lower left point) of points
lim.min = min(obj.X(obj.act,[1 2]));
% Round origin (raster maps have coincident cell centers if mod(100, p.CellSize) == 0)
lim.min = (floor(lim.min/100))*100;

% Find raster cells in which points lie (starts with 0/0 at lower left corner (o))
% +-----+-----+-----+
% + 1/0 | 1/1 | 1/2 |
% +-----+-----+-----+
% + 0/0 | 0/1 | 0/2 |
% o-----+-----+-----+
rowCol = [floor((obj.X(obj.act,1)-lim.min(1))/p.CellSize) ...
          floor((obj.X(obj.act,2)-lim.min(2))/p.CellSize)];

% Remove multiple points
rowCol = unique(rowCol, 'rows');

% Transformation of indices to coordinate system ('query points')
xq = lim.min(1)+p.CellSize/2+rowCol(:,1)*p.CellSize;
yq = lim.min(2)+p.CellSize/2+rowCol(:,2)*p.CellSize;

% Assign RasterValue -----------------------------------------------------------

% Moving average
if strcmpi(p.RasterValue, 'average')
    idxAct = find(obj.act);
    ns = createns(obj.X(idxAct,[1 2]));
    idxSearchRadius = ns.rangesearch([xq yq], p.SearchRadius);
    zq = cellfun(@(x) mean(obj.X(idxAct(x),3)), idxSearchRadius);
end

% Linear interpolation
if strcmpi(p.RasterValue, 'linear')
    F = scatteredInterpolant(obj.X(obj.act,1), obj.X(obj.act,2), obj.X(obj.act,3), 'linear', 'none');
    zq = F(xq, yq);
end

% Mask
if strcmpi(p.RasterValue, 'Mask')
    zq = 1;
end

% Moving planes
if strcmpi(p.RasterValue, 'plane')
    idxAct = find(obj.act);
    msg('S', {procHierarchy{:} 'BUILD 2D KD-TREE'});
    ns = createns(obj.X(idxAct,[1 2]));
    msg('E', {procHierarchy{:} 'BUILD 2D KD-TREE'});
    msg('S', {procHierarchy{:} 'NNSEARCH'});
    idxSearchRadius = ns.rangesearch([xq yq], p.SearchRadius);
    msg('E', {procHierarchy{:} 'NNSEARCH'});

    msg('S', {procHierarchy{:} 'PLANE INTERPOLATION'});
    for c = 1:numel(xq)

        x = obj.X(idxAct(idxSearchRadius{c}),1);
        y = obj.X(idxAct(idxSearchRadius{c}),2);
        z = obj.X(idxAct(idxSearchRadius{c}),3);

        xm = mean(x);
        ym = mean(y);
        zm = mean(z);

        C = cov([x-xm, y-ym, z-zm]);
        [V, ~] = eig(C);
        n = V(:,1);

        if numel(n) ~= 3
            zq(c) = NaN;
        else
            zq(c) = zm - (n(1)*(xq(c)-xm) + n(2)*(yq(c)-ym)) / n(3);
        end

    end
    msg('E', {procHierarchy{:} 'PLANE INTERPOLATION'});

end

% Create GeoTiff ---------------------------------------------------------------

% Size of data array
sizeA = max(rowCol)-min(rowCol)+1;

% World matrix
W = [p.CellSize           0 min(xq)
              0 -p.CellSize max(yq)];

% Create spatialref.MapRasterReference object for GeoTiff
R = maprasterref(W, [sizeA(2) sizeA(1)]); % cols -> x, rows -> y

% Initialize data array with noData values
A = NaN(sizeA);

% Linear indices
idxLin = sub2ind(size(A), rowCol(:,1)-min(rowCol(:,1))+1, ...
                          rowCol(:,2)-min(rowCol(:,2))+1);

% Set data values
A(idxLin) = zq;

% Transform A, so that element 1,1 is upper, left corner (min(xq), max(yq))
A = flipud(A');

% Raster reduction point
if strcmpi(p.RasterValue, 'mask')
    RedPoi = [obj.redPoi(1) obj.redPoi(2) 0]; % no height reduction
else
    RedPoi = obj.redPoi;
end

% Add grid object to pointCloud object
obj.raster = raster({A R}, ...
                    obj.label, ...
                    'RedPoi', RedPoi);

% End --------------------------------------------------------------------------

msg('E', procHierarchy);

% 4Debug -----------------------------------------------------------------------

% save2('n:\Dropbox\Matlab\Scripts\2013_05\testgrid.xyz', [xq yq zeros(numel(xq),1)], '%.3f %.3f %.3f\n');

end