function obj = init(obj,varargin)
%cETFWatcher
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','etfwatcher',@ischar);
    p.addParameter('InitiateWind',false,@islogical);
    p.addParameter('InitiateTHS',true,@islogical);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    %
    %other default values
    initiatewind = p.Results.InitiateWind;
    if initiatewind
        obj.conn_ = cWind;
        obj.iswind_ = true;
    else
        fprintf('cETFWatcher:init:wind not initiated!!!\n');
    end
    %
    intiateTHS = p.Results.InitiateTHS;
    if intiateTHS
        obj.conn2_ = cTHS;
        obj.isths_ = true;
    else
        fprintf('cETFWatcher:init:ths not initiated!!!\n');
    end
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
    obj.dailystatus_index_ = nan(n_index,1);
    obj.dailystatus_sector_ = nan(n_sector,1);
    obj.dailystatus_stock_ = nan(n_stock,1);
    %
    obj.reload;
    %
    %generate daily-frequency trades
    for i = 1:n_index
        if strcmpi(codes_index{i},'159781') || strcmpi(codes_index{i},'159782'), continue;end
        d = obj.dailybarstruct_index_{i};
        trade = fractal_latestposition('code',codes_index{i},...
            'extrainfo',d,...
            'frequency','daily',...
            'usefractalupdate',0,...
            'usefibonacci',1);
        if ~isempty(trade)
            if strcmpi(trade.status_,'set')
                obj.pos_index_{i} = trade;
                obj.dailystatus_index_(i) = trade.opendirection_;
            else
                if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                    obj.dailystatus_index_(i) = 0;
                end
            end
        else
            if ~(obj.dailystatus_index_(i) == 2  || obj.dailystatus_index_(i) == -2)
                obj.dailystatus_index_(i) = 0;
            end
        end
    end
    
    fprintf('\n');
    
    for i = 1:n_sector
        if strcmpi(codes_sector{i},'512880') || strcmpi(codes_sector{i},'512800'), continue;end
        d = obj.dailybarstruct_sector_{i};
        trade = fractal_latestposition('code',codes_sector{i},...
            'extrainfo',d,...
            'frequency','daily',...
            'usefractalupdate',0,...
            'usefibonacci',1);
        if ~isempty(trade)
            if strcmpi(trade.status_,'set')
                obj.pos_sector_{i} = trade;
                obj.dailystatus_sector_(i) = trade.opendirection_;
            else
                if ~(obj.dailystatus_sector_(i) == 2  || obj.dailystatus_sector_(i) == -2)
                    obj.dailystatus_sector_(i) = 0;
                end
            end
        else
            if ~(obj.dailystatus_sector_(i) == 2  || obj.dailystatus_sector_(i) == -2)
                obj.dailystatus_sector_(i) = 0;
            end
        end
    end
    
end 