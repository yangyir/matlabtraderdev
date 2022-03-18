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
    
    n_index = length(codes_index);codes_index_wind = cell(n_index,1);names_index = cell(n_index,1);
    n_sector = length(codes_sector);codes_sector_wind = cell(n_sector,1);names_sector = cell(n_sector,1);
    n_stock = length(codes_stock);codes_stock_wind = cell(n_stock,1);names_stock = cell(n_stock,1);

    for i = 1:n_index
        instrument = code2instrument(codes_index{i});
        codes_index_wind{i} = instrument.code_wind;
        names_index{i} = instrument.asset_name;
    end

    for i = 1:n_sector
        instrument = code2instrument(codes_sector{i});
        codes_sector_wind{i} = instrument.code_wind;
        names_sector{i} = instrument.asset_name;
    end

    for i = 1:n_stock
        instrument = code2instrument(codes_stock{i});
        codes_stock_wind{i} = instrument.code_wind;
        names_stock{i} = instrument.asset_name;
    end
    
    obj.codes_index_ = codes_index_wind;
    obj.codes_sector_ = codes_sector_wind;
    obj.codes_stock_ = codes_stock_wind;

    obj.names_index_ = names_index;
    obj.names_sector_ = names_sector;
    obj.names_stock_ = names_stock;
    %
    %
    obj.reload;
    
    
end 