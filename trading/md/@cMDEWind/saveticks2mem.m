function [] = saveticks2mem(obj)
%cMDEWind
    if ~obj.conn_.isconnect, return; end
    if size(obj.codeswind_,1) == 0, return;end
    
    codestr = [obj.codeswind_{1},','];
    for i = 2:size(obj.codeswind_,1)
        temp = [codestr,obj.codeswind_{i},','];
        codestr = temp;
    end
    codestr = codestr(1:end-1);
    
    if strcmpi(obj.mode_,'realtime') || strcmpi(obj.mode_,'demo')
        rtdata = obj.conn_.realtime(codestr,'rt_time,rt_bid1,rt_ask1,rt_latest');
        for i = 1:size(obj.codes_,1)
            count = obj.ticks_count_(i)+1;
            tstr = num2str(rtdata(i,1));
            if length(tstr) < 6
                ticktime_i = [datestr(today,'yyyy-mm-dd'),' 0',tstr(1),':',tstr(2:3),':',tstr(4:5)];
            else
                ticktime_i = [datestr(today,'yyyy-mm-dd'),' ',tstr(1:2),':',tstr(3:4),':',tstr(5:6)];
            end
            obj.ticksquick_(i,1) = datenum(ticktime_i,'yyyy-mm-dd HH:MM:SS');
            obj.ticksquick_(i,2) = rtdata(i,2);
            obj.ticksquick_(i,3) = rtdata(i,3);
            obj.ticksquick_(i,4) = rtdata(i,4);
            obj.ticks_count_(i) = count;
        end
    elseif strcmpi(obj.mode_,'replay')
        for i = 1:ns
            idx = obj.replay_idx_(i);
            if idx == 0, continue; end
            count = obj.ticks_count_(i) + 1;
            obj.ticksquick_(i,1) = obj.replayer_.tickdata_{i}(idx,1);
            obj.ticksquick_(i,2:4) = obj.replayer_.tickdata_{i}(idx,2);
            obj.ticks_count_(i) = count;
        end
    end
end
%end of saveticks2mem