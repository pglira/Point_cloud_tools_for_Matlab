function normals(obj, searchRadius, varargin)
% NORMALS Compute normal vectors of activated points.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% * The components of the normal vectors are saved into the attribute structure
%   of the point cloud:
%     * x component of n -> obj.A.nx
%     * y component of n -> obj.A.ny
%     * z component of n -> obj.A.nz
% * Additionally a roughness value corresponding to the standard deviation of
%   the residuals is saved as roughness attribute:
%     * roughness -> obj.A.roughness
% ------------------------------------------------------------------------------
% INPUT
% 1 [searchRadius]
%   Search radius for normal estimation.
% 
% 2 ['MinNoNeighbours', minNoNeighbours]
%   Minimum number of nearest neighbours. If less than minNoNeighbours
%   neighbours are found within the specified search radius, the normal vector
%   components are set to NaN.
%
% 3 ['MaxNoNeighbours', maxNoNeighbours]
%   Maximum number of nearest neighbours to use for normal vector estimation.
% ------------------------------------------------------------------------------
% OUTPUT
% 1 [obj]
%   Updated object.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Compute normals for a subset of points and visualize them.
%   pc = pointCloud('Lion.xyz');
%   pc.select('UniformSampling', 3);
%   pc.normals(1);
%   pc.plot('Color', 'r', 'MarkerSize', 5);
%   pc.plotNormals('Color', 'y', 'Scale', 5);
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired( 'searchRadius'        , @(x) numel(x)==1 && isnumeric(x) && x>0);
p.addParameter('MinNoNeighbours',   3, @(x) numel(x)==1 && isnumeric(x) && x>0);
p.addParameter('MaxNoNeighbours', Inf, @(x) numel(x)==1 && isnumeric(x) && x>0);
p.parse(searchRadius, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear searchRadius

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'NORMALS'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));

% Create normals attribute -----------------------------------------------------

if ~isfield(obj.A, 'nx'       ), obj.A.nx        = nan(size(obj.X,1),1); end
if ~isfield(obj.A, 'ny'       ), obj.A.ny        = nan(size(obj.X,1),1); end
if ~isfield(obj.A, 'nz'       ), obj.A.nz        = nan(size(obj.X,1),1); end
if ~isfield(obj.A, 'roughness'), obj.A.roughness = nan(size(obj.X,1),1); end

% NN search --------------------------------------------------------------------

msg('S', {'POINTCLOUD' 'NORMALS' 'NNSEARCH'});

% Query points
qp = obj.X(obj.act,:);

% Search of nn
idxNN = rangesearch(obj.X, qp, p.searchRadius); % result is cell array

msg('E', {'POINTCLOUD' 'NORMALS' 'NNSEARCH'});

% PCA --------------------------------------------------------------------------

msg('S',{'POINTCLOUD' 'NORMALS' 'PCA'});

% Initialization
n         = nan(size(qp,1),3);
roughness = nan(size(qp,1),1);

% PCA for each point
% parfor i = 1:size(qp,1)
for i = 1:size(qp,1)
    if numel(idxNN{i}) >= p.MinNoNeighbours

        if numel(idxNN{i}) > p.MaxNoNeighbours
            idxNN{i} = idxNN{i}(1:p.MaxNoNeighbours);
        end
            
        XNN = obj.X(idxNN{i},:); % includes neighbours AND query point!
        C = cov(XNN);

        % Solution 1 -> actual preference, as normal vector are primarily upwards
        [P, lambda] = pcacov(C);
        n(i,:) = P(:,3)';
        roughness(i,1) = sqrt(lambda(3)); % third component is smallest eigenvalue

        % Solution 2
        % [V, W]  = eig(C);
        % n(i,:)  = V(:,1); % normal vector
        % roughness(i,1) = sqrt(W(1,1)); % square root of eigenvalue (= standard deviation) corresponding to normal vector

    end
end

% tic;
% C = cellfun(@(x) cov(obj.X(x,:)), idxNN, 'UniformOutput', false);
% [P, lambda] = cellfun(@(x) pcacov(x), C, 'UniformOutput', false);
% N = cellfun(@(x) x(:,3)', P, 'UniformOutput', false);
% n = vertcat(N{:});
% roughness = cellfun(@(x) sqrt(x(3)), lambda);
% toc;

obj.A.nx(obj.act,1)        = n(:,1);
obj.A.ny(obj.act,1)        = n(:,2);
obj.A.nz(obj.act,1)        = n(:,3);
obj.A.roughness(obj.act,1) = roughness;

msg('V', sum(obj.act)       , 'no. of activated points'        , 'Prec', 0);
msg('V', sum(~isnan(n(:,1))), 'normal computation   successful', 'Prec', 0);
msg('V', sum( isnan(n(:,1))), 'normal computation unsuccessful', 'Prec', 0);

obj.correctNormals;

msg('E',{'POINTCLOUD' 'NORMALS' 'PCA'});

% End --------------------------------------------------------------------------

msg('E',{'POINTCLOUD' 'NORMALS'});

end