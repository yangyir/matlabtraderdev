function data = tickdata(obj,instrument,startdate,enddate)
%some sanity check first
    if ~ischar(startdate), error('cLocal:tickdata:startdate must be char'); end
    if ~ischar(enddate), error('cLocal:tickdata:enddate must be char'); end
    
    if isa(instrument,'cFutures')
        code_ctp = instrument.code_ctp;
        dir_ = [obj.ds_,'ticks\',code_ctp,'\'];

        bds = gendates('fromdate',datenum(startdate,'yyyy-mm-dd'),...
            'todate',datenum(enddate,'yyyy-mm-dd'));
        n = size(bds,1);
        if n == 0
            fprintf('cLocal:tickdata:no business dates found between input startdate and enddate\n');
            data = [];
            return
        elseif n == 1
            fullfn_ = [dir_,code_ctp,'_',datestr(bds(1),'yyyymmdd'),'_tick.txt'];
            try
                data = cDataFileIO.loadDataFromTxtFile(fullfn_);
            catch e
                fprintf([e.message,'\n'])
            end
        else
            data_ = cell(n,1);
            for i = 1:n
                fullfn_ = [dir_,code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_tick.txt'];
                try
                    data_{i,1} = cDataFileIO.loadDataFromTxtFile(fullfn_);
                catch e
                    fprintf([e.message,'\n'])
                end
            end
            data = cell2mat(data_);
        end
    else
        classname = class(instrument);
        error(['cLocal:tickdata:not implemented for class ',...
            classname])
    end
    
end