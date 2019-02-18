function [filename] = totxt2(obj, filename, start_pos, end_pos)
    po = strfind(filename, '.txt');
    if isempty(po), filename = [filename '.txt'];end
    if ~exist('start_pos','var'), start_pos = 1;end
    if ~exist('end_pos','var'), end_pos = start_pos + length(obj.node_) - 1;end
    if end_pos < start_pos, fprintf('cTradeOpenArray:totxt:invalid input of start_pos and end_pos');return;end
    
    [table,~] = obj.totable2(start_pos,end_pos);
    
    fid = fopen(filename,'w');
    
    [nrows,ncols] = size(table);
    try
        for i = 1:nrows
            if i == 1
                datafmt = '%s';
                txtstr = 'table{i,1}';
                for j = 2:ncols
                    temp2 = [datafmt,'\t%s'];
                    if j == ncols
                        datafmt = [temp2,'\n'];
                    else
                        datafmt = temp2;
                    end
                    temp = [txtstr,',','table{i,',num2str(j),'}'];
                    txtstr = temp;
                end
            else
                val = table{i,1};
                if ischar(val)
                    datafmt = '%s';
                else
                    datafmt = '%f';
                end
                for j = 2:ncols
                    val = table{i,j};
                    if ischar(val)
                        temp2 = [datafmt,'\t%s'];
                    else
                        temp2 = [datafmt,'\t%f'];
                    end
                    if j == ncols
                        datafmt = [temp2,'\n'];
                    else
                        datafmt = temp2;
                    end
                end
            end
            eval(['fprintf(fid,datafmt,',txtstr,');']);
        end
        fclose(fid);
        
    catch e
        fprintf('cTradeOpenArray:totxt:%s',e.message);
        fclose(fid);
    end
end