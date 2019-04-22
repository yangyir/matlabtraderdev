function [signals] = gensignals_futpaircointegration(strategy)
%cStratFutPairCointegration
    instruments = strategy.getinstruments;
    
    refindex = strategy.referencelegindex_;
    
    calcsignalflag = strategy.getcalcsignalflag(instruments{refindex});

    if ~calcsignalflag
        signals = {};
        return
    end
    
    %update obj data
    strategy.updatapairdata;
    % check whether rebalancing is required
    strategy.rebalance;
    
    if isempty(strategy.cointegrationparams_)
        signals = {};
        return
    end
    
    lasttick1 = strategy.mde_fut_.getlasttick(instruments{1});
    lasttick2 = strategy.mde_fut_.getlasttick(instruments{2});
    
    if isempty(lasttick1) || isempty(lasttick2)
        signals = {};
        return
    end
    
    params = strategy.cointegrationparams_;
    indicator = lasttick1(4) - (params.coeff(1) + params.coeff(2) * lasttick2(4));
    indicator = indicator / params.RMSE;
    
    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{1}.code_ctp,'propname','samplefreq');
    
    if indicator > strategy.upperbound_
        signals = cell(2,1);
        fprintf('%s:indicator value:%4.1f:leg1 overbought:(-)leg1 at %s and (+)leg2 at %s\n',datestr(lasttick1(1),'HH:MM'),indicator,num2str(lasttick1(4)),num2str(lasttick2(4)))
        signals{1,1} = struct('name','paircointegration',...
                        'instrument',instruments{1},...
                        'frequency',samplefreqstr,...
                        'direction',-1,...
                        'volume',params.coeff(2));
        signals{2,1} = struct('name','paircointegration',...
                        'instrument',instruments{2},...
                        'frequency',samplefreqstr,...
                        'direction',1,...
                        'volume',1);
        return
    elseif indicator < strategy.lowerbound_
        signals = cell(2,1);
        fprintf('%s:indicator value:%4.1f:leg1 oversold:(+)leg1 at %s and (-)leg2 at %s\n',datestr(lasttick1(1),'HH:MM'),indicator,num2str(lasttick1(4)),num2str(lasttick2(4)))
        signals{1,1} = struct('name','paircointegration',...
                        'instrument',instruments{1},...
                        'frequency',samplefreqstr,...
                        'direction',1,...
                        'volume',params.coeff(2));
        signals{2,1} = struct('name','paircointegration',...
                        'instrument',instruments{2},...
                        'frequency',samplefreqstr,...
                        'direction',-1,...
                        'volume',1);
        return
    else
        fprintf('%s:indicator value:%4.1f\n',datestr(lasttick1(1),'HH:MM'),indicator);
        signals = {};
        return
    end
        
end

