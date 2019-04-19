function [port,pos,cost,margin] = opt_loadpositions2(optdir,optfn)

    fullfn = [optdir,optfn];
    
    if ~isempty(strfind(fullfn,'.txt'))
        fid = fopen(fullfn,'r');
    else
        fid = fopen([fullfn,'.txt'],'r');
    end
        
    if fid < 0, return; end
    port = cell(100,1);
    pos = zeros(100,1);
    cost = zeros(100,1);
    margin = zeros(100,1);
    
    line_ = fgetl(fid);
    count = 0;
    while ischar(line_)
        lineinfo = regexp(line_,'\t','split');
        count = count + 1;
        port{count} = lineinfo{1};
        pos(count) = str2double(lineinfo{2});
        cost(count) = str2double(lineinfo{3});
        margin(count) = str2double(lineinfo{4});
        line_ = fgetl(fid);
    end
            
    fclose(fid);
    port = port(1:count);
    pos = pos(1:count);
    cost = cost(1:count);
    margin = margin(1:count);
    
end