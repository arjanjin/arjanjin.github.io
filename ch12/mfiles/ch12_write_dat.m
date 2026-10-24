function ch12_write_dat(fn, names, M, step)
%CH12_WRITE_DAT  Write a whitespace-separated .dat file with a header row
%   (pgfplots "table" format), keeping every step-th row.
M = M(1:step:end,:);
fid = fopen(fn,'w');
fprintf(fid,'%s\n', strjoin(names,' '));
fprintf(fid,[repmat('%.6f ',1,size(M,2)-1) '%.6f\n'], M.');
fclose(fid);
end
