function obj = init(obj,varargin)
%cETFWatcher
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','etfwatcher',@ischar);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    %
    %other default values
    obj.conn_ = cWind;
    obj.settimerinterval(1);
    %
    
    [~,~,codes_index,codes_sector,codes_stock] = isinequitypool('');
    
    n_index = length(codes_index);codes_index_wind = cell(n_index,1);names_index = cell(n_index,1);pos_index = cell(n_index,1);
    n_sector = length(codes_sector);codes_sector_wind = cell(n_sector,1);names_sector = cell(n_sector,1);pos_sector = cell(n_sector,1);
    n_stock = length(codes_stock);codes_stock_wind = cell(n_stock,1);names_stock = cell(n_stock,1);pos_stock = cell(n_stock,1);

    for i = 1:n_index
        instrument = code2instrument(codes_index{i});
        codes_index_wind{i} = instrument.code_wind;
        names_index{i} = instrument.asset_name;
        pos_index{i} = {};
    end

    for i = 1:n_sector
        instrument = code2instrument(codes_sector{i});
        codes_sector_wind{i} = instrument.code_wind;
        names_sector{i} = instrument.asset_name;
        pos_sector{i} = {};
    end

    for i = 1:n_stock
        instrument = code2instrument(codes_stock{i});
        codes_stock_wind{i} = instrument.code_wind;
        names_stock{i} = instrument.asset_name;
        pos_stock{i} = {};
    end
    
    obj.codes_index_ = codes_index_wind;
    obj.codes_sector_ = codes_sector_wind;
    obj.codes_stock_ = codes_stock_wind;
    %
    obj.names_index_ = names_index;
    obj.names_sector_ = names_sector;
    obj.names_stock_ = names_stock;
    %
    obj.pos_index_ = pos_index;
    obj.pos_sector_ = pos_sector;
    obj.pos_stock_ = pos_stock;
    %
    obj.dailystatus_index_ = zeros(n_index,1);
    obj.dailystatus_sector_ = zeros(n_sector,1);
    obj.dailystatus_stock_ = zeros(n_stock,1);
    %
    obj.reload;
    %
    %generate daily-frequency trades
    nfractal = 2;
    for i = 1:n_index
        if strcmpi(codes_index{i},'159781') || strcmpi(codes_index{i},'159782'), continue;end
        etf = code2instrument(codes_index{i});
        d = obj.dailybarstruct_index_{i};
        [idxb1,~] = fractal_genindicators1(d.px,...
            d.hh,d.ll,...
            d.jaw,d.teeth,d.lips,...
            'instrument',etf);
        b1type = idxb1(end,2);
        if b1type == 1, continue;end
        j = idxb1(end,1);
        ei = fractal_truncate(d,j);
        op = fractal_filterb1_singleentry(b1type,nfractal,ei,etf.tick_size);
        if op.use
            trade = fractal_gentrade(d,codes_index{i},j,op.comment,1,'daily');
        else
            continue;
        end
        %
        tradeout = {};
        for k = j+1:size(d.px,1)
            ei = fractal_genextrainfo(d,k);
            if k == size(d.px,1)
                ei.latestopen = d.px(k,5);
                ei.latestdt = d.px(k,1);
            else
                ei.latestopen = d.px(k+1,2);
                ei.latestdt = d.px(k+1,1);
            end
            if strcmpi(trade.status_,'closed'),break;end
            tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
                'usecandlelastonly',false,...
                'debug',false,...
                'updatepnlforclosedtrade',true,...
                'extrainfo',ei);
        end
    
        if isempty(tradeout) || trade.id_ == size(d.px,1)
            fprintf('%s:live.\n',trade.code_);
            obj.pos_index_{i} = trade;
        else
            if tradeout.closedatetime1_ >= d.px(end,1)
                fprintf('%s:closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
            end
        end
    end
    
    fprintf('\n');
    
    for i = 1:n_sector
        if strcmpi(codes_sector{i},'512880') || strcmpi(codes_sector{i},'512800'), continue;end
        etf = code2instrument(codes_sector{i});
        d = obj.dailybarstruct_sector_{i};
        [idxb1,~] = fractal_genindicators1(d.px,...
            d.hh,d.ll,...
            d.jaw,d.teeth,d.lips,...
            'instrument',etf);
        b1type = idxb1(end,2);
        if b1type == 1, continue;end
        j = idxb1(end,1);
        ei = fractal_truncate(d,j);
        op = fractal_filterb1_singleentry(b1type,nfractal,ei,etf.tick_size);
        if op.use
            trade = fractal_gentrade(d,codes_sector{i},j,op.comment,1,'daily');
        else
            continue;
        end
        %
        tradeout = {};
        for k = j+1:size(d.px,1)
            ei = fractal_genextrainfo(d,k);
            if k == size(d.px,1)
                ei.latestopen = d.px(k,5);
                ei.latestdt = d.px(k,1);
            else
                ei.latestopen = d.px(k+1,2);
                ei.latestdt = d.px(k+1,1);
            end
            if strcmpi(trade.status_,'closed'),break;end
            tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
                'usecandlelastonly',false,...
                'debug',false,...
                'updatepnlforclosedtrade',true,...
                'extrainfo',ei);
        end
    
        if isempty(tradeout) || trade.id_ == size(d.px,1)
            obj.pos_sector_{i} = trade;
            fprintf('%s:live.\n',trade.code_);
        else
            if k == size(d.px,1)
                fprintf('%s:closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
            end
        end
    end
    
    
end 