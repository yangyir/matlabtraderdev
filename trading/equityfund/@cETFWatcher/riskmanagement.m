function [ret] = riskmanagement(obj,varargin)
% a cETFWatcher method
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    
    BUCKET = 1/48;

    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    for i = 1:n_index
        if isempty(obj.pos_index_{i}), continue;end
        t_vector = obj.intradaybarstruct_index_{i}.px(:,1) + BUCKET;
        idx_end = find(t_vector <= t,1,'last');
        ei = fractal_truncate(obj.intradaybarstruct_index_{i},idx_end);
        riskmanagementintradayend('position',obj.pos_index_{i},'extrainfo',ei);
    end
    %
    for i = 1:n_sector
        if isempty(obj.pos_sector_{i}), continue;end
        t_vector = obj.intradaybarstruct_sector_{i}.px(:,1) + BUCKET;
        idx_end = find(t_vector <= t,1,'last');
        ei = fractal_truncate(obj.intradaybarstruct_sector_{i},idx_end);
        riskmanagementintradayend('position',obj.pos_sector_{i},'extrainfo',ei);
    end
    %
    %not sure we shall introduce intraday for single stock or not
    for i = 1:n_stock
        if isempty(obj.pos_stock_{i}), continue;end
        t_vector = obj.intradaybarstruct_stock_{i}.px(:,1) + BUCKET;
        idx_end = find(t_vector <= t,1,'last');
        ei = fractal_truncate(obj.intradaybarstruct_stock_{i},idx_end);
        riskmanagementintradayend('position',obj.pos_stock_{i},'extrainfo',ei);
    end

end

