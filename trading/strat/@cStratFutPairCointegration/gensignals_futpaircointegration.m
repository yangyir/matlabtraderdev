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
    
    d_ = strategy.data_(end,:);
    reftimestr = datestr(d_(1),'HH:MM');
    params = strategy.cointegrationparams_;
    
    if isempty(params)
        signals = {};
        fprintf('%s:no cointegration\n',reftimestr);
        return
    end
    
    indicator = d_(2) - (params.coeff(1) + params.coeff(2) * d_(3));
    indicator = indicator / params.RMSE;
    
    fprintf('%s:indicator:%5.2f; coeff:%4.1f\n',reftimestr,indicator,params.coeff(2));
    
    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{1}.code_ctp,'propname','samplefreq');
        
    if indicator > strategy.upperbound_
        signals = cell(2,1);
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
        signals = {};
        return
    end
        
end

