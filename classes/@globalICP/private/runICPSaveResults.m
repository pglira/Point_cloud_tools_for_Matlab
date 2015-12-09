function obj = runICPSaveResults(obj, g)

msg('S', {g.proc{:} 'SAVE RESULTS'}, 'LogLevel', 'basic');

% Check if called from opals
st = dbstack; % function call stack
calledFromOpals = false; % default
for i = 1:numel(st)
    if strcmp(st(i).file, 'ICP4opals.m')
        calledFromOpals = true;
    end
end

if ~calledFromOpals % if not called from opals

    % Export HO
    fid = fopen(fullfile(obj.OutputFolder, 'TrafoPrmOrigin.txt'), 'at');
    fprintf(fid, '##\n'); % to denote a new call of globalICP (since input is appended to file)
    for i = 1:numel(obj.PC)
        fprintf(fid, '# point cloud %d: %s\n', i, obj.PC{i});
        for j = 1:4 % for each row
            fprintf(fid, '%20.12f %20.12f %20.12f %20.12f\n', obj.D.HO{i}(j,:));
        end
    end
    fclose(fid);

    % Export H
    fid = fopen(fullfile(obj.OutputFolder, 'TrafoPrmRedPoi.txt'), 'at');
    fprintf(fid, '##\n');
    fprintf(fid, '# reduction point\n');
    fprintf(fid, '%20.3f %20.3f %20.3f\n', obj.D.redPoi);
    for i = 1:numel(obj.PC)
        fprintf(fid, '# point cloud %d: %s\n', i, obj.PC{i});
        for j = 1:4 % for each row
            fprintf(fid, '%20.12f %20.12f %20.12f %20.12f\n', obj.D.H{i}(j,:));
        end
    end
    fclose(fid);

    % Export affine filter for opals
    fid = fopen(fullfile(obj.OutputFolder, 'TrafoPrmOrigin4Opals.txt'), 'at');
    fprintf(fid, '##\n');
    for i = 1:numel(obj.PC)
        trafoPrm = [obj.D.HO{i}(1,1:3) obj.D.HO{i}(2,1:3) obj.D.HO{i}(3,1:3) obj.D.HO{i}(1:3,4)']; % a11 a12 a13 a21 a22 a23 a31 a32 a33 a14 a24 a34
        fprintf(fid, '# point cloud %d: %s -> -filter "affine[%.12f %.12f %.12f %.12f %.12f %.12f %.12f %.12f %.12f %.12f %.12f %.12f]"\n', i, obj.PC{i}, trafoPrm);
    end
    fclose(fid);
    
end

% Save object
save(fullfile(obj.OutputFolder, 'ICP.mat'), 'obj');

msg('E', {g.proc{:} 'SAVE RESULTS'}, 'LogLevel', 'basic');
    
end