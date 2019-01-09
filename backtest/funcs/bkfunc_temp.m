% assets = getassetmaptable;
c = bbgconnect;
db = cLocal;
assets = {'copper'};
nassets = size(assets,1);
dailyvolres = cell(nassets,1);
for i = 1:nassets, dailyvolres{i} = rollfutures(assets{i});end
res = dailyvolres{1};
%%
rollinfo2use = cell(nassets,1);
[dataintraday] = bkfunc_loadintradaydata( c, assets );
for i = 1:nassets
    data = dataintraday{1};
    dtstart = data(1,1);
    res = dailyvolres{i};
    for j = 1:size(res.RollInfo,1)
        if res.RollInfo{j,1} > dtstart
            break
        end
    end
    rollinfo2use{i} = res.RollInfo(j:end,:);
end
%%
% note: rules to calculate intraday returns and to consilidate those
% returns into continuous time series:
% 1. download the pre-active contract until the close on the roll date
% 2. download the post-active contract from the open on the roll date
% 3. use the prices of the pre-active contract until the close on the roll
% date for the intraday return calculation
% 4. use the prices of the post-active contract from the open on the next
% business date after the roll date with the close of the post-active
% contract for the intraday return calculation
% 5.use returns in step 3 and 4 to consolidate continuous return series




nrolls = size(rollinfo2use,1);
intradaydata = cell(nrolls+1,1);

for i = 1:nrolls
    dotindex = strfind(rollinfo2use{i,4},'.');
    instrument = code2instrument(rollinfo2use{i,4}(1:dotindex-1));
    if i == 1
        dt1 = '';
    else
        dt1 = '';
    end
    dt2 = [datestr(rollinfo2use{i,1},'yyyy-mm-dd'),' ',];
end



for i = 1:nrolls+1
    if i == 1
        dotindex = strfind(rollinfo2use{i,4},'.');
        instrument = code2instrument(rollinfo2use{i,4}(1:dotindex-1));
        intradaydata{i} = db.intradaybar(instrument,...
            datestr(floor(dtstart),'yyyy-mm-dd'),...
            datestr(rollinfo2use{i,1},'yyyy-mm-dd'),...
            1,'trade');
    elseif i == nrolls+1
        dotindex = strfind(rollinfo2use{i-1,5},'.');
        instrument = code2instrument(rollinfo2use{i-1,5}(1:dotindex-1));
        intradaydata{i} = db.intradaybar(instrument,...
            datestr(rollinfo2use{i-1,1},'yyyy-mm-dd'),...
            datestr(getlastbusinessdate,'yyyy-mm-dd'),...
            1,'trade');
    else
        dotindex = strfind(rollinfo2use{i,4},'.');
        instrument = code2instrument(rollinfo2use{i,4}(1:dotindex-1));
        intradaydata{i} = db.intradaybar(instrument,...
            datestr(rollinfo2use{i-1,1},'yyyy-mm-dd'),...
            datestr(rollinfo2use{i,1},'yyyy-mm-dd'),...
            1,'trade');
    end
end
