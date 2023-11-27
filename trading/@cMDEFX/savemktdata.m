function [] = savemktdata(mdefx,varargin)
%cmdefx
    dir_ = [getenv('DATAPATH'),'globalmacro\'];
    
    t = now;
    wday = weekday(t);
    %find the previous weekday, regardless of any holiday calendar as fx is
    %traded worldwide
    if wday >= 3 && wday <= 7
        lastbd = floor(t);
    elseif wday == 2
        lastbd = floor(t)-3;
    elseif wday == 1
        lastbd = floor(t)-2;
    end
    %
    nfx = size(mdefx.codes_fx_,1);
    for i = 1:nfx
        fn_i = [lower(mdefx.codes_fx_{i}(1:end-3)),'_daily.txt'];
        try
            d = cDataFileIO.loadDataFromTxtFile([dir_,fn_i]);
            lastobd = d(end,1);
        catch
            d = [];
            lastobd = datenum('2000-01-01','yyyy-mm-dd');
        end
        if lastobd < lastbd
            [wdata,~,~,wtime] = mdefx.w_.ds_.wsd(mdefx.codes_fx_{i},...
                'open,high,low,close',lastobd,lastbd,'Days=Weekdays');
            idx = wtime > lastobd;
            dnew = [wtime(idx),wdata(idx,:)];
            if ~isempty(dnew)
                data = [d;dnew];
                cDataFileIO.saveDataToTxtFile([dir_,fn_i],data,{'date','open','high','low','close'},'w',false);
            end
        end
    end
    %
    fprintf('cmdefx:savemktdata:done!!!\n');
        

end

