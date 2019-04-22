function [] = rebalance(obj)
%cStratFutPairCointegration
    instruments = obj.getinstruments;
    flag = false;
    for i = 1:obj.count
        tick = obj.mde_fut_.getlasttick(instruments{i});
        if isempty(tick)
            continue
        end
        ticktime = tick(1);
        if ticktime > obj.nextrebalancedatetime1_
            flag = true;
            break
        end
    end
    
    if flag
        obj.lastrebalancedatetime1_ = obj.nextrebalancedatetime1_;
        M = obj.lookbackperiod_;
        [h,~,~,~,reg1] = egcitest(obj.data_(end-M+1:end,2:3));
        if h ~= 0
            obj.cointegrationparams_ = reg1;
        else
            obj.cointegrationparams_ = {};
        end
        fprintf('rebalanced at %s\n',obj.lastrebalancedatetime2_);
    `    end
    
end