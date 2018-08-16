function val = spliceFixedTimeQuote(data, quoteTime, fixed_time_)
% 基于固定时间的数据切片
%Import
% fixed_time_输入的当前时间切片
% data是组成的时间切片上的数据
% quoteTime取行情的数据
%进而输出相应的数据切片
% 吴云峰 20170616

if ~exist('fixed_time_', 'var')
    % 取一分钟的数据
    minSecond      = 60;
    setToday       = today;
    % 将时间轴进行固定
    morningStart   = setToday + 9/24  + 30/24/60;
    morningEnd     = setToday + 11/24 + 30/24/60;
    afternoonStart = setToday + 13/24 + 1/24/60;
    afternoonEnd   = setToday + 15/24;
    fixed_time_ = morningStart:minSecond/24/60/60:morningEnd;
    fixed_time_ = [ fixed_time_ , afternoonStart:minSecond/24/60/60:afternoonEnd ];
end

if isempty( data )
    val = [];
    return;
end

% 数据的长度和宽度
data_sz    = size(data, 1);
data_colsz = size(data, 2);
if data_sz < data_colsz
    % 进行数据的对齐
    data = data';
    data_sz    = size(data, 1);
    data_colsz = size(data, 2);
end

% 数据的起始时间
setToday     = floor( quoteTime(1) );
morningStart = setToday + 9/24 + 30/24/60;
t_sz         = length( fixed_time_ );
val          = nan(t_sz , data_colsz);
start_time   = quoteTime(1);
end_time     = quoteTime(end);

if start_time < morningStart
    
    val(1,:) = data(1,:);
    t_end    = find( end_time > fixed_time_ );
    if isempty( t_end )
        val( 1 ) = data(end,:);
    else
        t_end    = t_end( end );
        node_pos = 2;
        for t = 2:t_end
            while( quoteTime(node_pos) <= fixed_time_( t ) && node_pos <= data_sz )
                node_pos = node_pos + 1;
            end
            node_pos = node_pos - 1;
            if node_pos <= data_sz
                val( t,: ) = data(node_pos,:);
                node_pos = node_pos + 1;
            end
            if node_pos > data_sz
                break;
            end
        end
    end
    
else
    
    start_pos = find( start_time < fixed_time_ );
    start_pos = start_pos( 1 );
    val(start_pos,:) = data(1,:);
    node_pos  = 2;
    if ( end_time - start_time < 1/24/60 )
        val(start_pos,:) = data(end,:);
    else
        t_end = find( end_time > fixed_time_ );
        t_end = t_end( end );
        for t = start_pos+1:t_end
            while( quoteTime(node_pos) <= fixed_time_( t ) && node_pos <= data_sz )
                node_pos = node_pos + 1;
            end
            node_pos = node_pos - 1;
            if node_pos <= data_sz
                val( t,: ) = data(node_pos,:);
                node_pos = node_pos + 1;
            end
            if node_pos > data_sz
                break;
            end
        end
    end
end

% 针对数据进行去杂
val(abs(val) < 0.0001-eps) = nan;

% 将数据进行初始值去nan
for col = 1:data_colsz
    val_col_ = val(:,col);
    nan_idx = isnan(val_col_);
    opposite_nan_idx = find(~nan_idx);
    if isempty(opposite_nan_idx)
    else
        if nan_idx(1)
            first_value = val_col_(opposite_nan_idx(1));
            for t = 1:opposite_nan_idx(1)-1
                val_col_(t) = first_value;
            end
        end
    end
    val(:,col) = val_col_;
end








end