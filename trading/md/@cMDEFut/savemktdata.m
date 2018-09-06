function [] = savemktdata(obj,varargin)
    if ~obj.fileioflag_, return; end
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
    instruments = obj.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    if isempty(obj.candles4save_)
    else 
        coldefs = {'datetime','open','high','low','close'};
        dir_ = obj.savedir_;
        if isempty(dir_), dir_ = 'C:\yangyiran\mdefut\save\';end
        try
            cd(dir_)
        catch
            mkdir(dir_);
        end
        
        for i = 1:ns
            code_ctp = instruments{i}.code_ctp;
            bd = obj.candles4save_{i}(1,1);
            dir_data_ = [dir_,'intradaybar\',code_ctp,'\'];
            try 
                cd(dir_data_);
            catch
                mkdir(dir_data_);
            end
            fn_ = [dir_data_,code_ctp,'_',datestr(bd,'yyyymmdd'),'_1m.txt'];
            cDataFileIO.saveDataToTxtFile(fn_,obj.candles4save_{i},coldefs,'w',true);
        end
        fprintf('mdefut:savemktdata on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
    end
    
    %2.we might not clear candles_ and hist_candles_ at this stage as we
    %need them for the next day trading
    

    if ~isempty(obj.ticks_)
        obj.ticks_ = {};
    end
%     if ~isempty(obj.candles_), obj.candles_ = {};end
    if ~isempty(obj.candles4save_)
        obj.candles4save_ = {};
    end
%     if ~isempty(obj.hist_candles_), obj.hist_candles_ = {};end

    if strcmpi(obj.mode_,'replay')
        try
            if strcmpi(obj.replayer_.mode_,'singleday')
                obj.stop;
            elseif strcmpi(obj.replayer_.mode_,'multiday')
                if obj.replayer_.multidayidx_ >= size(obj.replayer_.multidayfiles_,1)
                    obj.stop;
                end
            end
        catch e
            fprintf('cMDEFut:savemktdata:internal error:%s\n',e.message);
        end
        
    end
    
end