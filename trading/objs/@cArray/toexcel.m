function [ filename ] = toexcel(obj, filename, sheetname, start_pos, end_pos)
    % default.xlsx as EXCEL format
    className = class(obj);
    if ~exist('filename', 'var')
        filename = ['my_',className,'.xlsx'];
    else
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
    end


    % default sheetnames
    if ~exist('sheetname', 'var')
        sheetname = class(obj.node);
    end

    if ~exist('start_pos', 'var')
        start_pos = 1;
    end

    if ~exist('end_pos', 'var')
        end_pos = start_pos + length(obj.node_) - 1; 
    end

    % empty case
    if end_pos < start_pos
        return;
    end
    % transform to data
    obj.totable(start_pos, end_pos);

    % write data to excel
    all_data = obj.table_;
    if isempty(all_data), all_data = {''}; end
    xlswrite(filename, all_data, sheetname);

end
