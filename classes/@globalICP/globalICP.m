classdef globalICP
    % GLOBALICP Class for global ICP problems.
    
    properties
        
        % Corresponding points
        CP
        
        % Point clouds
        PC
        
        % Path to folder for output data
        OutputFolder
        
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
        % ['OutputFolder', OutputFolder]
        % Path to directory in which output files are stored. If this option
        % is omitted, the path given by the command 'cd' is used as directory.
        % ----------------------------------------------------------------------
        % OUTPUT
        % [obj]
        % Object instance of class globalICP.
        % ----------------------------------------------------------------------
        % EXAMPLES
        % 1 Minimal working example with 6 point clouds.
        %   
        %   % Create globalICP object
        %   icp = globalICP('OutputFolder', 'Y:\temp');
        %
        %   % Add point clouds to object from plain text files
        %   % (Added point clouds are saved as mat files, e.g. LionScan1Approx.mat)
        %   icp = icp.addPC('LionScan1Approx.xyz');
        %   icp = icp.addPC('LionScan2Approx.xyz');
        %   icp = icp.addPC('LionScan3Approx.xyz');
        %   icp = icp.addPC('LionScan4Approx.xyz');
        %   icp = icp.addPC('LionScan5Approx.xyz');
        %   icp = icp.addPC('LionScan6Approx.xyz');
        % 
        %   % Plot all point clouds BEFORE ICP (each in a different random color)
        %   figure; icp.plot('Color', 'random');
        %   title('BEFORE ICP'); view(0,0);
        % 
        %   % Run ICP!
        %   icp = icp.runICP('PlaneSearchRadius', 2);
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
        % philipp.glira@geo.tuwien.ac.at
        % ----------------------------------------------------------------------
        
        % Input parsing --------------------------------------------------------

        p = inputParser;
        p.addParamValue('OutputFolder', cd, @ischar);
        p.parse(varargin{:});
        p = p.Results;
        
        % Temporary directory --------------------------------------------------
        
        if ~exist(p.OutputFolder), mkdir(p.OutputFolder), end
        obj.OutputFolder = p.OutputFolder;
        
        end
        
    end
    
end

