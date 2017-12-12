function [] = registerinstrument(strategy,instrument)
    %registerinstrument of superclass
    registerinstrument@cStrat(strategy,instrument);

    %numofperiods_
    if isempty(strategy.numofperiods_)
        strategy.numofperiods_ = 144*ones(strategy.count,1); 
        params = struct('numofperiods',144);
        strategy.setparameters(instrument,params);
    else
        if size(strategy.numofperiods_) < strategy.count
            strategy.numofperiods_ = [strategy.numofperiods_;144];
            params = struct('numofperiods',144);
            strategy.setparameters(instrument,params);
        end
    end

    %tradingfreq_
    if isempty(strategy.tradingfreq_)
        strategy.tradingfreq_ = ones(strategy.count,1);
        strategy.settradingfreq(instrument,1);
    else
        if size(strategy.tradingfreq_) < strategy.count
            strategy.tradingfreq_ = [strategy.tradingfreq_;1];
            strategy.settradingfreq(instrument,1);
        end
    end

    %overbought_
    if isempty(strategy.overbought_)
        strategy.overbought_ = zeros(strategy.count,1);
    else
        if size(strategy.overbought_) < strategy.count
            strategy.overbought_ = [strategy.overbought_;0];
        end
    end

    %oversold_
    if isempty(strategy.oversold_)
        strategy.oversold_ = -100*ones(strategy.count,1);
    else
        if size(strategy.oversold_) < strategy.count
            strategy.oversold_ = [strategy.oversold_;-100];
        end
    end

    %william %r
    if isempty(strategy.wr_)
        strategy.wr_ = NaN(strategy.count,1);
    else
        if size(strategy.wr_) < strategy.count
            strategy.wr_ = [strategy.wr_;NaN];
        end
    end

%     %baseunits
%     if isempty(strategy.baseunits_)
%         strategy.baseunits_ = ones(strategy.count,1);
%     else
%         if size(strategy.baseunits_) < strategy.count
%             strategy.baseunits_ = [strategy.baseunits_;1];
%         end
%     end
% 
%     %maxunits
%     if isempty(strategy.maxunits_)
%         strategy.maxunits_ = 16*ones(strategy.count,1);
%     else
%         if size(strategy.maxunits_) < strategy.count
%             strategy.maxunits_ = [strategy.maxunits_;16];
%         end
%     end
% 
%     %executionperbucket
%     if isempty(strategy.executionperbucket_)
%         strategy.executionperbucket_ = zeros(strategy.count,1);
%     else
%         if size(strategy.executionperbucket_) < strategy.count
%             strategy.executionperbucket_ = [strategy.executionperbucket_;0];
%         end
%     end
% 
%     %maxexecutionperbucket
%     if isempty(strategy.maxexecutionperbucket_)
%         strategy.maxexecutionperbucket_ = ones(strategy.count,1);
%     else
%         if size(strategy.maxexecutionperbucket_) < strategy.count
%             strategy.maxexecutionperbucket_ = [strategy.maxexecutionperbucket_;1];
%         end
%     end
% 
%     %executionbucketnumber
%     if isempty(strategy.executionbucketnumber_)
%         strategy.executionbucketnumber_ = zeros(strategy.count,1);
%     else
%         if size(strategy.executionbucketnumber_) < strategy.count
%             strategy.executionbucketnumber_ = [strategy.executionbucketnumber_;0];
%         end
%     end

end
%end of registerinstrument