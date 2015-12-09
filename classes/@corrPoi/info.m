function info(obj)

% Report output ----------------------------------------------------------------

procHierarchy = {'CORRPOI' 'INFO'};

msg('S', procHierarchy);
msg('I', procHierarchy, sprintf('pc1id = ''%d'', pc2id = ''%d''', obj.pc1id, obj.pc2id));

% Correspondences present? -----------------------------------------------------

if size(obj.X1,1) == 0
    msg('I', procHierarchy, 'termination of function due to missing correspondences');
    return;
end

% Output -----------------------------------------------------------------------

msg('V', size(obj.X1,1), 'no. of correspondences', 'Prec', 0);

msg('V', mean(obj.dp), 'mean(dp)', 'Prec', 5);
msg('V', std(obj.dp) , 'std(dp)' , 'Prec', 5);
% msg('V', min(obj.dp) , 'min(dp)' , 'Prec', 5);
% msg('V', max(obj.dp) , 'max(dp)' , 'Prec', 5);

% msg('V', mean(obj.ds), 'mean(ds)', 'Prec', 5);
% msg('V', std(obj.ds) , 'std(ds)' , 'Prec', 5);
% msg('V', min(obj.ds) , 'min(ds)' , 'Prec', 5);
% msg('V', max(obj.ds) , 'max(ds)' , 'Prec', 5);
% 
% msg('V', mean(obj.A.w), 'mean(w)', 'Prec', 5);
% msg('V', std(obj.A.w) , 'std(w)' , 'Prec', 5);
% msg('V', min(obj.A.w) , 'min(w)' , 'Prec', 5);
% msg('V', max(obj.A.w) , 'max(w)' , 'Prec', 5);
    
msg('E', procHierarchy);

end