function [] = print(obj,varargin)
%cMDEFut    
    if ~obj.printflag_, return; end
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    time = p.Results.Time;
      
    if strcmpi(obj.status_,'sleep')
        fprintf('%s:mdefut sleeps......\n',datestr(time,'yyyy-mm-dd HH:MM:SS'));
    elseif strcmpi(obj.status_,'working')
        isanyinstrumenttrading = false;
        n = obj.qms_.instruments_.count;
        if strcmpi(obj.mode_,'replay')
            time = obj.replay_time1_;
        end
        for i = 1:n
            dtnum_open = obj.datenum_open_{i};
            dtnum_close = obj.datenum_close_{i};
            for j = 1:size(dtnum_open,1)
                if time >= dtnum_open(j) && time <= dtnum_close(j)
                    isanyinstrumenttrading = true;
                    break
                end
            end
        end
        if isanyinstrumenttrading
            obj.printmarket;            
        end
    end
    
end