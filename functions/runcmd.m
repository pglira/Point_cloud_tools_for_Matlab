function [status, result] = runcmd(cmdStruct, varargin)
% RUNCMD Run system command directly in Matlab or append it to a batch file.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% This function offers two options:
%   1 run command directly from Matlab (see SYNTAX 1/2/3)
%   2 append command to a batch file   (see SYNTAX 4)
% ------------------------------------------------------------------------------
% INPUT
% 1 cmdStruct
%     Structure with:
%       * structure name         = command          (e.g. opalshisto)
%       * structure fieldnames   = parameter name   (e.g. inFile)
%       * structure field values = parameter values (e.g. 'C:\strip.odm')
%       For argument values without argument name, use fieldname 'noprm[1-99]'.
%
% 2 ['Batchfile', p2Batchfile]
%     Path to batch file.
%     If a batch file is specified, the command is added to the batch file, but 
%     is not executed. In this case the output is not written into a msg
%     file.
%
% 3 ['RunFld', p2RunFld]
%     Path to running folder.
%     Folder in which command line should be started. This option should be 
%     specified to avoid very long command line strings.
% ------------------------------------------------------------------------------
% OUTPUT
% 1 status
%     Returned %ERRORLEVEL% variable - see 'doc system'.
%
% 2 result
%     Returned command line output - see 'doc system'.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Run opalshisto
%     opalshisto.inFile = 'C:\strip.odm';
%     runcmd(opalshisto);
%
% 2 Run cs2cs
%     Proj4Source  = '+proj=utm +zone=33 +ellps=WGS84 +datum=WGS84 +units=m +no_defs';
%     Proj4Target  = '+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs';
%     cs2cs.noprm1 = Proj4Source;
%     cs2cs.noprm2 = '+to';
%     cs2cs.noprm3 = Proj4Target;
%     cs2cs.f      = '"%.3f"';
%     runcmd(cs2cs);
%
% 3 Run opalszcolor
%     opalsgrid.inf           = 'C:\in.tif'
%     opalsgrid.outf          = 'C:\out.tif'
%     opalsgrid.gridSize      = '1';
%     opalsgrid.interpolation = 'movingPlanes';
%     opalsgrid.neighbours    = '8';
%     opalsgrid.searchRadius  = '3';
%     opalsgrid.selMode       = 'nearest';
%     opalsgrid.filter        = '"Generic[EchoNumber == NrOfEchos]"';
%     opalsgrid.feature       = 'sigmaz';
%     if ~exist(opalsgrid.outf), runcmd(opalsgrid); end
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired( 'cmdStruct' ,     @isstruct);
p.addParameter('BatchFile' , [], @ischar);
p.addParameter('RunFld'    , [], @ischar);
p.addParameter('Pause'     , 0 , @(x) isscalar(x) && x > 0);
p.parse(cmdStruct, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear cmdStruct

% Create command string --------------------------------------------------------

% Read command name and argument names from input structure
% Command name
cmd = inputname(1);
% Parameter names
Prm = fieldnames(p.cmdStruct);

% Create command string from structure
for i = 1:numel(Prm)
    if strfind(Prm{i}, 'noprm')
        cmd = [cmd             ' ' num2str(p.cmdStruct.(Prm{i}))];
    else
        cmd = [cmd ' -' Prm{i} ' ' num2str(p.cmdStruct.(Prm{i}))];
    end
end

% If RunFld is given, delete it from command string
if ~isempty(p.RunFld)
    % Add \ at the end of folder string
    if p.RunFld(end) ~= '\', p.RunFld(end+1) = '\'; end
    cmd = strrep(cmd, p.RunFld, '');
end

% Check if command string is longer than 8192 characters
if numel(cmd) > 8192, warning('Command is longer than 8192 characters!'); end

% Run command directly in Matlab -----------------------------------------------

if isempty(p.BatchFile)

    % Folder in which command should be executed
    folderOrig = cd;
    if ~isempty(p.RunFld)
        if ~exist(p.RunFld), mkdir(p.RunFld); end
    else
        p.RunFld = cd;
    end

    % Run command and log input and ouput
    procHierarchy = {'runcmd' inputname(1)};
    msg('S', procHierarchy);
    msg('I', procHierarchy, sprintf('command = %s', cmd));
    msg('I', procHierarchy, sprintf('folder  = %s', p.RunFld));
    % Run command!
    cd(p.RunFld);
    [status, result] = system(cmd);
    cd(folderOrig);
    % [status, result] = system(cmd);
    pause(p.Pause);
    if strcmpi(inputname(1), 'visualsfm'), result = strrep(result, result(1), ''); end % for visualsfm
    if strcmpi(inputname(1), 'texrecon' ), result = strrep(result, sprintf('\r'), ''); result = regexprep(result,' +',' '); end % for texrecon
    msg('I', procHierarchy, result(1:end-1)); % just until end-1, because end is \n
    % Play sound to check if command was successfully or not
    if status == 0 || strcmp(inputname(1), 'texrecon')
        % Just one beep
        % beep;
    else
        msg('X', procHierarchy, 'Error on execution of command!');
        % Beep three times
        % beep; pause(0.5); beep; pause(0.5); beep;
    end
    msg('E', procHierarchy);

end

% Write batch file -------------------------------------------------------------

if ~isempty(p.BatchFile)

    fid = fopen(p.BatchFile, 'at');
    
    % If file is empty and RunFld is given, insert a cd command
    fileInfo = dir(p.BatchFile);
    if fileInfo.bytes == 0 && ~isempty(p.RunFld)
        fprintf(fid, '%s\n', ['cd /d ' p.RunFld]);
    end
    
    fprintf(fid, '%s\n', cmd);
    fclose(fid);
    
end

end