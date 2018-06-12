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
            %the entrust is always placed in 'replay' mode
            f0 = 1;
            if e.direction == 1
                f1 = ticks(2) <= e.price;
            else
                f1 = ticks(2) >= e.price;
            end
            f2 = f1;
            if f1
                %once the entrust is executed
                e.dealVolume = e.volume;
                e.dealPrice = e.price;
                e.complete_time_ = ticks(1);
            end
        end
        if f0 && f1 && f2
            entrusts.push(e);
            if strcmpi(obj.mode_,'realtime')
                %todo:check queryEntrust to finish complete_time_
                e.complete_time_ = now;
                fprintf('executed entrust: %d at %s......\n',e.entrustNo,datestr(e.complete_time_,'yyyy-mm-dd HH:MM:SS'));
            elseif strcmpi(obj.mode_,'replay')
                fprintf('executed entrust: %d at %s......\n',e.entrustNo,datestr(e.complete_time_,'yyyy-mm-dd HH:MM:SS'));
            end
            % this entrust is fully placed and we shall update the book
            obj.book_.addpositions('code',e.instrumentCode,'price',e.price,...
                'volume',e.direction*e.dealVolume,'time',e.time,...
                'closetodayflag',e.closetodayFlag);
            % update trades as well
            if e.offsetFlag == 1
                %note:not sure whether e.complete_time works in realtime
                %mode and we need to revise this
                trade = cTradeOpen('id',e.entrustNo,...
                    'countername',obj.book_.counter_.char,...
                    'bookname',obj.book_.bookname_,...
                    'code',e.instrumentCode,...
                    'opentime',e.complete_time_,...
                    'openprice',e.price,...
                    'opendirection',e.direction,...
                    'targetprice',e.direction*inf,...
                    'stoplossprice',-e.direction*inf,...
                    'riskmanagementmethod','standard');
                obj.trades_.push(trade);
            end
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