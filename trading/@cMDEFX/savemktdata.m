function [] = savemktdata(macrocn,varargin)
%cMacroCN
    dir_ = [getenv('DATAPATH'),'macrochina\'];
    lastbd = getlastbusinessdate;
    %
    fn_cash_ = 'dr007_daily.txt';
    try
        d = cDataFileIO.loadDataFromTxtFile([dir_,fn_cash_]);
        lastobd = d(end,1);
    catch
        d = [];
        lastobd = datenum('2000-01-01','yyyy-mm-dd');
    end
    
    if lastobd < lastbd
        [wdata,~,~,wtime] = macrocn.w_.ds_.wsd(macrocn.codes_cash_,...
            'open,high,low,close',lastobd,lastbd);
        idx = wtime > lastobd;
        dnew = [wtime(idx),wdata(idx,:)];
        if ~isempty(dnew)
            data = [d;dnew];
            cDataFileIO.saveDataToTxtFile([dir_,fn_cash_],data,{'date','open','high','low','close'},'w',false);
        end
    end
    %
    nfut = size(macrocn.codes_govtbondfut_,1);
    for i = 1:nfut
        fn_i = [lower(macrocn.codes_govtbondfut_{i}(1:end-4)),'_daily.txt'];
        try
            d = cDataFileIO.loadDataFromTxtFile([dir_,fn_i]);
            lastobd = d(end,1);
        catch
            d = [];
            lastobd = datenum('2000-01-01','yyyy-mm-dd');
        end
        if lastobd < lastbd
            [wdata,~,~,wtime] = macrocn.w_.ds_.wsd(macrocn.codes_govtbondfut_{i},...
                'open,high,low,close',lastobd,lastbd);
            idx = wtime > lastobd;
            dnew = [wtime(idx),wdata(idx,:)];
            if ~isempty(dnew)
                data = [d;dnew];
                cDataFileIO.saveDataToTxtFile([dir_,fn_i],data,{'date','open','high','low','close'},'w',false);
            end
        end
    end
    %
    nbond = size(macrocn.codes_govtbond_,1);
    fns = {'tb01y_daily';'tb03y_daily';'tb05y_daily';'tb07y_daily';'tb10y_daily';'tb30y_daily'};
    for i = 1:nbond
        fn_i = [fns{i},'.txt'];
        try
            d = cDataFileIO.loadDataFromTxtFile([dir_,fn_i]);
            lastobd = d(end,1);
        catch
            d = [];
            lastobd = datenum('2000-01-01','yyyy-mm-dd');
        end
        if lastobd < lastbd
            [wdata,~,~,wtime] = macrocn.w_.ds_.wsd(macrocn.codes_govtbond_{i},...
                'open,high,low,close',lastobd,lastbd);
            idx = wtime > lastobd;
            dnew = [wtime(idx),wdata(idx,:)];
            if ~isempty(dnew)
                data = [d;dnew];
                cDataFileIO.saveDataToTxtFile([dir_,fn_i],data,{'date','open','high','low','close'},'w',false);
            end
        end
    end
    %
    fn_fx_ = 'usdcnh_daily.txt';
    try
        d = cDataFileIO.loadDataFromTxtFile([dir_,fn_fx_]);
        lastobd = d(end,1);
    catch
        d = [];
        lastobd = datenum('2000-01-01','yyyy-mm-dd');
    end
    if lastobd < lastbd
        [wdata,~,~,wtime] = macrocn.w_.ds_.wsd(macrocn.codes_fx_,...
            'open,high,low,close',lastobd,lastbd);
        idx = wtime > lastobd;
        dnew = [wtime(idx),wdata(idx,:)];
        if ~isempty(dnew)
            data = [d;dnew];
            cDataFileIO.saveDataToTxtFile([dir_,fn_fx_],data,{'date','open','high','low','close'},'w',false);
        end
    end
    %
    fn_eqindex_ = 'csi300_daily.txt';
    try
        d = cDataFileIO.loadDataFromTxtFile([dir_,fn_eqindex_]);
        lastobd = d(end,1);
    catch
        d = [];
        lastobd = datenum('2000-01-01','yyyy-mm-dd');
    end
    if lastobd < lastbd
        [wdata,~,~,wtime] = macrocn.w_.ds_.wsd(macrocn.codes_eqindex_,...
            'open,high,low,close',lastobd,lastbd);
        idx = wtime > lastobd;
        dnew = [wtime(idx),wdata(idx,:)];
        if ~isempty(dnew)
            data = [d;dnew];
            cDataFileIO.saveDataToTxtFile([dir_,fn_eqindex_],data,{'date','open','high','low','close'},'w',false);
        end
    end
        
    fprintf('cMacroCN:savemktdata:done!!!\n');
        

end

