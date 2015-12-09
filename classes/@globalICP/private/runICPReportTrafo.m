function runICPReportTrafo(obj, p, g)

msg('S', {g.proc{:} 'FINAL TRANSFORMATION PARAMETERS'}, 'LogLevel', 'basic');

msg('T', 'COORDINATE REDUCTION POINT:', 'LogLevel', 'basic');
msg('V', obj.D.redPoi(1), 'reduction point / x', 'Prec', 4, 'LogLevel', 'basic');
msg('V', obj.D.redPoi(2), 'reduction point / y', 'Prec', 4, 'LogLevel', 'basic');
msg('V', obj.D.redPoi(3), 'reduction point / z', 'Prec', 4, 'LogLevel', 'basic');

for i = 1:g.nPC

    msg('T', sprintf('POINT CLOUD [%d]:', i), 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(1,1), 'a11', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(1,2), 'a12', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(1,3), 'a13', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(2,1), 'a21', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(2,2), 'a22', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(2,3), 'a23', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(3,1), 'a31', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(3,2), 'a32', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(3,3), 'a33', 'Prec', 7, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(1,4), 'tx' , 'Prec', 4, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(2,4), 'ty' , 'Prec', 4, 'LogLevel', 'basic');
    msg('V', obj.D.H{i}(3,4), 'tz' , 'Prec', 4, 'LogLevel', 'basic');
    
end

msg('E', {g.proc{:} 'FINAL TRANSFORMATION PARAMETERS'}, 'LogLevel', 'basic');

end