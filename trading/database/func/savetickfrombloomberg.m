function savetickfrombloomberg(bbg,code_ctp,varargin)
    if ~isa(bbg,'cBloomberg')
        error('savetickfrombloomberg:invalid bloomberg instance input')
    end
    
    if ~ischar(code_ctp)
        error('savetickfrombloomberg;invalid CTP code input')
    end
    
    p = inputParser;
    p.addParameter('Override',false,@islogical);
    p.addParameter('FromDate','',@ischar);
    p.addParameter('ToDate','',@ischar);
    p.parse(varargin{:});
    override = p.Results.Override;
    fromDate = p.Results.FromDate;
    toDate = p.Results.ToDate;
    
    dir_ = getenv('DATAPATH');
    dir_info_ = [dir_,'info_futures\'];
    dir_data_ = [dir_,'ticks\',code_ctp,'\'];
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
        f.init(bbg.ds_);
        f.saveinfo(fn_info_);
    end
    
    files = dir(dir_data_);
    nfiles = size(files,1);
    
    coldefs = {'datetime','trade','volume'};
    permission = 'w';
    usedatestr = true;
    startdate = fromDate;
    lbd = getlastbusinessdate;
    plbd = businessdate(lbd,-1);
    enddate = min(lbd,datenum(toDate));
    bds = gendates('fromdate',startdate,'todate',enddate);
    
    for i = 1:size(bds,1)
        fn_ = [f.code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_tick.txt'];
        %first check whether fn_ exists
        flag = false;
        for j = 1:nfiles
            if strcmpi(fn_,files(j).name)
                flag = true;
                break
            end
        end
    
        if ~flag || (flag && override) || bds(i) == lbd || bds(i) == plbd
            fn_ = [dir_data_,f.code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_tick.txt'];
            data = bbg.tickdata(f,datestr(bds(i),'yyyy-mm-dd'),datestr(bds(i),'yyyy-mm-dd'));
            if isempty(data), continue; end
            cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
        end
    end
    
    
    
end

