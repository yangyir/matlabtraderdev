function [res] = bkfunc_loadintradaydata2(asset,rollinfotbl,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addRequired('AssetName',@ischar);
    p.addRequired('RollInfoTable',@iscell);
    p.addParameter('StartDate','2018-01-01',@ischar);
    p.addParameter('EndDate',datestr(getlastbusinessdate,'yyyy-mm-dd'),@ischar);
    p.addParameter('Frequency',1,@isnumeric);
    p.addParameter('DaysShift',0,@isnumeric);
    p.parse(asset,rollinfotbl,varargin{:});
    assetname = p.Results.AssetName;
    rolltbl = p.Results.RollInfoTable;
    dtstartstr = p.Results.StartDate;
    dtendstr = p.Results.EndDate;
    dtstartnum = datenum(dtstartstr,'yyyy-mm-dd');
    dtendnum = datenum(dtendstr,'yyyy-mm-dd');
    freq = p.Results.Frequency;
    daysshift = p.Results.DaysShift;
    istart = 1;
    iend = size(rolltbl,1);
    for i = 1:size(rolltbl,1)
        if rolltbl{i,1} > dtstartnum
            istart = i;
            break
        end
    end
    for i = 1:size(rolltbl,1)
        if rolltbl{i,1} > dtendnum
            iend = i-1;
            break
        end
    end
    rolltbl2use = rolltbl(istart:iend,:);
    %
    db = cLocal;
    nrolls = size(rolltbl2use,1);
    intradaydata2use = cell(nrolls+1,1);
    for i = 1:nrolls + 1
        if i ~= nrolls + 1
            instrument_i = code2instrument(rolltbl2use{i,4});
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
                if daysshift == 0
                    dt1 = [datestr(rolltbl2use{i-1,1},'yyyy-mm-dd'),' ',mktopentimestr];
                else
                    dt1 = dateadd(rolltbl2use{i-1,1},[num2str(daysshift),'b']);
                    dt1 = [datestr(dt1,'yyyy-mm-dd'),' ',mktopentimestr];
                end
            end
            dt2 = [datestr(rolltbl2use{i,1},'yyyy-mm-dd'),' ',mktclosetimestr];
        else
            instrument_i = code2instrument(rolltbl2use{i-1,5});
            if daysshift == 0
                dt1 = [datestr(rolltbl2use{i-1,1},'yyyy-mm-dd'),' ',mktopentimestr];
            else
                dt1 = dateadd(rolltbl2use{i-1,1},[num2str(daysshift),'b']);
                dt1 = [datestr(dt1,'yyyy-mm-dd'),' ',mktopentimestr];
            end
            if iend == size(rolltbl,1)
                dt2 = [datestr(getlastbusinessdate,'yyyy-mm-dd'),' ',mktclosetimestr];
            else
                dt2 = [datestr(rolltbl{iend+1,1},'yyyy-mm-dd'),' ',mktopentimestr];
            end
        end
        intradaydata2use{i}.dt1str = dt1;
        intradaydata2use{i}.dt2str = dt2;
        intradaydata2use{i}.codectp = instrument_i.code_ctp;
        intradaydata2use{i}.data = db.intradaybar(instrument_i,dt1,dt2,freq,'trade');
    end
    
    res = struct('assetname',{assetname},...
        'rollinfotable',{rolltbl2use},...
        'pricedata',{intradaydata2use});
    
end