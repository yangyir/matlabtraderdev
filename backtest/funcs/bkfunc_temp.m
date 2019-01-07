assets = getassetmaptable;
nassets = size(assets,1);
dailyvolres = cell(nassets,1);
for i = 1:nassets
    dailyvolres{i} = rollfutures(assets{i});
end
%%
code1 = 'cu1901';
code2 = 'cu1902';
codebbg1 = ctp2bbg(code1);
codebbg2 = ctp2bbg(code2);
c = bbgconnect;
data1 = c.history(codebbg1,'open_int',datenum('20181101','yyyymmdd'),datenum('20181215','yyyymmdd'));
data2 = c.history(codebbg2,'open_int',datenum('20181101','yyyymmdd'),datenum('20181215','yyyymmdd'));
check = [data1(:,1),data1(:,2)-data2(:,2)];
% cu1902 becomed the active contract on 29-Nov-2018
%%
assetInfo = getassetinfo('copper');
data = c.timeseries(assetInfo.BloombergSec1,{'2018-01-01',datestr(getlastbusinessdate,'yyyy-mm-dd')},1,'trade');
%%
db = cLocal;
dtstart = data(1,1);
for i = 1:size(res.RollInfo,1)
    if res.RollInfo{i,1} > dtstart
        break
    end
end
rollinfo2use = res.RollInfo(i:end,:);
ndata = size(rollinfo2use,1);
intradaydata = cell(ndata+1,1);
for i = 1:ndata+1
    if i == 1
        dotindex = strfind(rollinfo2use{i,4},'.');
        instrument = code2instrument(rollinfo2use{i,4}(1:dotindex-1));
        intradaydata{i} = db.intradaybar(instrument,...
            datestr(floor(dtstart),'yyyy-mm-dd'),...
            datestr(rollinfo2use{i,1},'yyyy-mm-dd'),...
            1,'trade');
    elseif i == ndata+1
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
