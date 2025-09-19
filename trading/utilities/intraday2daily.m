function [dailybar] = intraday2daily(code)

% code = 'T2512';
path_ = [getenv('datapath'),'intradaybar\',code,'\'];
filelist = dir(path_);

fn1 = filelist(3).name;
fn2 = filelist(end).name;



dt1 = datenum(fn1(length(code)+2:length(code)+9),'yyyymmdd');
dt2 = datenum(fn2(length(code)+2:length(code)+9),'yyyymmdd');
dts = gendates('fromdate',dt1,'todate',dt2);
dailybar = zeros(length(dts),5);
for i = 1:length(dts)
    try
        data = cDataFileIO.loadDataFromTxtFile([path_,code,'_',datestr(dts(i),'yyyymmdd'),'_1m.txt']);
        dailybar(i,1) = floor(data(1,1));
        dailybar(i,2) = data(1,2);
        dailybar(i,3) = max(data(:,3));
        dailybar(i,4) = min(data(:,4));
        dailybar(i,5) = data(end,5);
    catch
        dailybar(i,1) = dts(i);
        dailybar(i,2) = NaN;
        dailybar(i,3) = NaN;
        dailybar(i,4) = NaN;
        dailybar(i,5) = NaN;
    end
            
end

coldefs = {'date','open','high','low','close'};

fn_ = [getenv('datapath'),'dailybar\',code,'_daily.txt'];

cDataFileIO.saveDataToTxtFile(fn_,dailybar,coldefs,'w',false);

fprintf('transfered intraday bar to daily bar on %s...\n',code);

end