function [assetname,exch] = getexchangestr(obj)
%cStock
    assetname = obj.asset_name;
    exch = obj.exchange;
end