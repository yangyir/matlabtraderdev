function [res] = bkfunc_loadintradaydata2(asset,rollinfotbl,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('AssetName',@ischar);
    p.addRequired('RollInfoTable',@iscell);
    p.addParameter('StartDate','2018-01-01',@ischar);
    p.addParameter('Frequency',1,@isnumeric);
    p.parse(asset,rollinfotbl,varargin{:});
    assetname = p.Results.AssetName;
    rolltbl = p.Results.RollInfoTable;
    dtstartstr = p.Results.StartDate;
    dtstartnum = datenum(dtstartstr,'yyyy-mm-dd');
    freq = p.Results.Frequency;
    for i = 1:size(rolltbl,1)
        if rolltbl{i,1} > dtstartnum
            break
        end
    end
    rolltbl2use = rolltbl(i:end,:);
    %
    db = cLocal;
    nrolls = size(rolltbl2use,1);
    intradaydata2use = cell(nrolls+1,1);
    for i = 1:nrolls + 1
        if i ~= nrolls + 1
            dotindex_i = strfind(rolltbl2use{i,4},'.');
            instrument_i = code2instrument(rolltbl2use{i,4}(1:dotindex_i-1));
            if i == 1
                category_i = getfutcategory(instrument_i);
                mktopentimestr = instrument_i.break_interval{1,1};
                if category_i == 1 || category_i == 2
                    mktclosetimestr = instrument_i.break_interval{2,2};
                elseif category_i == 3 || category_i == 4 || category_i == 5
                    mktclosetimestr = instrument_i.break_interval{3,2};
                end
            end
            if i == 1
                dt1 = [datestr(dtstartnum,'yyyy-mm-dd'),' ',mktopentimestr];
            else
                dt1 = [datestr(rolltbl2use{i-1,1},'yyyy-mm-dd'),' ',mktopentimestr];
            end
            dt2 = [datestr(rolltbl2use{i,1},'yyyy-mm-dd'),' ',mktclosetimestr];
        else
            dotindex_i = strfind(rolltbl2use{i-1,5},'.');
            instrument_i = code2instrument(rolltbl2use{i-1,5}(1:dotindex_i-1));
            dt1 = [datestr(rolltbl2use{i-1,1},'yyyy-mm-dd'),' ',mktopentimestr];
            dt2 = [datestr(getlastbusinessdate,'yyyy-mm-dd'),' ',mktclosetimestr];
        end
        intradaydata2use{i}.dt1str = dt1;
        intradaydata2use{i}.dt2str = dt2;
        intradaydata2use{i}.codectp = instrument_i.code_ctp;
        intradaydata2use{i}.data = db.intradaybar(instrument_i,dt1,dt2,freq,'trade');
    end
    
    res = struct('assetname',assetname,...
        'rollinfotable',rolltbl2use,...
        'pricedata',{intradaydata2use});
    
end