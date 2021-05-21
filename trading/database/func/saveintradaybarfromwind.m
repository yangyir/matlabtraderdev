function saveintradaybarfromwind(w,code_ctp,override,dt1,dt2)

if ~isa(w,'cWind')
    error('saveintradaybarfromwind;invalid wind instance input')
end

if ~ischar(code_ctp)
    error('saveintradaybarfromwind;invalid CTP code input')
end

if nargin < 3
    override = false;
    dt1 = [];
    dt2 = [];
end

dir_ = getenv('DATAPATH');
dir_info_ = [dir_,'info_futures\'];
dir_data_ = [dir_,'intradaybar\',code_ctp,'\'];
try
    cd(dir_data_);
catch
    mkdir(dir_data_);
end


%first try to load information from local drive
f = cFutures(code_ctp);
fn_info_ = [dir_info_,code_ctp,'_info.txt'];
f.loadinfo(fn_info_);
if isempty(f.contract_size)
    %not loaded
    f.init(w);
    f.saveinfo(fn_info_);
end

sessions = regexp(f.trading_hours,';','split');
nsession = length(sessions);
if nsession > 2
    if strcmpi(sessions{3},'21:00-01:00') || strcmpi(sessions{3},'21:00-02:30')
        midnighttrading = true;
    else
        midnighttrading = false;
    end
else
    midnighttrading = false;
end

files = dir(dir_data_);
nfiles = size(files,1);

%2018-05-27
%comments:we need to fix a bug in case the futures trades after mid-night
%and before 9:00am

coldefs = {'datetime','open','high','low','close'};
permission = 'w';
usedatestr = true;
if isempty(dt1)
    startdate = f.first_trade_date1;
else
    startdate = dt1;
end
lbd = getlastbusinessdate;
plbd = businessdate(lbd,-1);
if isempty(dt2)
    enddate = min(lbd,f.last_trade_date1);
else
    enddate = dt2;
end
bds = gendates('fromdate',startdate,'todate',enddate);

for i = 1:size(bds,1)
    bd = datestr(bds(i),'yyyy-mm-dd');
    fn_ = [f.code_ctp,'_',datestr(bd,'yyyymmdd'),'_1m.txt'];
    %first check whether fn_ exists
    flag = false;
    for j = 1:nfiles
        if strcmpi(fn_,files(j).name)
            flag = true;
            break
        end
    end
    if ~flag || (flag && override) || bds(i) == lbd || bds(i) == plbd
        %20180527:we will always update data for the last businessdate
        fn_ = [dir_data_,f.code_ctp,'_',datestr(bd,'yyyymmdd'),'_1m.txt'];
        if flag && (bds(i) == lbd || bds(i) == plbd)
            delete(fn_);
        end
        data = w.intradaybar(f,bd,bd,1,'trade');
        check = sum(data(:,2:end),2);
        idx = ~isnan(check);
        data = data(idx,:);
        if isempty(data), continue; end
        cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
    end
    %
    %20180527:bug fix as follow
    if weekday(bds(i)) == 6 && midnighttrading
        %as of friday
        nextsaturday = datestr(bds(i)+1,'yyyy-mm-dd');
        fn_ = [f.code_ctp,'_',datestr(nextsaturday,'yyyymmdd'),'_1m.txt'];
        %first check whether fn_ exists
        flag = false;
        for j = 1:nfiles
            if strcmpi(fn_,files(j).name)
                flag = true;
                break
            end
        end
        if ~flag || (flag && override)
            if today >= datenum(nextsaturday,'yyyy-mm-dd')
                fn_ = [dir_data_,f.code_ctp,'_',datestr(nextsaturday,'yyyymmdd'),'_1m.txt'];
                data = w.intradaybar(f,nextsaturday,datestr(bds(i)+2,'yyyy-mm-dd'),1,'trade');
                check = sum(data(:,2:end),2);
                idx = ~isnan(check);
                data = data(idx,:);
                if isempty(data), continue; end
                cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
            end
        end
    end
    %20180527
    %also we need to check whether on the last business date to update
    %evening ticks, which will be replaced on the next update date
    if weekday(bds(i)) ~= 6 && bds(i) == lbd && midnighttrading
        nextbd = datestr(bds(i)+1,'yyyy-mm-dd');
        if today >= datenum(nextbd,'yyyy-mm-dd')
            fn_ = [dir_data_,f.code_ctp,'_',datestr(nextbd,'yyyymmdd'),'_1m.txt'];
            data = w.intradaybar(f,nextbd,datestr(bds(i)+2,'yyyy-mm-dd'),1,'trade');
            check = sum(data(:,2:end),2);
            idx = ~isnan(check);
            data = data(idx,:);
            if isempty(data), continue; end
            cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
        end
    end
    
end

fprintf('done with %s\n',code_ctp);

end

