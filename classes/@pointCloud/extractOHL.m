function conductor = extractOHL(obj, positionPylon1, positionPylon2, noConductors, varargin)

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired( 'positionPylon1'             , @(x) isnumeric(x) && numel(x) == 2 && iscolumn(x));
p.addRequired( 'positionPylon2'             , @(x) isnumeric(x) && numel(x) == 2 && iscolumn(x));
p.addRequired( 'noConductors'               , @(x) isscalar(x) && x>0);
p.addParameter('MinDistanceFromPylons', 10  , @(x) isscalar(x) && x>0);
p.addParameter('ProfileLength'        , 2   , @(x) isscalar(x) && x>0);
p.addParameter('NoProfiles'           , 30  , @(x) isscalar(x) && x>0);
p.addParameter('MaxAngleDiffFromAxis' , Inf , @(x) isscalar(x) && x>0); % max. convergence angle alpha (in gradian) defined as angle in xy plane between conductor and OHL axis
p.addParameter('MaxDistanceFromLine'  , 0.15, @(x) isscalar(x) && x>0);
p.addParameter('BufferFromAxis'       , 25  , @(x) isscalar(x) && x>0);
p.parse(positionPylon1, positionPylon2, noConductors, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear positionPylon1 positionPylon2 noConductors

% Start ------------------------------------------------------------------------

procHierarchy = {'POINTCLOUD' 'EXTRACTOHL'};
msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Point cloud label = ''%s''', obj.label));
% origLogLevel = msg('O', 'GetLogLevel');
% msg('O', 'SetLogLevel', 'off');

% Save all originally activated points for later
actOrig = obj.act;

% Add attribute for conductor id
obj.A.conductorID = NaN(obj.noPoints,1);

% OHL axis ---------------------------------------------------------------------

axisLength = norm(p.positionPylon2 - p.positionPylon1, 2);
axisDeltaX = p.positionPylon2(1) - p.positionPylon1(1);
axisDeltaY = p.positionPylon2(2) - p.positionPylon1(2);
axisAlpha  = atan2(axisDeltaY, axisDeltaX); % in radian!

% Transform point cloud to local cs --------------------------------------------

obj.transform(1, eye(3), -[p.positionPylon1; 0]); % move origin to pylon1
obj.transform(1, opk2R(0, 0, -axisAlpha, 'Unit', 'Radian'), zeros(3,1)); % rotate

% Find conductors in profiles --------------------------------------------------

gapBetweenProfiles = (axisLength - 2*p.MinDistanceFromPylons - p.NoProfiles*p.ProfileLength) / (p.NoProfiles-1);
% ToDo: Error if gapBetweenProfiles < 0

% For each profile
for i = 1:p.NoProfiles
    
    % Default value
    profile(i).use = true; % should profile be used (true) or not (false)?
    
    % Start and end point of profile
    profile(i).xMin = p.MinDistanceFromPylons + (i-1) * (p.ProfileLength + gapBetweenProfiles);
    profile(i).xMax = profile(i).xMin + p.ProfileLength;

    % Select points in profile
    obj.act = actOrig;
    obj.select('Limits', [profile(i).xMin profile(i).xMax; -p.BufferFromAxis p.BufferFromAxis; -Inf Inf]);
    
    % Don't use profile if to less points are found
    if sum(obj.act) < 3*p.noConductors % at least for each conductor 3 points
        
        profile(i).use = false;
        
    else
    
        % Find conductors as clusters
        obj.A.conductorID(obj.act) = clusterdata(obj.X(obj.act,[2 3]), ...
                                                 p.noConductors);

        % Determine distance of points from centroid for each conductor
        for n = 1:p.noConductors

            if n == 1, actProfile = find(obj.act); end
            actConductorInProfile = find(obj.A.conductorID(actProfile) == n);

            % Centroid
            profile(i).C(n,:) = mean(obj.X(actProfile(actConductorInProfile),:),1);

            % Distances from centroid
            dy = obj.X(actProfile(actConductorInProfile),2) - profile(i).C(n,2);
            dz = obj.X(actProfile(actConductorInProfile),3) - profile(i).C(n,3);
            distances2centroid = sqrt(dy.^2 + dz.^2);

            % StdDev of distances
            profile(i).stdOfDistancesFromCentroid(n,1) = std(distances2centroid);

            % No. of points
            profile(i).noOfPoints(n,1) = numel(actConductorInProfile);
            
        end

        % Check quality of profile
        if max(profile(i).stdOfDistancesFromCentroid) > median(profile(i).stdOfDistancesFromCentroid)*2 || ...
            min(profile(i).noOfPoints) <= 3 % at least 3 points for each conductor
            profile(i).use = false;
        end

        % 4Debug
        % if i==1
        %     obj.act(:) = true;
        %     obj.plot('Color', 'w');
        %     maximize;
        % end
        % if profile(i).use
        %     obj.plot('Color', 'A.conductorID', 'ColormapName', 'classpal', 'MarkerSize', 10);
        %     plot3(profile(i).C(:,1), profile(i).C(:,2), profile(i).C(:,3), 'rx', 'MarkerSize', 20);
        %     pause(0.5);
        % end
        
    end
    
end

% Delete profiles which should not be used
idx2keep = [profile(:).use];
profile(~idx2keep) = [];

% 4Debug
% for i = 1:numel(profile)
%     if i == 1
%         obj.act(:) = true;
%         obj.plotNew('Color', 'w');
%         maximize;
%     end
%     if profile(i).use
%         plot3(profile(i).C(:,1), profile(i).C(:,2), profile(i).C(:,3), 'rx', 'MarkerSize', 20);
%     end
% end


% Find matching conductors along profiles --------------------------------------

% Note:
% - profileA: first profile
% - profileB: intermediate profile
% - profileC: last profile

% Starting points in profileA
XA = profile(1).C;

% Intermediate points in profileB
[~, idxProfileB] = min(abs([profile(:).xMin]'-axisLength/2)); % selection of profileB in the middle of profileA and profileC
XB = profile(idxProfileB).C;

% End points in profileC
XC = profile(end).C;

% Inititialize all possible conductors at profileB and profileC
possibleConductorsAtProfileB = [1:p.noConductors]';
possibleConductorsAtProfileC = [1:p.noConductors]';

% Go trough all conductors of profileA
for actualConductorAtProfileA = 1:p.noConductors

    % Initialization of conductor structure
    conductor(actualConductorAtProfileA).meandp3d = Inf;
    
    % Go trough all available conductors of profileC
    for actualConductorAtProfileC = possibleConductorsAtProfileC'
        
        % Angle between conductor line and x axis in xy plane
        alpha = atan2(XC(actualConductorAtProfileC,2)-XA(actualConductorAtProfileA,2), ...
                      XC(actualConductorAtProfileC,1)-XA(actualConductorAtProfileA,1));
                  
        % Search for points in profileB only if alpha is below defined threshold
        if abs(alpha*200/pi) < p.MaxAngleDiffFromAxis
        
            % Line parameter (line model: y = y0 + slope*x; with slope = k = dy/dx = tan(alpha))
            slope = tan(alpha);
            y0 = XA(actualConductorAtProfileA,2) - slope*XA(actualConductorAtProfileA,1);
            
            % Distance of points in profileB from line
            dp = point2linedistance2d(y0, slope, XB(possibleConductorsAtProfileB,[1 2]));
            
            possibleConductorsAtProfileB2check = possibleConductorsAtProfileB(abs(dp) < p.MaxDistanceFromLine);
            
            for actualConductorAtProfileB = possibleConductorsAtProfileB2check'

                % 4Debug
                % plot([XA(actualConductorAtProfileA,1) XC(actualConductorAtProfileC,1)], [XA(actualConductorAtProfileA,2) XC(actualConductorAtProfileC,2)], 'xr-'); axis equal; hold on;
                % plot(XB(actualConductorAtProfileB,1), XB(actualConductorAtProfileB,2), 'ob');
                
                % Original coordinates
                X = [XA(actualConductorAtProfileA,:)   % start point        (from profileA)
                     XB(actualConductorAtProfileB,:)   % intermediate point (from profileB)
                     XC(actualConductorAtProfileC,:)]; % end point          (from profileC)
                 
                % Orthogonal projection of these points on catenary line in xy plane (changes only point of profileB, thus only this point is not ON the line)
                XProj = point2lineprojection2d(y0, slope, X(:,[1 2])); % returns only x and y coordinate
                XProj = [XProj X(:,3)]; % add z coordinate again
                
                y = XProj(:,2);
                z = XProj(:,3);
                
                f = @(prm) catenary3dof(prm, y, z, y0, alpha);

                % ToDo: better initial values, especially for z0 and a
                prm0 = [0 1000 axisLength/2]; % initial values

                % Estimate catenary!
                options = optimset('Display', 'off');
                prm = lsqnonlin(f, prm0, [], [], options);

                z0 = prm(1);
                a  = prm(2);
                d0 = prm(3);

                % Check distance of all catenary centroids from estimated catenary
                C = vertcat(profile(:).C);
                
                % Orthogonal projection of centroids on catenary line in xy plane
                CProj = point2lineprojection2d(y0, slope, C(:,[1 2])); % returns only x and y coordinate
                CProj = [CProj C(:,3)]; % add z coordinate again
                
                % dz: z difference from estimated catenary
                y = CProj(:,2);
                z = z0 + a * cosh(((y-y0)./sin(alpha)-d0)/a);
                dz = z - C(:,3);

                % dp2d: 2d difference from estimated catenary
                dp2d = point2linedistance2d(y0, slope, C(:,[1 2]));

                % dp3d: 3d difference from estimated catenary
                dp3d = sqrt(dp2d.^2 + dz.^2);

                [dp3dSorted, idxSort] = sort(dp3d);

                % Mean of distances 
                meandp3d = mean(dp3dSorted(1:numel(profile)));

                % Update?
                if conductor(actualConductorAtProfileA).meandp3d > meandp3d
                    
                    conductor(actualConductorAtProfileA).meandp3d = meandp3d;
                    
                    % Catenary points (centroids from profiles)
                    conductor(actualConductorAtProfileA).localCS.C = C(idxSort(1:numel(profile)),:);
                    
                    % Catenary parameters
                    conductor(actualConductorAtProfileA).localCS.CatenaryPrm.y0    = y0;
                    conductor(actualConductorAtProfileA).localCS.CatenaryPrm.z0    = z0;
                    conductor(actualConductorAtProfileA).localCS.CatenaryPrm.d0    = d0;
                    conductor(actualConductorAtProfileA).localCS.CatenaryPrm.a     = a;
                    conductor(actualConductorAtProfileA).localCS.CatenaryPrm.alpha = alpha;
                    
                    % Save selected conductors at profileB and profileC
                    selectedConductorAtProfileB = actualConductorAtProfileB;
                    selectedConductorAtProfileC = actualConductorAtProfileC;
                    
                end

            end

        end
        
    end
    
    % Remove selected conductors from list of possible conductors
    possibleConductorsAtProfileB(possibleConductorsAtProfileB == selectedConductorAtProfileB) = [];
    possibleConductorsAtProfileC(possibleConductorsAtProfileC == selectedConductorAtProfileC) = [];
    
end

% Estimate catenaries from all points ------------------------------------------

% Save conductor points in structure
for i = 1:p.noConductors

    prm = conductor(i).localCS.CatenaryPrm;
    
    x = [-p.MinDistanceFromPylons:0.05:axisLength+p.MinDistanceFromPylons]';
    y = prm.y0 + x * tan(prm.alpha);
    z = prm.z0 + prm.a * cosh(((y-prm.y0)./sin(prm.alpha)-prm.d0)/prm.a);

    noPoints = numel(x);
    conductorID = ones(noPoints,1)*i;
    
    conductor(i).localCS.PC = pointCloud([x y z conductorID], 'Attributes', {'conductorID'});
    
end

% Transformation to global cs --------------------------------------------------

% Point cloud
obj.transform(1, opk2R(0, 0, axisAlpha, 'Unit', 'Radian'), zeros(3,1));
obj.transform(1, eye(3), [p.positionPylon1; 0]);

% Conductors
for i = 1:p.noConductors

    conductor(i).globalCS.PC = conductor(i).localCS.PC.copy;
    conductor(i).globalCS.PC.transform(1, opk2R(0, 0, axisAlpha, 'Unit', 'Radian'), zeros(3,1));
    conductor(i).globalCS.PC.transform(1, eye(3), [p.positionPylon1; 0]);
    
end

% Report -----------------------------------------------------------------------

for i = 1:p.noConductors
    % table
end

% End --------------------------------------------------------------------------

% msg('O', 'SetLogLevel', origLogLevel);

msg('E', procHierarchy);

end