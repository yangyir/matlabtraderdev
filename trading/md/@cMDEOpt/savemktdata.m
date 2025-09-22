function [] = savemktdata(mdeopt,varargin)
    if ~mdeopt.fileioflag_, return; end
    %note:the mktdata is scheduled to be saved between 02:30am and 02:40am
    %on each trading date
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    dtnum = p.Results.Time;
    
    %1.we first check whether candles4save_ is empty or not
    %empty candles4save_ indicates either candles have been saved or they
    %haven't poped up yet
    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    if isempty(mdeopt.candles4save_)
    else 
        coldefs = {'datetime','open','high','low','close'};
        dir_ = mdeopt.savedir_;
        if isempty(dir_), dir_ = 'C:\yangyiran\mdeopt\save\';end
        try
            cd(dir_)
        catch
            mkdir(dir_);
        end
        
        for i = 1:ns
            code_ctp = instruments{i}.code_ctp;
            bd = mdeopt.candles4save_{i}(1,1);
            dir_data_ = [dir_,'intradaybar\',code_ctp,'\'];
            try 
                cd(dir_data_);
            catch
                mkdir(dir_data_);
            end
            fn_ = [dir_data_,code_ctp,'_',datestr(bd,'yyyymmdd'),'_1m.txt'];
            cDataFileIO.saveDataToTxtFile(fn_,mdeopt.candles4save_{i},coldefs,'w',true);
        end
        fprintf('cMDEOpt:savemktdata on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
        %
        if mdeopt.savetick_
            coldefs = {'datetime','trade'};
            for i = 1:ns
                code_ctp = instruments{i}.code_ctp;
                bd = mdeopt.candles4save_{i}(1,1);
                dir_data_ = [dir_,'ticks\',code_ctp,'\'];
                try
                    cd(dir_data_);
                catch
                    mkdir(dir_data_);
                end
                fn_ = [dir_data_,code_ctp,'_',datestr(bd,'yyyymmdd'),'_tick.txt'];
                ticks = mdeopt.ticks_{i}(1:mdeopt.ticks_count_(i),:);
                cDataFileIO.saveDataToTxtFile(fn_,ticks,coldefs,'w',true);
            end
            fprintf('cMDEOpt:savemktdata(ticks) on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
        end
    end
    
    %2.we might not clear candles_ and hist_candles_ at this stage as we
    %need them for the next day trading
    
    if ~isempty(mdeopt.ticks_)
        mdeopt.ticks_ = {};
    end
      
    if ~isempty(mdeopt.ticksquick_)
        mdeopt.ticksquick_ = [];
    end
    
    if ~isempty(mdeopt.candles4save_)
        mdeopt.candles4save_ = {};
    end

    if strcmpi(mdeopt.mode_,'replay')
        try
            if strcmpi(mdeopt.replayer_.mode_,'singleday')
                mdeopt.stop;
            elseif strcmpi(mdeopt.replayer_.mode_,'multiday')
                if mdeopt.replayer_.multidayidx_ >= size(mdeopt.replayer_.multidayfiles_{1},1)
                    mdeopt.stop;
                end
            end
        catch e
            fprintf('cMDEOpt:savemktdata:internal error:%s\n',e.message);
        end
        
    end
    %
    %
    %note:the mktdata is scheduled to be saved between 02:30am and 02:40am
    %on each trading date
    %we shall logoff the MD server after the mktdata is saved
    if strcmpi(mdeopt.mode_,'realtime')
        if mdeopt.qms_.isconnect
            mdeopt.logoff;
            fprintf('cMDEOpt:logoff from MD on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
        end
    end
    
end