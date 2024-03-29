function [tblb_data_combo,tbls_data_combo] = fractal_comdtyweeklyreport(varargin)
    % fractal utility function to automatically report the performance of
    % futures
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('fromdate',{},@(x) validateattributes(x,{'char','numeric'},{},'','fromdate'));
    p.addParameter('usefractalupdate',1,@isnumeric);
    p.addParameter('usefibonacci',1,@isnumeric);
    p.addParameter('frequency','intraday',@ischar);
    p.addParameter('todate',{},@(x) validateattributes(x,{'char','numeric'},{},'','todate'));
    p.parse(varargin{:});
    checkfreq = p.Results.frequency;
    usefractalupdateflag = p.Results.usefractalupdate;
    usefibonacciflag = p.Results.usefibonacci;
    dt1 = p.Results.fromdate;
    dt2 = p.Results.todate;
    if isempty(dt2)
        dt2 = getlastbusinessdate;
    else
        dt2 = getlastbusinessdate(datenum(dt2,'yyyy-mm-dd'));
    end
    activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
    futfile = ['activefutures_',datestr(dt2,'yyyymmdd'),'.txt'];
    futlist = cDataFileIO.loadDataFromTxtFile([activefuturesdir,futfile]);
    
    if strcmpi(checkfreq,'intraday')
        dt2 = dateadd(dt2,'1b');
    end
    
    nfut = size(futlist,1);
    tblsb_data = cell(nfut,1);
    tblss_data = cell(nfut,1);
    
    parfor i = 1:nfut
        if strcmpi(futlist{i}(1:2),'ZC'), continue;end
        if strcmpi(futlist{i}(1:2),'jd'), continue;end
        
        [~,tblb_data,~,tbls_data,~,~,~,~,~] = fractal_gettradesummary(futlist{i},...
            'frequency',checkfreq,...
            'direction','both',...
            'usefractalupdate',usefractalupdateflag,...
            'usefibonacci',usefibonacciflag,...
            'fromdate',dt1,...
            'todate',dt2);
        tblsb_data{i} = tblb_data;
        tblss_data{i} = tbls_data;
    end
    
    for i = 1:nfut
        if strcmpi(futlist{i}(1:2),'ZC'), continue;end
        if strcmpi(futlist{i}(1:2),'jd'), continue;end
        
        if i == 1
            tblb_data_combo = tblsb_data{i};
            tbls_data_combo = tblss_data{i};
        else
            tempnew = [tblb_data_combo;tblsb_data{i}];
            tblb_data_combo = tempnew;
            tempnew = [tbls_data_combo;tblss_data{i}];
            tbls_data_combo = tempnew;
        end
    end
    
    
end