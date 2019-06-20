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
                if obj.replayer_.multidayidx_ >= size(obj.replayer_.multidayfiles_{1},1)
                    obj.stop;
                    return
                end
                %TODO:here we may extend the replay mode with mutltiple futures
                %note:20181002:finally we have capcity to cope with
                %multiple futures
                %below we first load tick data for the next business date
                multidayidx = obj.replayer_.multidayidx_;
                multidayidx = multidayidx+1;
                fns = obj.replayer_.multidayfiles_;
                for i = 1:ns
                    obj.replayer_.loadtickdata('code',instruments{i}.code_ctp,'fn',fns{i}{multidayidx});
                    if i == 1
                        obj.replay_date1_ = floor(obj.replayer_.tickdata_{i}(1,1));
                        obj.replay_date2_ = datestr(obj.replay_date1_,'yyyy-mm-dd');
                    else
                        checkdate = floor(obj.replayer_.tickdata_{i}(1,1));
                        if checkdate ~= obj.replay_date1_
                            error('cMDEFut:loadmarketdata:inconsitent tick data found on different cob dates')
                        end
                    end
                    obj.replay_idx_(i) = 0;
                end
%                 obj.replay_datetimevec_ = obj.replayer_.tickdata_{1}(:,1);
                obj.replay_count_ = 1;
                obj.replay_time1_ = obj.replay_date1_ + obj.replay_datetimevec_(obj.replay_count_)/86400;
                obj.replay_time2_ = datestr(obj.replay_time1_,'yyyy-mm-dd HH:MM:SS');
                obj.replayer_.multidayidx_ = multidayidx;
            end
        end
        fprintf('mdefut:loadmktdata on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
        obj.move2cobdate(floor(dtnum));
    end
    
    %note:the mktdata is scheduled to be loaded between 08:50am and 09:00am
    %on each trading date
    %and we shall gurantee that we have logged into MD server in the
    %realtime mode
    if strcmpi(obj.mode_,'replay'), return; end
    
    if ~obj.qms_.isconnect
        if ~isempty(obj.qms_.watcher_.ds)
            if isa(obj.qms_.watcher_.ds,'cCTP')
                countername = obj.qms_.watcher_.ds.char;
                obj.login('Connection','CTP','CounterName',countername);
                fprintf('cMDEFut:login to MD server on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
            else
                error('cMDEFut:data source not supported');
            end
        end
    end
    
end