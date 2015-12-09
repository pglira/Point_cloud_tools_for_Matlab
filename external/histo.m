function statistics = histo(varargin)
% Shows histogram of a matrix as bar plot and returns statistics of matrix 
% including median, mean, standeviation, sigma_MAD etc. Cumulative histogram can also be plotted.
% ------------------------------------------------------------------------
% FUNCTION: statStruct = histo(varargin)
%           = histo(mat, nodata, mask, range, title, nclass, ...
%             'handle', hid,  'type', typ)
% 
% Note: most input arguments are identified by their type!
% 
% INPUT:
% mat  (= first input argument)  matrix or vector with values to be
%          histogrammed; in case of matrix mat(:) is applied internally
% 
% nodata is either NaN or a struct containing the element NODATA_VALUE
% 
% mask is a logical matrix of same size as mat, which has '1' where values
%         in mat should be used for histogram
% 
% range = [min max] defines the left BORDER of the first and the right
%         border of the last class; Values outside range are considered 
%         in under- and overflow class;
%         (use mat>min & mat<max in mask parameter to not consider values 
%          outside [min max]; )
%         range also defines the extent of the horizontal axis in the plot.         
%         * default: min and max from input mat
%         * use only a scalar [X] for taking boundary: 
%           [median - X*sigMAD   median + X*sigMAD]
%         * use [0 0] to suppress output;
%         * range setting is overruled by clip parameter below
% 
% nclass: use a NEGATIVE scalar to specify the number of classes (default: 100)
% 
% title = string used as title of the figure
% 
% 'handle', hid :  use this to plot the histogramm in an already existing
%          figure with handle hid; if no figure with handle hid exists a
%          new figure is created
% 
% 'type', typ : use this to select the typ of histogram plot:
%           'D': density (= default)
%           'C': cumulative
%           'K': cumulative (of absolute values)
%           'DC','CD','DK', or 'KD': density and cumulative, side by side
%         add a 'P' at the end to get also a plot of the Normal Distribution
%           based on derived median and sigMad (plotting nclass points).
%         add expectation value and standard deviation after P to use these
%         values; use MOD for modus, MEA for mean and MED for median; use
%         STD for standard deviation and MAD for sigMad; e.g.
%         'DP MOD MAD' or 'DP MEA STD' or 'DP 0.345 STD' or 'DP 0 1'
% 
% 'clip', [low high] : use this to set range boundary to the lowest and 
%           highest [%] of the data: e.g.  'clip', [5 95]
%           (values outside appear in under- and overflow class)
%
%
% OUTPUT:
% If no handle is given, a new figure popps up with the bar plot of the histogram. 
% The x-label contains the folowing statistics, which is computed for all
% valid elements (i.e. inside mask and different from NODATA_VALUE). The plot
% restriction using range has NO effect on these statistics.
% n_used  = number of elements considered for statistics and plotting
% n_data  = number of data elements (i.e. all minus no-data); 
%           graph lists '=' if n_used  == n_data  
% RMS     = RMS of n_used
% median  = median of n_used
% sigMAD  = MAD * 1.4826 (=median of absolute deviation to median * 1.4826)
%           (this is a robust estimater for the standard deviation - in 
%            case of normal distribution)
% mean    = mean of n_used
% sig     = standard deviation of n_used
% min, max = of n_used
% 
% All above and more are returned in the struct statStruct:
% .median
% .sigMad
% .mean
% .sig
% .RMS
% .min
% .max
% .n_used
% .n_data
% .modus  (based on histo bins)
% .quant.il_01     1% quantil
% .quant.il_025  2.5% quantil
% .quant.il_05     5% quantil
% .quant.il_10    10% quantil
% .quant.il_25    25% quantil
% .quant.il_75    75% quantil
% .quant.il_90    90% quantil
% .quant.il_95    95% quantil
% .quant.il_975 97.5% quantil
% .quant.il_99    99% quantil
% .handle handle to histo figure 
%
% ------------------------------------------------------------------------
% EXAMPLES:
% z=randn(90);         % generate 90*90 N(0,1) values
% histo(z);     % histo over all values with 100 bins (= classes) between min and max
% histo(z,-50); % same as above, but with 50 bins (= classes) between min and max
% histo(z,2);   % now 100 classes between median - sig_mad*2 and median + sig_mad*2
% histo(z,2,-50);   % now 50 classes between median - sig_mad*2 and median + sig_mad*2
% histo(z,[0 2]); % 100 classes between 0 and 2; rest = over/underflow
% histo(z,[0 2], z<2 & z>0); % only positive values smaller 2 are used, 100 classes between 0 and 2
% histo(z, z<2 & z>0); % same as above
% histo(z,'clip', [5 95]); % show only central 90% of data; rest = over/underflow
% histo(z, 'handle', 10);  % histo over all values with 100 bins
%                          between min and max in already existing figure with handle 10
% histo(z,[0 2],'my Title',-20,'type','CD'); % 20 classes between 0 and 2;
%                           rest = over/underflow; with cummulative histo
% histo(z,[0 2],'type','DP'); % plot the Normal Distribution also
% ------------------------------------------------------------------------
% RESPONSIBILITY: CaR
% MATLAB VERSION: 7.0.0.19920 (R14)
% CREATION DATE:  2006
% ------------------------------------------------------------------------
% Copyright: 2006
%            Institute of Photogrammetry and Remote Sensing / TU Vienna
% ------------------------------------------------------------------------

mat = varargin{1};
valid = true(size(mat));
range=[];
nodata_value = [];
title_text = [];
handl = [];
clip = [];
type = 'D';
nc = 100; %number of classes

mask = [];
i = 2;
while i <= nargin
    % Range or number of classes
    if isnumeric(varargin{i}) && length(varargin{i})<=3 
        inp = varargin{i};
        if inp(1)>=0  || length(inp) == 2
           range=inp;
        else
            nc = abs(inp);% number of classes
        end
    end
    % Mask
    if islogical(varargin{i})
%        valid = valid & varargin{i};
       mask = varargin{i};
    end
    % Title text
    if ischar(varargin{i})
        if strcmpi(varargin{i},'handle')
            i=i+1;
            handl = varargin{i};
        elseif strcmpi(varargin{i}, 'type')
            i = i + 1;
            type = upper(varargin{i});
        elseif strcmpi(varargin{i}, 'clip')
            i = i + 1;
            clip = varargin{i};
        else
            title_text = varargin{i};
        end
    end
    % nodata-value
    if isstruct(varargin{i})
        nodata_value = varargin{i}.NODATA_VALUE;
    end

    i = i + 1;
end

% ------------
% valid numbers in mat
if (isempty(nodata_value)) || (isnan(nodata_value))
    valid = valid & ~isnan(mat);
else
    valid = valid & mat~=nodata_value;
end

n_valid = sum(valid(:));
n_used = n_valid;
if ~isempty(mask)
    valid = valid & mask;
    n_used = sum(valid(:));
end
vec = mat(valid);


if isempty(vec)
    warning('Histogramm requested but no (valid) elements given.')
    statistics = [];
    return
end

if ~isfloat(vec), vec = double(vec); end

% ------------
% statistics
vec = sort(vec);
if rem(n_used,2)==1
    med = vec(0.5 * n_used + 0.5);
else
    med = (vec(0.5 * n_used) + vec(0.5 * n_used + 1))/2;
end

med = median(vec);
absdif = abs(vec - med);

sig_mad = 1.4826*median(absdif);

mean_ = mean(vec);
sig = std(vec);

rms = sqrt(sum(vec.^2)/numel(vec));

max_ = max(vec);
min_ = min(vec);


statistics.median = med;
statistics.sigMad = sig_mad;
statistics.mean = mean_;
statistics.sig = sig;
statistics.RMS = rms;
statistics.min = min_;
statistics.max = max_;
statistics.n_used = n_used;
statistics.n_data = n_valid;
statistics.quant.il_01  = vec(max([1,round(0.01  * n_used)])); % max(...) if round(0.01 * n_used)=0
statistics.quant.il_025 = vec(max([1,round(0.025 * n_used)]));
statistics.quant.il_05  = vec(max([1,round(0.05  * n_used)]));
statistics.quant.il_10  = vec(max([1,round(0.10  * n_used)]));
statistics.quant.il_25  = vec(max([1,round(0.25  * n_used)]));
statistics.quant.il_75  = vec(max([1,round(0.75  * n_used)]));
statistics.quant.il_90  = vec(max([1,round(0.90  * n_used)]));
statistics.quant.il_95  = vec(max([1,round(0.95  * n_used)]));
statistics.quant.il_975 = vec(max([1,round(0.975 * n_used)]));
statistics.quant.il_99  = vec(max([1,round(0.99  * n_used)]));

% ------------
% range of displayed histogramm
overUnderFlow = true;
if isempty(range)
    range = [min(vec)  max(vec)];
    overUnderFlow = false;
elseif length(range) == 1
    range = [max([min(vec) med-range*sig_mad])   med+range*sig_mad]; % special treatment for only positive values close to zero
elseif length(range) == 2
    %range = range;
elseif length(range) == 3    
    vec = sort(vec);
    if abs(range(3)) > 100, 
        range = [vec(1)  vec(end)]; 
    else
        if range(3) < 0
            range = [vec(1)   vec(ceil(numel(vec)/100*abs(range(3))))];
        elseif range(3) > 0
            range = [vec(floor(numel(vec)/100*(100-range(3))))  vec(end)];
        else
            range = [vec(1)  vec(end)];
        end
    end
else
    range = [min(vec)  max(vec)];
    overUnderFlow = false;
end

if ~isempty(clip)
    if numel(clip) == 2
        n = numel(vec)/100;
        vec = sort(vec);
        range = [vec(floor(n*(clip(1)))) vec(ceil(n*clip(2)))];
        overUnderFlow = true;
    else
        range = [min(vec)  max(vec)];
        overUnderFlow = false;
    end
end


% -------------
% put values into classes
% Definition of classes: 
% 1. class:   [range(1),           range(1) + cw)  (right opend!) with cw = class width
% last class: [range(2) - cw,           range(2)]  (both sides closed)
% values < range(1) and > range(2) (if present) are considered in under and over flow class!

cw = (range(2)-range(1))/(nc);
if overUnderFlow
    class_midpoints = linspace(range(1)-cw/2, range(2)+cw/2, nc+2);
else
    class_midpoints = linspace(range(1)+cw/2, range(2)-cw/2, nc);
end
n = hist(vec, class_midpoints);
[~, maxI] = max(n);
statistics.modus = class_midpoints(maxI);


% no output of histogram?
if (range(2) == range(1)) && (range(2) == 0) % && (vec(1) ~= vec(end)) % to asure showing histo in case all values are the same 
    return
end

% matlab error would result if all values are identical
if abs(range(2)-range(1)) < eps
    range(1) = range(1) - 1;
    range(2) = range(1) + 1;
end


% ------------
% which figure?
if isempty(handl)
    handl = figure;
else
    try
    handl = figure(handl);
    catch
    handl = subplot(handl);
    end
end
statistics.handle = handl;

h_histo_D = gca; h_histo_C = gca;
plotCurve = false;
plotCurvePDF = [];
posP = strfind(type,'P');
if ~isempty(posP)
    plotCurve = true;
    
    [ExpPlot, StdPlot] = strtok(type(posP+1:end));
    StdPlot = strrep(StdPlot,' ','');
    if strcmpi(ExpPlot,'MED'), 
        ExpPlot = statistics.median; 
    elseif strcmpi(ExpPlot,'MOD'), 
        ExpPlot = statistics.modus; 
    elseif strcmpi(ExpPlot,'MEA'), 
        ExpPlot = statistics.mean; 
    else
        ExpPlot = str2num(ExpPlot); 
    end
        
    if strcmpi(StdPlot,'MAD'), 
        StdPlot = statistics.sigMad; 
    elseif strcmpi(StdPlot,'STD'), 
        StdPlot = statistics.sig; 
    else
        StdPlot = str2num(StdPlot); 
    end
    
    if isempty(ExpPlot), ExpPlot = statistics.median; end
    if isempty(StdPlot), StdPlot = statistics.sigMad; end
    
	type = type(1:posP-1);
    plotCurvePDF = normpdf(class_midpoints,ExpPlot, StdPlot);
end
if length(type)>1
    h_histo_D = subplot(1,2,1);
    h_histo_C = subplot(1,2,2);
end


% ------
% plot DENSITY histogram
n_valid_string = num2str(n_valid);
if n_used == n_valid, n_valid_string='=';end % only for plotting --> immedeatly clear that all data is used
if strfind(type,'D')
    n = n/numel(vec)*100;
    h_bar = bar(h_histo_D, class_midpoints,n);
    set(h_bar, 'EdgeColor', 'none');

    if sig > 0.0009
    xlabel(h_histo_D,  {['n_{used}/n_{data}: ' num2str(n_used) '/' n_valid_string '   RMS: ' num2str(rms,'%11.4f')    '    median: ' num2str(med,'%11.4f') '  sig_{MAD}: ' num2str(sig_mad,'%11.4f')]; ...
        ['    min: ' num2str(min_,'%11.4f') '  max: ' num2str(max_,'%11.4f')   '     mean: '   num2str(mean_,'%11.4f')   '  sig: '   num2str(sig,'%11.4f')]})
    else
    xlabel(h_histo_D,  {['n_{used}/n_{data}: ' num2str(n_used) '/' n_valid_string '   RMS: ' num2str(rms,'%11.4e')    '    median: ' num2str(med,'%11.4e') '  sig_{MAD}: ' num2str(sig_mad,'%11.4e')]; ...
        ['    min: ' num2str(min_,'%11.4e') '  max: ' num2str(max_,'%11.4e')   '     mean: '   num2str(mean_,'%11.4e')   '  sig: '   num2str(sig,'%11.4e')]})
    end
    ylabel(h_histo_D,  '%');
    title(h_histo_D,  title_text);
    
    if overUnderFlow % draw under and overflow bars differently
        xlim(h_histo_D,  [range(1)-cw range(2)+cw]) 
        hold(h_histo_D, 'on'); 
        ylimIst = ylim;
        subplot(h_histo_D);
        %ouflCol = [128 0 255]/512;
        ouflCol = [128 128 128]/255;
        if n(1)>0, rectangle('Position',[range(1)-cw,ylimIst(1),cw,n(1)], 'FaceColor',ouflCol); end
        if n(end)>0, rectangle('Position',[range(2),ylimIst(1),cw,n(end)], 'FaceColor',ouflCol); end
    else
        xlim(h_histo_D,  [range(1)-cw/2 range(2)+cw/2]) 
    end

    % overlay plot of Gauss-Distribution using median and sigMad
    if plotCurve
        % determine scaling factor of pdf plot wrt to histo-bars only
        % within interesting range of +-4*sigMad as weighted mean between
        % pdf values and bar heights
        %         fac = n./plotCurvePDF;
        %         k = ( class_midpoints < statistics.median + 4*statistics.sigMad ) & ( class_midpoints > statistics.median - 4*statistics.sigMad );
        %         mfac = fac(k)*n(k)'/sum(n(k));

        mfac = 100 * cw; % always true, since each bar has the area cw * bin_height
        hold(h_histo_D, 'on'); 
        plot(class_midpoints,plotCurvePDF*mfac,'r');
    end
end


% ------
% plot CUMMULATIVE histogram
if ~isempty(strfind(type,'C')) || ~isempty(strfind(type,'K'))
 n = hist(vec, class_midpoints);

	if strfind(type,'C')
        n_cum = zeros(size(n));
        for i=1:length(n),
            n_cum(i) = sum(n(1:i));
        end
        mid_cum = class_midpoints;
        
    elseif strfind(type,'K') % absolute values
        Z = [abs(class_midpoints)'   n'];
        Z = sortrows(Z,1);
        n_cum = zeros(size(n));
        mid_cum = zeros(size(n));
        bin_n = 1;
        i = 1;
        mid_cum(bin_n) = 0;
        n_cum(bin_n) = 0;
        while i<=length(n),
            bin_n = bin_n + 1;
            mid_cum(bin_n) = Z(i,1);
            n_cum(bin_n) = sum(Z(1:i,2));
            if i < length(n) && Z(i+1,1)-Z(i,1)<0.001*max(Z(i+1,1), Z(i,1)),
                i = i + 1;
                n_cum(bin_n) = n_cum(bin_n) + Z(i,2);
            end
            i = i + 1;
        end        
        mid_cum(bin_n+1:end)=[];
        n_cum(bin_n+1:end)=[];
    end

    n_total = sum(n);
    plot(h_histo_C,  mid_cum,n_cum/n_total*100); %[1:length(Z)]'/length(Z)*100),xlim([0 0.5])
    title(h_histo_C, 'Cum.Histogram')
    ylabel(h_histo_C,  '%');

    
    % overlay plot of Gauss-Distribution using median and sigMad
    if plotCurve
        pdf_cum = zeros(size(n));
        for i=1:length(n),
            pdf_cum(i) = sum(plotCurvePDF(1:i));
        end
        plot(h_histo_C, class_midpoints, pdf_cum/pdf_cum(end)*100, 'r');
    end
end