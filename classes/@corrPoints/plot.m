function plot(obj, varargin)

% Default values ---------------------------------------------------------------

if isempty(varargin)
    varargin = {'Color' 'A.dp', ...
                'CAxisLim' [-0.24 0.24], ...
                'ColormapName' 'difpal'};
end

% Create point cloud object ----------------------------------------------------

pc = pointCloud(obj.X1, 'Label', obj.label);

pc.A.dp     = obj.dp;
pc.A.ds     = obj.ds;
pc.A.dAlpha = obj.dAlpha;
pc.A.w      = obj.A.w;

% Plot -------------------------------------------------------------------------

pc.plot(varargin{:});

end