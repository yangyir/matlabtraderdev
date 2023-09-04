function savedailybarfromths(ths,code_ctp,override)
%utility function to save data from THS
%for options and futures traded in SHFE,DCE,CZC and CFE only
if ~isa(ths,'cTHS')
    error('savedailybarfromths:invalid THS instance input')
end

if ~ischar(code_ctp)
    error('savedailybarfromths:invalid CTP code input')
end

if nargin < 3
    override = false;
end

if override
    error('savedailybarfromths:override true is not supported now as THS access is limited...')
end

f = code2instrument(code_ctp);
fn = [getenv('DATAPATH'),'info_futures\',code_ctp,'_info.txt'];
if isa(f,'cFX')
    fn_dailybar = [getenv('DATAPATH'),'globalmacro\',code_ctp,'_daily.txt'];
else
    fn_dailybar = [getenv('DATAPATH'),'dailybar\',code_ctp,'_daily.txt'];
end
if isempty(f.contract_size)
    f.init(ths);
    f.saveinfo(fn);
end

lbd = getlastbusinessdate;
if isa(f,'cFX')
    dt2 = min(lbd,today-1);
else
    dt2 = min(lbd,f.last_trade_date1);
end

try
    dailybar_old = cDataFileIO.loadDataFromTxtFile(fn_dailybar);
    dt1 = dailybar_old(end,1);
catch
    %fn_dailybar not found
    dailybar_old = [];
    dt1 = f.first_trade_date1;
end

if dt1 < dt2
    if ~isempty(dailybar_old)
       if size(dailybar_old,2) == 5
           dailybar_new = ths.history(f,'open;high;low;close',datestr(dt1,'yyyy-mm-dd'),datestr(dt2,'yyyy-mm-dd'));
       else
           dailybar_new = ths.history(f,'open;high;low;close;volume',datestr(dt1,'yyyy-mm-dd'),datestr(dt2,'yyyy-mm-dd'));
       end
    else
        dailybar_new = ths.history(f,'open;high;low;close;volume',datestr(dt1,'yyyy-mm-dd'),datestr(dt2,'yyyy-mm-dd'));
    end
else
    dailybar_new = [];
end

if isempty(dailybar_old)
    dailybar = dailybar_new;
else
    if ~isempty(dailybar_new)
        lastdt = dailybar_old(end,1);
        idx = dailybar_new(:,1) > lastdt;
        ncols = size(dailybar_new,2);
        dailybar = [dailybar_old(:,1:ncols);dailybar_new(idx,:)];
    else
        dailybar = dailybar_old;
    end
end

ncols = size(dailybar,2);
if ncols > 5
    titledefs = {'date','open','high','low','close','volume'};
else
    titledefs = {'date','open','high','low','close'};
end

if ~isempty(dailybar_new)
    cDataFileIO.saveDataToTxtFile(fn_dailybar,dailybar(:,1:length(titledefs)),titledefs,'w',false);
end

fprintf('done daily bar with %s\n',code_ctp);
end