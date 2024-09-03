function data = savetickfromwind(w,code_ctp,varargin)
    data = [];
    if ~isa(w,'cWind')
        error('savetickfromwind:invalid wind instance input')
    end
    
    if ~ischar(code_ctp)
        error('savetickfromwind;invalid CTP code input')
    end
    
    p = inputParser;
    p.addParameter('Override',false,@islogical);
    p.addParameter('FromDate','',@ischar);
    p.addParameter('ToDate','',@ischar);
    p.addParameter('UseLastBusinessDate',true,@islogical);
    p.parse(varargin{:});
    override = p.Results.Override;
    fromDate = p.Results.FromDate;
    toDate = p.Results.ToDate;
    uselastbd = p.Results.UseLastBusinessDate;
    
    dir_ = getenv('DATAPATH');
    dir_info_ = [dir_,'info_futures\'];
    dir_data_ = [dir_,'ticks\',code_ctp,'\'];
    try
        cd(dir_data_);
    catch
        mkdir(dir_data_);
    end
    
    %first try to load information from local drive
    try
        f = cFutures(code_ctp);
        fn_info_ = [dir_info_,code_ctp,'_info.txt'];
        f.loadinfo(fn_info_);
        if isempty(f.contract_size)
            %not loaded
            f.init(w);
            f.saveinfo(fn_info_);
        end
    catch
        %shall be a stock or fund here
        f = [];
    end
    
    files = dir(dir_data_);
    nfiles = size(files,1);
    
    coldefs = {'datetime','trade','volume'};
    permission = 'w';
    usedatestr = true;
    startdate = fromDate;
    lbd = getlastbusinessdate;
    plbd = businessdate(lbd,-1);
    if uselastbd
        enddate = min(lbd,datenum(toDate));
    else
        enddate = toDate;
    end
    bds = gendates('fromdate',startdate,'todate',enddate);
    
    for i = 1:size(bds,1)
        if ~isempty(f)
            fn_ = [f.code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_tick.txt'];
        else
            fn_ = [code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_tick.txt'];
        end
        %first check whether fn_ exists
        flag = false;
        for j = 1:nfiles
            if strcmpi(fn_,files(j).name)
                flag = true;
                break
            end
        end
    
        if ~flag || (flag && override) || bds(i) == lbd || bds(i) == plbd         
            if ~isempty(f)
                fn_ = [dir_data_,f.code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_tick.txt'];
                data = w.tickdata(f,datestr(bds(i),'yyyy-mm-dd'),datestr(bds(i),'yyyy-mm-dd'));
            else
                fn_ = [dir_data_,code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_tick.txt'];
                data = w.tickdata(code_ctp,datestr(bds(i),'yyyy-mm-dd'),datestr(bds(i),'yyyy-mm-dd'));
            end
            if isempty(data)
                fprintf('savetickfromwind:no tick data returned on %s...\n',datestr(bds(i),'yyyy-mm-dd'));
                continue; 
            else
                cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
            end
        end
    end
    
    
    
end

