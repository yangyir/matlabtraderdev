function [] = rebalance(obj)
%cStratFutPairCointegration
%     instruments = obj.getinstruments;
    flag = false;

    ndata = size(obj.data_,1);
    M = obj.lookbackperiod_;
    N = obj.rebalanceperiod_;
    if mod(ndata-obj.lastrebalanceindex_,N) == 0
        flag = true;
    end
    
    if flag
%         obj.lastrebalancedatetime1_ = obj.nextrebalancedatetime1_;
        obj.lastrebalancedatetime1_ = obj.data_(end,1);
        [h,~,~,~,reg1] = egcitest(obj.data_(end-M+1:end,2:3));
        if h ~= 0
            obj.cointegrationparams_ = reg1;
        else
            obj.cointegrationparams_ = {};
        end
        fprintf('rebalanced at %s\n',obj.lastrebalancedatetime2_);
    end
    
end