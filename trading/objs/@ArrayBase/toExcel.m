function [ filename ] = toExcel(obj, filename, sheetname, start_pos, end_pos)
% toExcel把TEBase.headers, TEBase.data(如为空则生成）写入excel中
% 格式：[ obj ] = toExcel(obj, filename, sheetname)
% sheetname（默认'data'）中放Ticks.headers, Ticks.data
% filename默认my_className.xlsx，默认类型.xlsx
% savepath默认当前，否则可专门写进filename里
% 吴云峰:修改一个Bug：empty case:原[if end_pos <= start_pos]修改为[if end_pos < start_pos]
% --------------------------------------------------------
% 程刚；140806
% 吴云峰；161117


%% 预处理

% 默认xlsx类型
className = class(obj);
if ~exist('filename', 'var')
    filename = [ 'my_' className '.xlsx'];
else
    po = strfind(filename, '.xls');
    if isempty(po)
        % 添加扩展名
        filename = [filename '.xlsx']; 
    else
        po = po(end);
        ext = filename(po:end);
        if ~strcmp(ext, '.xls') ||  ~strcmp(ext, '.xlsx') ...
        || ~strcmp(ext, '.xlsm') || ~strcmp(ext, '.xlsb')
            % 改变扩展名
            filename = [filename(1:po-1) '.xlsx'];
        end
    end
end


% 默认sheetnames
if ~exist('sheetname', 'var')
    sheetname = class(obj.node);
end

if ~exist('start_pos', 'var')
    start_pos = 1;
end

if ~exist('end_pos', 'var')
    end_pos = start_pos + length(obj.node) - 1; 
end

% empty case
if end_pos < start_pos
    return;
end
% 强制重新生成data
obj.toTable(start_pos, end_pos);



%% 写入内容
all_data = obj.table;
if isempty(all_data), all_data = {''}; end
xlswrite(filename, all_data, sheetname);


end
