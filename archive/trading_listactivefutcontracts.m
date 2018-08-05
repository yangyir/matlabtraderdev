if ~(exist('conn','var') && isa(conn,'cBloomberg'))
    conn = cBloomberg;
end
%%
asset_list = {'eqindex_300';'eqindex_50';'eqindex_500';...
    'govtbond_5y';'govtbond_10y';...
    'crude oil';...
    'gold';'silver';...
    'copper';'aluminum';'zinc';'lead';'nickel';...
    'deformed bar';'iron ore';...
    'pta';'lldpe';'pp';'methanol';...
    'sugar';'cotton';'corn';'egg';...
    'soybean';'soymeal';'soybean oil';'palm oil';...
    'rapeseed oil';'rapeseed meal'};

bbg_codes = cell(size(asset_list));
active_fut_codes = cell(size(asset_list));

for i = 1:size(asset_list,1)
    assetinfo = getassetinfo(asset_list{i});
    bbg_codes{i} = assetinfo.BloombergCode;
    excode = assetinfo.ExchangeCode;
    if strcmpi(excode,'.SHF') || strcmpi(excode,'.DCE')
        active_fut_codes{i} = lower(assetinfo.WindCode);
    else
        active_fut_codes{i} = upper(assetinfo.WindCode);
    end
    
    try
        if strcmpi(asset_list{i},'eqindex_300') || ...
                strcmpi(asset_list{i},'eqindex_50') || ...
                strcmpi(asset_list{i},'eqindex_500')
            check = conn.ds_.getdata([bbg_codes{i},'A Index'],'parsekyable_des');
            nright = length(' Index');
        else
            check = conn.ds_.getdata([bbg_codes{i},'A Comdty'],'parsekyable_des');
            nright = length(' Comdty');
        end
        %
        bcode_i = check.parsekyable_des;
        if iscell(bcode_i), bcode_i = bcode_i{1};end
        bcode_i = bcode_i(1:length(bcode_i)-nright);
        futcode = bcode_i(end-1:end-1);
        futyear = bcode_i(end);
        if strcmpi(excode,'.CZC')
            yearstr = bcode_i(end);
        else
            yearstr = ['1',bcode_i(end)];
        end
        mm = strfind('FGHJKMNQUVXZ',futcode);
        if mm > 9
            monthstr = num2str(mm);
        else
            monthstr = ['0',num2str(mm)];
        end
        
        active_fut_codes{i} = [active_fut_codes{i},yearstr,monthstr];           
    catch e
        fprintf('error for %s:%s\n',assetinfo.AssetName,e.message);
    end
end