function [] = init_wind(obj,w)
%FX
    ctpstr = obj.code_wind;
    if isempty(ctpstr)
        return
    end

    if nargin < 2, return; end

    if ~isa(w,'windmatlab')
        error('cFX:init_wind:invalid wind connection')
    end

    wind_fields = {'sec_englishname','exch_eng'};

    [wdata,~,~,~,errorid,~] = w.wss(obj.code_wind,wind_fields);

    if errorid ~= 0
        error('cFX:init_wind failed')
    end

    if isnan(wdata{1})
        obj.asset_name = 'n/a';
    else
        obj.asset_name = wdata{1};
    end
    if isnan(wdata{2})
        obj.exchange = 'n/a';
    else
        obj.exchange = wdata{2};
    end
    
end
%end of init_wind

