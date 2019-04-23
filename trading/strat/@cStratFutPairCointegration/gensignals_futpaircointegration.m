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
    
    d_ = strategy.data_(end,:);
    params = strategy.cointegrationparams_;
    indicator = d_(2) - (params.coeff(1) + params.coeff(2) * d_(3));
    indicator = indicator / params.RMSE;
    
    reftimestr = datestr(d_(1),'HH:MM');
       
    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{1}.code_ctp,'propname','samplefreq');
        
    if indicator > strategy.upperbound_
        signals = cell(2,1);
        fprintf('%s:indicator value:%4.2f:(-)leg1 and (+)leg2\n',reftimestr,indicator)
        signals{1,1} = struct('name','paircointegration',...
                        'instrument',instruments{1},...
                        'frequency',samplefreqstr,...
                        'direction',-1,...
                        'coeff',params.coeff,...
                        'rmse',params.RMSE);
        signals{2,1} = struct('name','paircointegration',...
                        'instrument',instruments{2},...
                        'frequency',samplefreqstr,...
                        'direction',1,...
                        'coeff',params.coeff,...
                        'rmse',params.RMSE);
        return
    elseif indicator < strategy.lowerbound_
        signals = cell(2,1);
        fprintf('%s:indicator value:%4.2f:(+)leg1 and (-)leg2\n',reftimestr,indicator)
        signals{1,1} = struct('name','paircointegration',...
                        'instrument',instruments{1},...
                        'frequency',samplefreqstr,...
                        'direction',1,...
                        'coeff',params.coeff,...
                        'rmse',params.RMSE);
        signals{2,1} = struct('name','paircointegration',...
                        'instrument',instruments{2},...
                        'frequency',samplefreqstr,...
                        'direction',-1,...
                        'coeff',params.coeff,...
                        'rmse',params.RMSE);
        return
    else
        fprintf('%s:indicator value:%4.2f\n',reftimestr,indicator);
        signals = {};
        return
    end
        
end

