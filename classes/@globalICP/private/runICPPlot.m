function runICPPlot(obj, p, g, PC)

% Was the function called before or after the first minimization/adjustment?
if ~isfield(obj.D, 'adj')
    beforeFirstMin = true;
else
    beforeFirstMin = false;
end

clf;

if beforeFirstMin
    set(gcf, 'Name', 'ICP results', ...
             'NumberTitle', 'off', ...
             'MenuBar', 'none', ...
             'DockControls', 'off');
end
    
% Plot point clouds (each in a different color) --------------------------------

% Total no. of points
for i = 1:g.nPC
    if i == 1, noPointsTotal = 0; end
    noPointsTotal = noPointsTotal + PC{i}.noPoints;
end

% Total no. of points to plot
maxPointsTotal = 1e6;

% Percent of points to plot
if noPointsTotal > maxPointsTotal;
    percent2plot = maxPointsTotal/noPointsTotal*100; % plot only a percentage of the points
else
    percent2plot = 100; % plot all points
end
    
for i = 1:g.nPC

    subplot(4,3,[1 2 4 5 7 8]);
    
    % Select subset of points
    maxPoints = floor(PC{i}.noPoints*percent2plot/100);
    idxRandom = randperm(PC{i}.noPoints, maxPoints); % indices of randomly selected points
    
    % Plot!
    plot3(PC{i}.X(idxRandom,1), ...
          PC{i}.X(idxRandom,2), ...
          PC{i}.X(idxRandom,3), ...
          '.', ...
          'MarkerSize', 1);
      
    % Set axes properties
    if i == 1, axis equal; hold on; grid on; box on; rotate3d on; end
    
    if beforeFirstMin
        title('ICP initial state');
    else
        title(sprintf('ICP iteration %d', g.nItICP));
    end
        
end

% for i = 1:g.nPC, legendNames{i} = sprintf('pc %d', i); end, legend(legendNames);
view(3);

% Maximize window
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame'); % disable warning for maximize function in next line
maximize;

% Return to main function
if beforeFirstMin, pause(0.5); return; end

% Plot point cloud 'quality' ---------------------------------------------------

subplot(4,3,[10 11]);
bar(obj.D.stats{g.nItICP}.PC_std_obs_dp_vWithoutGrossErrors, 'r');
xlim([0 g.nPC+1]);
xlabel('point cloud');
ylabel('std(dp)');
grid on;

% Plot nObs --------------------------------------------------------------------

subplot(4,3,3);
for i = 1:g.nItICP, nObs(i) = obj.D.stats{i}.nObs; end
plot(nObs, 'o-r');
xlim([0 p.MaxNoIt+1]);
set(gca, 'XTick', [0:p.MaxNoIt+1]);
ylabel('correspondences');
grid on;

% Plot std(dp) -----------------------------------------------------------------

subplot(4,3,6);
for i = 1:g.nItICP, std_vWithoutGrossErrors(i) = obj.D.stats{i}.std_vWithoutGrossErrors; end
plot(std_vWithoutGrossErrors, 'o-r');
xlim([0 p.MaxNoIt+1]);
set(gca, 'XTick', [0:p.MaxNoIt+1]);
ylabel('std(dp)');
grid on;

% Plot mean(dp) ----------------------------------------------------------------

subplot(4,3,9);
for i = 1:g.nItICP, mean_vWithoutGrossErrors(i) = obj.D.stats{i}.mean_vWithoutGrossErrors; end
plot(mean_vWithoutGrossErrors, 'o-r');
xlim([0 p.MaxNoIt+1]);
set(gca, 'XTick', [0:p.MaxNoIt+1]);
ylabel('mean(dp)');
grid on;

% Plot norm(dx) ----------------------------------------------------------------

subplot(4,3,12);
for i = 1:g.nItICP, normdx(i) = obj.D.stats{i}.normdx; end
plot(normdx, 'o-r');
xlim([0 p.MaxNoIt+1]);
set(gca, 'XTick', [0:p.MaxNoIt+1]);
xlabel('ICP iteration');
ylabel('norm(dx)');
grid on;

pause(0.5);

% screencapture(gcf, [], sprintf('It%02d.png', g.nItICP));

end