function [flag] = isfx(asset)
    if ~ischar(asset)
        error('isfx:invalid asset input, a string is expected...')
    end
    
    fn_fx = {'usdx';'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';...
    'eurjpy';'eurchf';'gbpeur';'gbpjpy';'audjpy';...
    'usdcnh'};
    
    if sum(strcmpi(asset,fn_fx)) > 0
        flag = true;
    else
        flag = false;
    end
end