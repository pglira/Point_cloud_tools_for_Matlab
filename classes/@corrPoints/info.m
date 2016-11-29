function info(obj)

% Report output ----------------------------------------------------------------

procHierarchy = {'CORRPOINTS' 'INFO'};

msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('Corr. points label = ''%s''', obj.label));

% Correspondences present? -----------------------------------------------------

if obj.noCP == 0
    msg('I', procHierarchy, 'no correspondences present!');
    msg('E', procHierarchy);
    return;
end

% Output -----------------------------------------------------------------------

msg('V', obj.noCP    , 'no. of correspondences', 'Prec', 0);
msg('V', mean(obj.dp), 'mean(dp)'              , 'Prec', 5);
msg('V', std(obj.dp) , 'std(dp)'               , 'Prec', 5);
    
msg('E', procHierarchy);

end