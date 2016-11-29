classdef globalICP < handle
    % GLOBALICP Class for global ICP problems.
    
    properties
        
        % Corresponding points
        CP
        
        % Point clouds
        PC
        
        % Path to folder for output data
        OutputFolder
        
        % Path to folder for temporary data
        TempFolder
        
        % Various data
        D

    end
    
    methods
        
        function obj = globalICP(varargin)
        % GLOBALICP Constructor method for global ICP class.
        % ----------------------------------------------------------------------
        % DESCRIPTION/NOTES
        % With the globalICP class the alignment of two or more point clouds can
        % be refined. A prerequisite for this is an approximate alignment of the
        % point clouds.
        % ----------------------------------------------------------------------
        % INPUT
        % 1 ['OutputFolder', OutputFolder]
        %   Path to directory in which output files are stored. If this option
        %   is omitted, the path given by the command 'cd' is used as directory.
        %
        % 2 ['TempFolder', TempFolder]
        %   Folder in which temporary files are saved, e.g. imported point 
        %   clouds. If this option is omitted, the path given by the command
        %   'tempdir' is used as directory.
        % ----------------------------------------------------------------------
        % OUTPUT
        % [obj]
        % Object instance of class globalICP.
        % ----------------------------------------------------------------------
        % EXAMPLES
        % 1 Minimal working example with 6 point clouds.
        %   
        %   % Create globalICP object
        %   icp = globalICP('OutputFolder', 'D:\temp');
        %
        %   % Add point clouds to object from plain text files
        %   % (Added point clouds are saved as mat files, e.g. LionScan1Approx.mat)
        %   icp.addPC('LionScan1Approx.xyz');
        %   icp.addPC('LionScan2Approx.xyz');
        %   icp.addPC('LionScan3Approx.xyz');
        %   icp.addPC('LionScan4Approx.xyz');
        %   icp.addPC('LionScan5Approx.xyz');
        %   icp.addPC('LionScan6Approx.xyz');
        % 
        %   % Plot all point clouds BEFORE ICP (each in a different random color)
        %   figure; icp.plot('Color', 'random');
        %   title('BEFORE ICP'); view(0,0);
        % 
        %   % Run ICP!
        %   icp.runICP('PlaneSearchRadius', 2);
        % 
        %   % Plot all point clouds AFTER ICP
        %   figure; icp.plot('Color', 'random');
        %   title('AFTER ICP'); view(0,0);
        %
        % 2 Continued: Demo of the methods 'loadPC' and 'exportPC'.
        %
        %   % Load fifth point cloud to workspace and plot
        %   pc = icp.loadPC(5);
        %   figure; pc.plot;
        %
        %   % Export final point clouds
        %   icp.exportPC(1, 'LionScan1.xyz');
        %   icp.exportPC(2, 'LionScan2.xyz');
        %   icp.exportPC(3, 'LionScan3.xyz');
        %   icp.exportPC(4, 'LionScan4.xyz');
        %   icp.exportPC(5, 'LionScan5.xyz');
        %   icp.exportPC(6, 'LionScan6.xyz');
        % ----------------------------------------------------------------------
        % philipp.glira@gmail.com
        % ----------------------------------------------------------------------
        
        % Input parsing --------------------------------------------------------

        p = inputParser;
        p.addParameter('OutputFolder', cd     , @ischar);
        p.addParameter('TempFolder'  , tempdir, @ischar);
        p.parse(varargin{:});
        p = p.Results;
        
        % Directories ----------------------------------------------------------
        
        if ~exist(p.OutputFolder, 'dir'), mkdir(p.OutputFolder), end
        obj.OutputFolder = p.OutputFolder;
        
        if ~exist(p.TempFolder, 'dir'), mkdir(p.TempFolder), end
        obj.TempFolder = p.TempFolder;
        
        end
        
    end
    
end

