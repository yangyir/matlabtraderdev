function [] = loadmktdata(obj,varargin)
    if ~obj.fileioflag_, return; end
    %note:the mktdata is scheduled to be loaded between 08:50am and 09:00am
    %on each trading date
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    dtnum = p.Results.Time;
    
    if ~isempty(obj.candles4save_)
        %do nothing if the candles4save_
    else
        instruments = obj.qms_.instruments_.getinstrument;
        ns = size(instruments,1);
        if ns == 0, return; end
        if strcmpi(obj.mode_,'replay')
            if strcmpi(obj.replayer_.mode_,'multiday')
                if obj.replayer_.multidayidx_ >= size(obj.replayer_.multidayfiles_,1)
                    obj.stop;
                    return
                end
                %TODO:here we may extend the replay mode with mutltiple futures
                
                %below we first load tick data for the next business date
                multidayidx = obj.replayer_.multidayidx_;
                multidayidx = multidayidx+1;
                fns = obj.replayer_.multidayfiles_;
                obj.replayer_.loadtickdata('code',instruments{1}.code_ctp,'fn',fns{multidayidx});
                obj.replay_date1_ = floor(obj.replayer_.tickdata_{1}(1,1));
                obj.replay_date2_ = datestr(obj.replay_date1_,'yyyy-mm-dd');
                obj.replay_datetimevec_ = obj.replayer_.tickdata_{1}(:,1);
                obj.replay_count_ = 1;
                obj.replayer_.multidayidx_ = multidayidx;
            end
        end
        fprintf('mdefut:loadmktdata on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
        obj.move2cobdate(floor(dtnum));
    end
    
end