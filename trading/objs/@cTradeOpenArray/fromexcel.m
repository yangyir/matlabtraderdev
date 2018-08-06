function [obj] = fromexcel(obj, filename, sheetname)
   
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
    
    obj = obj.fromtable(raw);

end