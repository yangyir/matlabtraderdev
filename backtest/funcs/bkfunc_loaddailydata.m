function [ dataDailybar,codeList ] = bkfunc_loaddailydata( bbgConn, assetList )
    %
    bkdataDir = [getenv('ONEDRIVE'),'\backtest\'];
    lastbd = businessdate(getlastbusinessdate,-1);
    
    nasset = length(assetList);
    codeList = cell(nasset,1);
    assetInfo = cell(nasset,1);
    dataDailybar = cell(nasset,1);
    for i = 1:nasset
        assetInfo{i} = getassetinfo(assetList{i});
        fileName = [assetList{i},'_daily.mat'];
        %1.first check whether the file exist or not
        flag = hasfileindirectory(bkdataDir,fileName);
        if flag
            %2.load the file if it exists
            load([bkdataDir,fileName]);
            evalstr = ['lastobs = ',assetList{i},'_daily(end,1);'];
            eval(evalstr);
            %3.check whether the last observation is in the past
            if lastobs < lastbd
                %load the latest data from bloomberg
%                 dataNew = bbgConn.timeseries(assetInfo{i}.BloombergSec1,...
%                     {businessdate(floor(lastobs),1),datestr(getlastbusinessdate,'yyyy-mm-dd')},1,'trade');
                dataNew = bbgConn.history(assetInfo{i}.BloombergSec1,...
                    {'px_open','px_high','px_low','px_last','volume'},businessdate(lastobs,1),datestr(getlastbusinessdate,'yyyy-mm-dd'));
                evalstr = ['dataDailybar{i} = [',assetList{i},'_daily;dataNew];'];
                eval(evalstr);
            else
                %nothing to do if the data is the latest already
                evalstr = ['dataDailybar{i} = ',assetList{i},'_daily;'];
                eval(evalstr);
            end
        else
            %load data from bloomberg if there is no file exist
            dataDailybar{i} = bbgConn.history(assetInfo{i}.BloombergSec1,...
                {'px_open','px_high','px_low','px_last','volume'},'2015-01-01',datestr(getlastbusinessdate,'yyyy-mm-dd'));
        end
        temp = bbgConn.getdata(assetInfo{i}.BloombergSecA,'parsekyable_des');
        codeList{i} = bbg2ctp(temp.parsekyable_des{1});
        check = regexp(assetList{i},' ','split');
        if length(check) == 2
            evalstr = sprintf('%s_daily = dataDailybar{i};',[check{1},check{2}]);
            eval(evalstr);
            save([bkdataDir,check{1},check{2},'.mat'],[check{1},check{2},'_daily']);
        else
            evalstr = sprintf('%s_daily = dataDailybar{i};',assetList{i});
            eval(evalstr);
            save([bkdataDir,assetList{i},'.mat'],[assetList{i},'_daily']);
        end
    end

end

