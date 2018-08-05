function [ret,activefutlist] = trading_func_loadactivefut(datasource)

ret = 0;
activefutlist = {};

if ~(isa(datasource,'cBloomberg') || isa(datasource,'cLocal'))
    error('trading_loadactivefut:datasource shall be either bloomberg or local');
end

path = 'c:\yangyiran\';
try
    cd(path);
catch
    mkdir(path);
end
fn = 'activefutlist.txt';

if isa(datasource,'cBloomberg')
    try
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
        nasset = size(asset_list,1);
        activefutlist = cell(nasset,1);
        for i = 1:nasset
            assetinfo = getassetinfo(asset_list{i});
            bbg_codes = assetinfo.BloombergCode;
            excode = assetinfo.ExchangeCode;
            if strcmpi(excode,'.SHF') || strcmpi(excode,'.DCE')
                activefutlist{i} = lower(assetinfo.WindCode);
            else
                activefutlist{i} = upper(assetinfo.WindCode);
            end
            
            if strcmpi(asset_list{i},'eqindex_300') || ...
                    strcmpi(asset_list{i},'eqindex_50') || ...
                    strcmpi(asset_list{i},'eqindex_500')
                check = datasource.ds_.getdata([bbg_codes,'A Index'],'parsekyable_des');
                nright = length(' Index');
            else
                check = datasource.ds_.getdata([bbg_codes,'A Comdty'],'parsekyable_des');
                nright = length(' Comdty');
            end
            %
            bcode_i = check.parsekyable_des;
            if iscell(bcode_i), bcode_i = bcode_i{1};end
            bcode_i = bcode_i(1:length(bcode_i)-nright);
            futcode = bcode_i(end-1:end-1);
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
            activefutlist{i} = [activefutlist{i},yearstr,monthstr];
        end
    catch e
        fprintf('trading_loadactivefut:error:%s\n',e.message);
    end
    
    fid = fopen([path,fn],'w');
    fprintf(fid,'%s\n','futcode');
    for i = 1:nasset
        fprintf(fid,'%s\n',activefutlist{i});
    end
    fclose(fid);
    ret = 1;
elseif isa(datasource,'cLocal')
    try
        fid = fopen([path,fn],'r');
        if fid < 0, return; end
    
        line_ = fgetl(fid);
        count = 0;
        activefutlist = cell(100,1);
        while ischar(line_)
            count = count + 1;
            if count > 1
                activefutlist{count-1} = line_;
            end
            line_ = fgetl(fid);
        end
    catch e
        fprintf('trading_loadactivefut:error:%s\n',e.message);
        fclose(fid);
    end
    fclose(fid);
    activefutlist = activefutlist(1:count-1);
    ret = 1;
end



end