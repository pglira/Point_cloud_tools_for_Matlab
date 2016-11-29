function list = dirext(path, varargin)
% DIREXT Extended version of standard dir command.
% ------------------------------------------------------------------------------
% SYNTAX
% 1 list = dirext(path)
%     Lists all files and folders contained in path.
%
% 2 list = dirext(path, Filter)
%     With Filter a filtering of the files and folders can be performed.
% ------------------------------------------------------------------------------
% INPUT
% 1 path
%     Search path.
%
% 2 [Filter]
%     String or cell array of strings containing filter informations. All
%     options offered by the original dir command are possible. Among them
%     possible choices are:
%       * 'isdir'    Output list contains just folders.
% ------------------------------------------------------------------------------
% OUTPUT
% 1 list
%     List of files and/or folders, found in path. Result is cell array.
% ------------------------------------------------------------------------------
% EXAMPLES
% 1 List all files and folders in current folder.
%     dirext('*')
%
% 2 List all files and folders in Y:\Temp\.
%     dirext('Y:\Temp')
% 
% 3 List just folders in Y:\Temp\.
%     dirext('Y:\Temp', 'isdir')
% ------------------------------------------------------------------------------
% philipp.glira@gmail.com
% ------------------------------------------------------------------------------

% Input parsing ----------------------------------------------------------------

p = inputParser;
p.addRequired('path',     @ischar);
p.addOptional('Filter', [], @(x) ischar(x) || iscell(x));
p.parse(path, varargin{:});
p = p.Results;
% Clear required inputs to avoid confusion
clear path

% Create raw list of files/folders ---------------------------------------------

listStruct = dir(p.path);

% Error if no files or folders are found
if isempty(listStruct), error('No files or folders found.'); end

% Delete two first entries ('.' and '..') if present
idxLogPoint  = strcmp({listStruct.name}, '.');  % where is point?
idxLogDPoint = strcmp({listStruct.name}, '..'); % where is double point?
idxLog = idxLogPoint | idxLogDPoint;
% Delete if found
if any(idxLog), listStruct(idxLog) = []; end

% Filtering of results? --------------------------------------------------------

if ~isempty(p.Filter)
    
    % Just folders
    if strcmpi(p.Filter, 'isdir')
        LogIdx = ([listStruct.isdir] == 1);
        listStruct = listStruct(LogIdx);
    end
    
end

list = {listStruct.name};




