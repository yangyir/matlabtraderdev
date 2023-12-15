function data = savetickfromths(ths,code_ctp,varargin)
    data = [];
    if ~isa(ths,'cTHS')
        error('savetickfromths:invalid ths instance input')
    end
    
    if ~ischar(code_ctp)
        error('savetickfromths:invalid CTP code input')
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
    dir_data_ = [dir_,'ticks\',code_ctp,'\'];
    
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
    
    try
        f = code2instrument(code_ctp);
    catch
        f = [];
    end
    
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
                data = ths.tickdata(f,datestr(bds(i),'yyyy-mm-dd'),datestr(bds(i),'yyyy-mm-dd'));
            else
                fn_ = [dir_data_,code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_tick.txt'];
                data = ths.tickdata(code_ctp,datestr(bds(i),'yyyy-mm-dd'),datestr(bds(i),'yyyy-mm-dd'));
            end
            if isempty(data)
                fprintf('savetickfromths:no tick data returned on %s...\n',datestr(bds(i),'yyyy-mm-dd'));
                continue;
            else
                cDataFileIO.saveDataToTxtFile(fn_,data,coldefs,permission,usedatestr);
            end
        end
    end
    
end