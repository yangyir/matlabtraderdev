function [obj] = fromexcel(obj, filename, sheetname)

    nodeClassName = class(obj.node_);
    
    if ~exist('filename', 'var')
        error('cTradeOpenArray:fromexcel:invalid input of filename')
    end

    if ~exist('sheetname', 'var')
        error('cTradeOpenArray:fromexcel:invalid input of sheetname')
    end

    % main
    try
        [~, ~, raw] = xlsread(filename, sheetname);
    catch e
        fprintf('%s\n',e.message);
    end

    % 先清空
    eval( ['obj.node = ' nodeClassName ';' ] );

    % 逐一读入
    [nrows, ncols] = size(raw);
    for i = 2:nrows
        eval( ['anode = ', nodeClassName, ';'] );
        for j = 1:ncols
            try
                fd = raw{1,j};
                if strfind(fd,'opensignal_') == 1
                    
                    
                    
                elseif strfind(fd,'riskmanager_') == 1
                else
                    anode.(fd) = raw{i,j};
                end
            catch
            end
        end
        obj.node_(i-1) = anode;
        obj.latest_ = i-1;
    end


end