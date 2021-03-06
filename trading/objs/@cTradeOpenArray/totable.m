function [ table, headers ] = totable(obj, start_pos, end_pos)
    if ~exist('start_pos', 'var')
        start_pos = 1;
    end

    if ~exist('end_pos', 'var')
        end_pos = start_pos + length(obj.node_) - 1; 
    end    

    trades = obj.node_(start_pos : end_pos);
    N = length(trades);
    
    %note:yangyiran:20180809
    %we used force all the trades with the same opensignal and riskmangaer
    %and now we shall release this restriction given all the properties of
    %opensignal_ and riskmanager_ stored in string respectively
    [data,headers] = trades(1).tradeopen2table;
    
    table = cell(N+1,length(headers));
    table(1,:) = headers;
    table(2,:) = data;
    for i = 2:N
        data = trades(i).tradeopen2table;
        table(i+1,:) = data;
    end
    
    obj.table_   = table;
    obj.headers_ = headers;

end