function [] = print(mdeopt,varargin)
%cMDEOpt
    if ~mdeopt.printflag_, return; end
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    time = p.Results.Time;
    if strcmpi(mdeopt.status_,'sleep')
        fprintf('%s:mdeopt sleeps......\n',datestr(time,'yyyy-mm-dd HH:MM:SS'));
    elseif strcmpi(mdeopt.status_,'working')
        isanyinstrumenttrading = false;
        dtnum_open = mdeopt.datenum_open_;
        dtnum_close = mdeopt.datenum_close_;
        for j = 1:size(dtnum_open,1)
            if time >= dtnum_open(j) && time <= dtnum_close(j)
                isanyinstrumenttrading = true;
                break
            end
        end
        if isanyinstrumenttrading
            mdeopt.displaypivottable;
        else
%             mdeopt.displaypivottable;
        end
        
    end
    
    
        
    
end