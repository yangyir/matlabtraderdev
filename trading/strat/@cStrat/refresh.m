function [] = refresh(strategy)
    try
        strategy.updategreeks;
    catch e
        msg = ['error:cStrat:updategreeks:',e.message,'\n'];
        fprintf(msg);
    end
    %
%     try
%         strategy.updateentrusts;
%     catch e
%         msg = ['error:cStrat:updateentrusts:',e.message,'\n'];
%         fprintf(msg);
%     end
    try
        strategy.helper_.refresh;
    catch e
        msg = ['error:cStrat:cOps:refresh:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        strategy.riskmanagement(now);
    catch e
        msg = ['error:cStrat:riskmanagment:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        signals = strategy.gensignals;
    catch e
        msg = ['error:cStrat:gensiignals:',e.message,'\n'];
        fprintf(msg);
    end
    %
    try
        strategy.autoplacenewentrusts(signals);
    catch e
        msg = ['error:cStrat:autoplacenewentrusts:',e.message,'\n'];
        fprintf(msg);
    end
end