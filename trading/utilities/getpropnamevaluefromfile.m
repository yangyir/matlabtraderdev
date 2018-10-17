function [propnames,propvalues] = getpropnamevaluefromfile(filename)
    fid = fopen(filename,'r');
    tline = fgetl(fid);
    lineinfo = regexp(tline,'\t','split');
    n = size(lineinfo,2) - 1;
    propnames = cell(100,1);
    propvalues = cell(100,n);
    count = 0;
    
    while ischar(tline)
        count = count + 1;
        lineinfo = regexp(tline,'\t','split');
        propnames{count} = lineinfo{1};
        
        for i = 2:size(lineinfo,2)
            propvalues{count,i-1} = lineinfo{i};
        end
        tline = fgetl(fid);
    end
    
    propnames = propnames(1:count);
    propvalues = propvalues(1:count,1:n);
    
    fclose(fid);
    
end