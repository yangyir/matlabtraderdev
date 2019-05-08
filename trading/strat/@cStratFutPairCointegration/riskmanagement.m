function [] = riskmanagement(obj,dtnum)
%cStratFutPairCointegration
    n = obj.count;
%     return
    ismarketopen = zeros(n,1);
    volume_exist = zeros(n,1);
    instruments = obj.getinstruments;
    
    for i = 1:n
        %firstly to check whether this is in trading hours
        ismarketopen(i) = istrading(dtnum,instruments{i}.trading_hours,...
            'tradingbreak',instruments{i}.trading_break);
        
        try
            [flag,idx] = obj.helper_.book_.hasposition(instruments{i});
        catch
            flag = false;
            idx = 0;
        end
        if ~flag
            volume_exist(i) = 0;
        else
            pos = obj.helper_.book_.positions_{idx};
            volume_exist(i) = pos.position_total_ * pos.direction_;
        end
    end
    
    if sum(ismarketopen) == 0, return; end
    
    emptybook = true;
    for i = 1:n
        if volume_exist(i) ~= 0
            emptybook = false;
            break
        end
    end
    
    if emptybook, return; end
    
    npending = obj.helper_.entrustspending_.latest;
    if npending > 0
        for i = 1:npending
            try
                e = obj.helper_.entrustspending_.node(i);
                t = e.time;
                %check whether there are any pending close entrusts
                if e.offsetFlag == -1
                    if (dtnum - t)*86400 >= 10
                        obj.withdrawentrusts(e.instrumentCode);
                        obj.unwindpositions(e.instrumentCode);
                    end
                end
                %
                %check whether there are any pending open entrusts
                if e.offsetFlag == 1
                    if (dtnum - t)*86400 >= 50
                        [~,idx] = obj.hasinstrument(e.instrumentCode);
                        if idx == 1
                            obj.withdrawentrusts(e.instrumentCode);
                            obj.unwindpositions(instruments{2});
                        else
                            obj.withdrawentrusts(e.instrumentCode);
                            obj.unwindpositions(instruments{1});
                        end
                    end
                    
                end
            catch
            end
            
        end
    end
    
    
    %in case only 1 leg is unwind and the other remains, we shall unwind
    %the remaining leg with the latest tick price A.S.A.P
    if (volume_exist(1) == 0 && volume_exist(2) ~= 0)
        %scenario 1:leg2 is newly open but leg1's open entrust is pending
%         obj.withdrawentrusts(instruments{1});
%         obj.unwindpositions(instruments{2});
        return
    end
    
    if (volume_exist(1) ~= 0 && volume_exist(2) == 0)
%         obj.withdrawentrusts(instruments{2});
%         obj.unwindpositions(instruments{1});
        return
    end
    
    if volume_exist(1) ~= 0 && volume_exist(2) ~= 0
        runningpnlmat = obj.helper_.calcpnl('mdefut',obj.mde_fut_);
        runningpnlscalar = sum(sum(runningpnlmat));
        if runningpnlscalar >= 300
            obj.unwindpositions(instruments{1});
            obj.unwindpositions(instruments{2});
        end
    end
    
    
    
    
end