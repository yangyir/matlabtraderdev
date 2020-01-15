function [ strikes ] = opt_getstrikes(code_underlier,spot)
    if strcmpi(code_underlier(1:2),'IF')
        %此处只针对当月或者下2个月合约
        %对当月与下2个月合约：行权价格≤2500点时，行权价格间距为25点；
        %2500点<行权价格≤5000点时，行权价格间距为50点；
        %5000点<行权价格≤10000点时，行权价格间距为100点；
        %行权价格>10000点时，行权价格间距为200点
        %
        %行权价格覆盖沪深300指数上一交易日收盘价上下浮动10%对应的价格范围
        lb = spot*0.9;
        ub = spot*1.1;
        if lb <= 2500
            k_lb = ceil(lb/25)*25;
        elseif lb > 2500 && lb <= 5000
            k_lb = ceil(lb/50)*50;
        elseif lb > 5000 && lb <= 10000
            k_lb = ceil(lb/100)*100;
        else
            k_lb = ceil(lb/1000)*1000;
        end
        %
        if ub <= 2500
            k_ub = ceil(ub/25)*25;
        elseif ub > 2500 && ub <= 5000
            k_ub = ceil(ub/50)*50;
        elseif lb > 5000 && ub <= 10000
            k_ub = ceil(ub/100)*100;
        else
            k_ub = ceil(ub/1000)*1000;
        end
        %
        strikes = zeros(20,1);
        strikes(1) = k_lb;
        k = k_lb;
        count = 1;
        while k <= k_ub;
            if k < 2500
                k = k + 25;
            elseif k >= 2500 && k < 5000
                k = k + 50;
            elseif k >= 5000 && k < 10000
                k = k + 100;
            else
                k = k + 200;
            end
            count = count + 1;
            strikes(count) = k;
        end
        strikes = strikes(1:count);
    elseif strcmpi(code_underlier(1:2),'au')
        
    end



end

