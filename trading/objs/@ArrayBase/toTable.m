function [ table, flds ] = toTable( obj, start_pos, end_pos)
%TOTABLE 每个node写一行，逐行写


% 矩阵输出时间序列，存在TEBase.data, TEBase.headers里
% 原TradeList和EntrustList中单独的域和方法统一到这个
% 可供输出excel用。Ticks,Bars,TradeList里也有同样的函数
% headers的优先级：入参里 > obj.headers > default_headers(主要域都含）
% ===============================================================
% 程刚，140805


%% 简单版本，域内值都是标量

if ~exist('start_pos', 'var')
    start_pos = 1;
end

if ~exist('end_pos', 'var')
    end_pos = start_pos + length(obj.node) - 1; 
end

nodes = obj.node(start_pos : end_pos);
N = length(nodes);

flds = properties( nodes );
F = length(flds);

table = cell(N+1, F);


% 第一行写标题
for col = 1:F
    f = flds{col};
    table{1, col} = f;
end


% 第2到N+1行写数据，假设数据都是标量
for lin = 1:N
    for col = 1:F
        n = nodes(lin);
        f = flds{col};
        table{lin+1, col} = n.(f);
    end
end


%%

obj.table   = table;
obj.headers = flds;

end



 %% 预处理
% 
% % 所有域全包含
% all_fields = properties( obj );
% 
% % 选出所有N*1向量域， 所有标量域
% default_headers  = {};  % 所有N*1向量域
% default_headers2 = {}; % 所有标量域，暂时不用
% lenN             = size(obj.time, 1);
% for i = 1:length(all_fields)
%     f   = all_fields{i};
%     s1  = size( obj.(f), 1);
%     s2  = size( obj.(f), 2);
%     
%     % 所有N*1向量域
%     if s1 == lenN && s2 == 1
%         default_headers{end+1} = f;
%     end
%     
%     % 所有标量域
%     if s1 == 1 && s2 == 1
%         default_headers2{end+1} = f;
%     end
% end
% 
% 
%     
%     
% if ~exist('headers', 'var')
%     if isempty(obj.headers)
%         headers = default_headers;
%     else
%         headers = obj.headers;
%     end    
% end
% 
% 
% %% 时间序列向量， 放入data
% data    = nan(lenN, length(headers));
% 
% for i = 1:length(headers)
%     f = headers{i};
%     try
%         data(:,i) = obj.(f);
%     catch e
%         disp( [f '出错！'] );
%     end
% end




%% 信息标量, 放入data2（暂无）






