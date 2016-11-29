function R = opk2R(om, ph, ka, varargin)

% Input parsing ----------------------------------------------------------------

validAngles = {'Gradian' 'Radian'};

p = inputParser;
p.addRequired( 'om');
p.addRequired( 'ph');
p.addRequired( 'ka');
p.addParameter('Unit', 'Gradian', @(x) any(strcmpi(x, validAngles)));
p.parse(om, ph, ka, varargin{:});
p = p.Results;

% R ----------------------------------------------------------------------------
% Formula from Kraus, p. 489 

if strcmpi(p.Unit, 'Gradian')

    R = [cosg(ph)*cosg(ka)                            -cosg(ph)*sing(ka)                             sing(ph)        
         cosg(om)*sing(ka)+sing(om)*sing(ph)*cosg(ka)  cosg(om)*cosg(ka)-sing(om)*sing(ph)*sing(ka) -sing(om)*cosg(ph)
         sing(om)*sing(ka)-cosg(om)*sing(ph)*cosg(ka)  sing(om)*cosg(ka)+cosg(om)*sing(ph)*sing(ka)  cosg(om)*cosg(ph)];
     
elseif strcmpi(p.Unit, 'Radian')
    
    R = [cos(ph)*cos(ka)                         -cos(ph)*sin(ka)                          sin(ph)        
         cos(om)*sin(ka)+sin(om)*sin(ph)*cos(ka)  cos(om)*cos(ka)-sin(om)*sin(ph)*sin(ka) -sin(om)*cos(ph)
         sin(om)*sin(ka)-cos(om)*sin(ph)*cos(ka)  sin(om)*cos(ka)+cos(om)*sin(ph)*sin(ka)  cos(om)*cos(ph)];
    
end
 
end