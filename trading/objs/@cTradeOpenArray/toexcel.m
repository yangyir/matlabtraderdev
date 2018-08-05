function [filename] = toexcel(obj, filename, sheetname, start_pos, end_pos)
    po = strfind(filename, '.xls');
    if isempty(po)
        filename = [filename '.xlsx'];
    else
        po = po(end);
        ext = filename(po:end);
        if ~strcmp(ext, '.xls') ||  ~strcmp(ext, '.xlsx') ...
                || ~strcmp(ext, '.xlsm') || ~strcmp(ext, '.xlsb')
            filename = [filename(1:po-1) '.xlsx'];
        end
    end
    
    if ~exist('sheetname','var'), sheetname = 'tradeopen';end
    if ~exist('start_pos','var'), start_pos = 1;end
    if ~exist('end_pos','var'), end_pos = start_pos + length(obj.node_) - 1;end
    if end_pos < start_pos, fprintf('cTradeOpenArray:toexcel:invalid input of start_pos and end_pos');return;end
    
    [table,~] = obj.totable(start_pos,end_pos);

    if isempty(table), table = {''};end
    xlswrite(filename, table, sheetname);
    
end