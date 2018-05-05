function [] = updateentrustsandbook(obj)
%cOps
    n = obj.entrusts_.latest;
    % in case there is no placed entrusts at all, we just return
    if n == 0, return; end
    
    npending = obj.entrustspending_.latest;
    % in case there is no pending entrusts, we return as well
    if npending == 0, return; end
    
    warning('off');
    entrusts = EntrustArray;
    for i = 1:npending
        e = obj.entrustspending_.node(i);
        if strcmpi(obj.mode_,'realtime')
            f0 = obj.book_.counter_.queryEntrust(e);
            f1 = e.is_entrust_closed;
            f2 = e.dealVolume > 0;
        elseif strcmpi(obj.mode_,'replay')
            codestr = e.instrumentCode;
            isopt = isoptchar(codestr);
            if isopt
                ticks = obj.mdeopt_.getlasttick(codestr);
            else
                ticks = obj.mdefut_.getlasttick(codestr);
            end
            f0 = 1;
            if e.direction == 1
                f1 = ticks(2) <= e.price;
            else
                f1 = ticks(2) >= e.price;
            end
            f2 = f1;
            e.dealVolume = e.volume;
        end
        if f0 && f1 && f2
            entrusts.push(e);
            fprintf('executed entrust: %d......\n',e.entrustNo);
            % this entrust is fully placed and we shall update the book
            obj.book_.addpositions('code',e.instrumentCode,'price',e.price,...
                'volume',e.direction*e.dealVolume,'time',e.time,...
                'closetodayflag',e.closetodayFlag);
        elseif f0 && f1 && ~f2
            % this entrust is canceled
            fprintf('cancelled entrust: %d......\n',e.entrustNo);
            entrusts.push(e);
        end
    end
    
    nf = entrusts.latest;
    for i = 1:nf
        npending = obj.entrustspending_.latest;
        for j = npending:-1:1
            if obj.entrustspending_.node(j).entrustNo == entrusts.node(i).entrustNo
                rmidx = j;
                obj.entrustspending_.removeByIndex(rmidx);
                break
            end
        end
        nfinished = obj.entrustsfinished_.latest;
        flag = false;
        for j = 1:nfinished
            if obj.entrustsfinished_.node(j).entrustNo == entrusts.node(i).entrustNo
                flag = true;
                break
            end
        end
        if ~flag
            obj.entrustsfinished_.push(e);
        end
    end
end