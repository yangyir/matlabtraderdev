function [filename] = totxt(obj, filename, start_pos, end_pos)
    po = strfind(filename, '.txt');
    if isempty(po), filename = [filename '.txt'];end
    if ~exist('start_pos','var'), start_pos = 1;end
    if ~exist('end_pos','var'), end_pos = start_pos + length(obj.node_) - 1;end
    if end_pos < start_pos, fprintf('cTradeOpenArray:totxt:invalid input of start_pos and end_pos');return;end
    
    [table,headers] = obj.totable(start_pos,end_pos);
    
    fid = fopen(filename,'w');
    
    [nrows,ncols] = size(table);
    try
        for i = 1:nrows
            if i == 1
                for j = 1:ncols
                    
                end
            else
            end
            
        end
    catch e
        fprintf('cTradeOpenArray:totxt:%s',e.message);
        fclose(fid);
    end
end