function varargout = msg(Flag, varargin)
% MSG Report process informations to the workspace.
% ------------------------------------------------------------------------------
% DESCRIPTION/NOTES
% With this function informations about processes and variables can be printed
% to the workspace.
% ------------------------------------------------------------------------------
% INPUT
% 1 [Flag]
%   Flag describing the scope of the report. Any Flag can be used, however, 
%   the following flags have a special purpose:
%   S ... to define the start of a process
%   E ... to define the end of a process
%   V ... to report the value of a variable
%   T ... to report a text string
%   D ... to report a table (of data)
%   O ... to set persistant options for this function (e.g. log level)
%   Conventions for arbitrary flags:
%   I ... for output of informations
%   X ... for error output
%   W ... for warnings
%
% 2 [ProcHierarchy] (not required for flags V, T, D and O)
%   Cell describing the hierarchy of the process.
%
% 3 [Info] (required for all flags, except S, E, D and O)
%   String containing report information.
%
% 4 ['Prec', Prec] (optional for flag V)
%   Precision of variable output.
%
% 5 ['MaxPrec', MaxPrec] (optional for flag V)
%   Maximal precision output for variables (see examples section).
%
% 6 ['FieldWidth', FieldWidth] (optional for flag V)
%   Field width for variable output (see examples section).
%
% 7 ['LogLevel', LogLevel] (optional for all flags, except O)
%   Define the log level of the message. Possible values:
%   * 'basic' -> for output of basic information.
%   * 'debug' -> for output of detailed information.
%
% 8 ['SetLogLevel', SetLogLevel] (optional for flag O)
%   Define which messages are reported to the workspace. Possible values:
%   * 'basic'  -> output of messages with log level 'basic'.
%   * 'debug'  -> output of messages with log level 'basic' and 'debug'.
%   * 'off'    -> no message output.
%
% 9 'GetLogLevel' (optional for flag O)
%   Get actual log level.
%
% 10 ['SetLogfile', SetLogfile] (optional for flag O)
%    Define a logfile instead of displaying the output information on the
%    workspace.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 Report the start of a process and begin time measurement for this process.
%   msg('S', {'POINTCLOUD' 'ESTIMATE NORMALS'});
%
% 2 Report an info update for the same process.
%   msg('I', {'POINTCLOUD' 'ESTIMATE NORMALS'}, 'Normal estimation by PCA');
%
% 3 Report the end of the process.
%   msg('E', {'POINTCLOUD' 'ESTIMATE NORMALS'});
%
% 4 Print a variable.
%   msg('V', 6378137, 'Semi-major axis (GRS80)');
%
% 5 Print variable with specified precision.
%   msg('V', pi, 'pi', 'Prec', 7);
%
% 6 Print variable with definition of MaxPrec and FieldWidth.
%   msg('V', pi, 'pi', 'Prec', 7, 'MaxPrec', 10, 'FieldWidth', 20);
%
%   V :         3.1415927    = pi
%       12345678901234567890
%      >     FieldWidth     <
%                > MaxPrec  <
%                > Prec  <
%
% 8 Print a text string.
%   msg('T', 'A text information');
%
% 9 Print a data table.
%
%   tabularData.Caption = 'CAPTION OF DATA TABLE';
%   tabularData.ColumnCaptions     = {'value' 'usage'  'file'    % first row
%                                     ''      'yes/no' ''     }; % second row
%   tabularData.ColumnWidths       = [8        10       0     ];
%   tabularData.ColumnPrecs        = [2        NaN      NaN   ]; % NaN for char columns
%   tabularData.ColumnRightMargins = [1        3        0     ]; % optional
% 
%   tabularData.Data = {7.654  'yes' 'file1.txt'
%                       6.3245 'no'  'file2_with_long_name.txt'
%                       8.12   'yes' 'file3.txt'};
%                 
%   tabularData.Notes = {'Note: files are located in folder ''D:\data\'''}; % optional
% 
%   msg('D', tabularData);
%
% 10 Set log level to 'basic', so that only messages with log level equal to
%    'basic' are reported.
%    msg('O', 'SetLogLevel', 'basic');
%
% 11 Get actual log level.
%    origLogLevel = msg('O', 'GetLogLevel');
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Preparations -----------------------------------------------------------------

persistent logLevel % log level of output
if isempty(logLevel), logLevel = 'debug'; end % initialize

persistent logFile
if isempty(logFile), logFile = ''; end % initialize

% Set options
if strcmpi(Flag, 'O')
    
    % Set log level
    idx = find(strcmpi('SetLogLevel', varargin));
    if ~isempty(idx)
        logLevel = varargin{idx+1};
    end
    
    % Get log level
    idx = find(strcmpi('GetLogLevel', varargin));
    if ~isempty(idx)
        varargout{1} = logLevel;
    end
    
    % Set log file
    idx = find(strcmpi('SetLogFile', varargin));
    if ~isempty(idx)
        logFile = varargin{idx+1};
    end
    
    return;

% Retrieve log level of message
else
    
    % Check if log level of message is defined (without parsing all input arguments)
    idx = find(strcmpi('LogLevel', varargin));
    if ~isempty(idx) % if log level of message is defined
        logLevelMsg = varargin{idx+1};
        varargin(idx:idx+1) = []; % delete log level arguments (no parsing)
    else % if log level of message is NOT defined
        logLevelMsg = 'debug'; % default value
    end
    
end

% Check log level and eventually stop function ---------------------------------
% In order to save time, this section has to be placed at the beginning of the
% function

% If logLevel is set to off leave the function
if strcmpi(logLevel, 'off')
    return;
    
% If logLevel is set to basic ...
elseif strcmpi(logLevel, 'basic')

    % ... and log level of message is set to debug, leave the function
    if strcmpi(logLevelMsg, 'debug'), return; end

end

% ... continue with normal parsing of input arguments

% Input parsing ----------------------------------------------------------------

% Global parameters
p = inputParser;

if strcmpi(Flag, 'V')
    p.addRequired( 'Var'              , @(x) isnumeric(x) || islogical(x));
    p.addRequired( 'Info'             , @ischar);
    p.addParameter('Prec'         , 3 , @isnumeric);
    p.addParameter('MaxPrec'      , 9 , @isnumeric);
    p.addParameter('FieldWidth'   , 20, @isnumeric);

elseif any(strcmpi(Flag, {'S' 'E'}))
    p.addRequired(  'ProcHierarchy'    , @iscell);
    
elseif strcmpi(Flag, 'T')
    p.addRequired(  'Info'             , @ischar);
    
elseif strcmpi(Flag, 'D')
    p.addRequired(  'TabularData'      , @isstruct);
    
else
    p.addRequired(  'ProcHierarchy'    , @iscell);
    p.addRequired(  'Info'             , @ischar);
end

p.parse(varargin{:});
p = p.Results;

% Variable declaration ---------------------------------------------------------

persistent tictoc   % for time measurement

% Output string
out = [];

% Add time info to output ------------------------------------------------------

if any(strcmpi(Flag, {'V' 'T' 'D'}))
    % No time information, just empty string with same length
    tInfo = char( ones(1,numel(timeinfo)) *32 );
    
elseif strcmpi(Flag, 'S')
    tInfo = timeinfo;
    % Start timer for specific process
    tictoc.(genvarname([p.ProcHierarchy{:}])).tic = tic;
    
else
    % Elapsed time for specific process
    t = toc(tictoc.(genvarname([p.ProcHierarchy{:}])).tic);
    % No time information, just empty string with same length
    tInfo = char( ones(1,numel(timeinfo)) *32 );
    % Write elapsed time right-aligned into string
    tString = sprintf('+%.3fs', t);
    tInfo(end-numel(tString)+1:end) = tString;
end

out = [out tInfo];

% Add separator between two columns to output ----------------------------------

out = [out ' | '];

% Add flag to output -----------------------------------------------------------

out = [out Flag ' : '];

% Add process hierarchy string to output ---------------------------------------

if all(~strcmpi(Flag, {'V' 'T' 'D'}))
    for i = 1:numel(p.ProcHierarchy)
        switch i
            case 1
                procStr = upper(p.ProcHierarchy{i});
            otherwise
                procStr = [procStr ' > ' upper(p.ProcHierarchy{i})];
        end
    end 
    out = [out procStr];
end

% Add info string to output ----------------------------------------------------

if ~any(strcmpi(Flag, {'S' 'E' 'V' 'T' 'D'}))
    out = [out ' : '];
    
    % If p.Info contains \n, replace them by left part of output
    logIdxSep = out == '|';
    leftPart = char( ones(1,numel(out)) *32 );
    leftPart(logIdxSep) = '|';
    p.Info = strrep(p.Info, sprintf('\n'), sprintf('\n%s', leftPart));
    
    out = [out p.Info];
end

% Add variable info to output --------------------------------------------------

if strcmpi(Flag, 'V')
    if p.Prec == 0, p.MaxPrec = p.MaxPrec+1; end
    out = [out sprintf('%*.*f%*s = %s', p.FieldWidth-p.MaxPrec+p.Prec, p.Prec, p.Var, p.MaxPrec-p.Prec, '', p.Info)];
end

% Add text info to output ------------------------------------------------------

if strcmpi(Flag, 'T')
    out = [out p.Info];
end

% Add tabular data to output ---------------------------------------------------

if strcmpi(Flag, 'D')
    
    % First: delete all columns containing only NaNs
    idx2del = [];
    for i = 1:size(p.TabularData.Data,2)
        if all(isnan([p.TabularData.Data{:,i}]))
            idx2del = [idx2del; i];
        end
    end
    p.TabularData.Data(:,idx2del) = [];
    p.TabularData.ColumnCaptions(:,idx2del) = [];
    p.TabularData.ColumnWidths(idx2del) = [];
    p.TabularData.ColumnPrecs(idx2del) = [];
    
    % Add column margins if not defined
    if ~isfield(p.TabularData, 'ColumnRightMargins')
        p.TabularData.ColumnRightMargins = [ones(1, size(p.TabularData.Data,2)-1) 0];
    end
    
    % Save prefix
    prefix = out;
    clear out
    
    % Separation line
    lengthSeparationLine = sum(p.TabularData.ColumnWidths) + sum(p.TabularData.ColumnRightMargins);
    if lengthSeparationLine < 80, lengthSeparationLine = 80; end
    out{1,1} = [prefix repmat('-', 1, lengthSeparationLine)];
    
    % Report table caption
    out{2,1} = [prefix p.TabularData.Caption];
    
    % Report column captions
    formatSpec = [];
    for col = 1:size(p.TabularData.ColumnCaptions,2)
        formatSpec = [formatSpec '%' num2str(p.TabularData.ColumnWidths(col)) 's' repmat(' ', 1,p.TabularData.ColumnRightMargins(col))];
    end
    formatSpec = strtrim(formatSpec); % remove trailing spaces
    for row = 1:size(p.TabularData.ColumnCaptions,1)
        out{end+1,1} = [prefix sprintf(formatSpec, p.TabularData.ColumnCaptions{row, :})];
    end
    
    % Report data
    formatSpec = [];
    for col = 1:size(p.TabularData.Data,2)
        if isnan(p.TabularData.ColumnPrecs(col))
            columnFormatSpec = ['%' num2str(p.TabularData.ColumnWidths(col)) 's'];
        else
            columnFormatSpec = ['%' num2str(p.TabularData.ColumnWidths(col)) '.' num2str(p.TabularData.ColumnPrecs(col)) 'f'];
        end
        formatSpec = [formatSpec columnFormatSpec repmat(' ', 1,p.TabularData.ColumnRightMargins(col))];
    end
    formatSpec = strtrim(formatSpec); % remove trailing spaces
    for row = 1:size(p.TabularData.Data,1)
        out{end+1,1} = [prefix sprintf(formatSpec, p.TabularData.Data{row, :})];
    end
    
    % Notes?
    if isfield(p.TabularData, 'Notes')
        for i = 1:numel(p.TabularData.Notes)
           out{end+1,1} = [prefix p.TabularData.Notes{i}];
        end
    end
    
    % Separation line
    out{end+1,1} = [prefix repmat('-', 1, lengthSeparationLine)];
    
end

% Write output to command window -----------------------------------------------

% Output to log file
if ~isempty(logFile)
    fid = fopen(logFile, 'at');
    if ~iscell(out)
        fprintf(fid, '%s\n', out);
    else % only in case of Flag = 'D'
        for i = 1:numel(out)
            fprintf(fid, '%s\n', out{i});
        end
    end
    fclose(fid);
% Output to work space
else
    if any(strcmpi(Flag, {'X'})) % standard error output
        fprintf(2, '%s\n', out); 
    else % standard output
        if ~iscell(out)
            fprintf(1, '%s\n', out);
        else % only in case of Flag = 'D'
            for i = 1:numel(out)
                fprintf(1, '%s\n', out{i});
            end
        end
    end
end

% wk 2015-04-25 Wolfgang Rieger criticized that when redirecting the output of opalsICP to a file, the output stream seems to be buffered, and hence he cannot closely follow the progress of opalsICP when watching the file in a text editor.
% In fact, this seems to be the case for stdout and stderr, see: http://undocumentedmatlab.com/blog/improving-fwrite-performance 
% Let's check if stdout and stderr can be flushed explicitly by the following command, see: http://stackoverflow.com/questions/2633019/how-can-i-flush-the-output-of-disp-in-matlab-or-octave 
% wk 2015-04-26 this seems to be unnecessary, because the output of ICP4opals is directed to the opals logging system via the handler installed by opalsICP. Thus, flush the screen log stream (std::cout) in opalsICP instead.
% drawnow('update')

end % function end

% ------------------------------------------------------------------------------

function tInfo = timeinfo
tInfo = [datestr(now,'yyyy-mm-dd HH:MM:SS.FFF') 's'];
end