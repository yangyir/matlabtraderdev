function [obj] = loadExcel(obj, filename, sheetname)
% LOADEXCEL, 向已有的obj读入excel数据，ArrayBase类的方法
% [obj] = loadExcel(obj, filename, sheetname)
% className的问题比较好解决
% ------------------------------------
% 程刚，20160210
% cg，20160311，更正：读取前先清空

%% 预处理
nodeClassName = class(obj.node);

if ~exist('filename', 'var')
    warning('没有文件名，无法读入');
    return;
end

if ~exist('sheetname', 'var')
    sheetname = nodeClassName;
end


%% main
try
    [num, txt, raw] = xlsread(filename, sheetname);
catch e
    disp(e);
end

% 先清空
eval( ['obj.node = ' nodeClassName ';' ] );

% 逐一读入
[L, C] = size(raw);
for i = 2:L
    eval( ['anode = ', nodeClassName, ';'] );
    for j = 1:C
        fd = raw{1,j};
        anode.(fd) = raw{i,j};
    end
    obj.node(i-1) = anode;
    obj.latest = i-1;
end


%             obj.headers = raw(1,1:end);
%             obj.table   = raw;
end
