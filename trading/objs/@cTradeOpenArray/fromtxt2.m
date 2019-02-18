function [obj] = fromtxt2(obj, filename)
    po = strfind(filename, '.txt');
    if isempty(po), filename = [filename '.txt'];end
    
    [fid,errmsg] = fopen(filename,'r');
    if fid < 0
        error(['cTradeOpenArray:fromtxt:',errmsg,' in ',filename])
    end
    
    lineinfo = fgetl(fid);
    if lineinfo == -1, return;end
    headers = regexp(lineinfo,'\t','split');
    ncols = length(headers);
    
    tablecell = cell(1000,ncols);
    for j = 1:ncols, tablecell{1,j} = headers{j};end
    nrows = 1;
    
    lineinfo = fgetl(fid);
    while lineinfo ~= -1
        nrows = nrows + 1;
        vals = regexp(lineinfo,'\t','split');
        for j = 1:ncols
            valnum = str2double(vals{j});
            if ~isnan(valnum)
                tablecell{nrows,j} = valnum;
            else
                tablecell{nrows,j} = vals{j};
            end
        end
        lineinfo = fgetl(fid);
    end
    tablecell = tablecell(1:nrows,:);
    
    fclose(fid);
    
    obj = obj.fromtable2(tablecell);
    
    
end