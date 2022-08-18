function [] = init_wind(obj,w)
%FX
    ctpstr = obj.code_wind;
    if isempty(ctpstr)
        return
    end

    if nargin < 2, return; end

    if ~isa(w,'windmatlab')
        error('cStock:init_wind:invalid wind connection')
    end

    wind_fields = {'sec_englishname','exch_eng'};

    [wdata,~,~,~,errorid,~] = w.wss(obj.code_wind,wind_fields);

    if errorid ~= 0
        error('cStock:init_wind failed')
    end

    obj.asset_name = wdata{1};
    obj.exchange = wdata{2};
    
end
%end of init_wind

