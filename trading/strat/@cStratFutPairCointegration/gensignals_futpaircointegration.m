function [signals] = gensignals_futpaircointegration(strategy)
%cStratFutPairCointegration
    instruments = strategy.getinstruments;
    
    refindex = strategy.referencelegindex_;
    
    calcsignalflag = strategy.getcalcsignalflag(instruments{refindex});
    
    processlasttick = false;
    
    if ~calcsignalflag
        nbuckets = length(strategy.mde_fut_.candles_{refindex});
        calcsignalbucket = strategy.getcalcsignalbucket(instruments{refindex});
        if calcsignalbucket < nbuckets
            signals = {};
            return
        end
        if calcsignalbucket == nbuckets
            tick = strategy.mde_fut_.getlasttick(instruments{refindex});
            ticktime = tick(1);
            mktclosetime = strategy.mde_fut_.datenum_close_{refindex}(end,1);
            if (mktclosetime-ticktime)*86400 > 1
                signals = {};
                return
            else
                %special treatment for the last ticks around the market
                %close
                if strcmpi(strategy.mode_,'realtime')
                    dtnum = now;
                elseif strcmpi(strategy.mode_,'replay')
                    dtnum = strategy.getreplaytime;
                end
                if dtnum >= mktclosetime
                    signals = {};
                    return
                end                
                processlasttick = true;
            end
        end
    end
    
    %update obj data
    if ~processlasttick
        strategy.updatapairdata;
    else
        K1 = strategy.mde_fut_.getlastcandle(instruments{1});
        K2 = strategy.mde_fut_.getlastcandle(instruments{2});
        K1 = K1{1};K2 = K2{1};
        temp = [K2(1),K1(5),K2(5)];
        lastdt = strategy.data_(end,1);
        if abs(lastdt-temp(1)) > 1e-8
            strategy.data_ = [strategy.data_;temp];
        else
            strategy.data_(end,:) = temp;
        end
    end
    % check whether rebalancing is required
    strategy.rebalance;
    
    d_ = strategy.data_(end,:);
    reftimestr = datestr(d_(1),'HH:MM');
    params = strategy.cointegrationparams_;
    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{1}.code_ctp,'propname','samplefreq');
        
    if isempty(params)
        signals = cell(2,1);
        signals{1,1} = struct('name','paircointegration',...
                        'instrument',instruments{1},...
                        'frequency',samplefreqstr,...
                        'direction',0,...
                        'coeff',[],...
                        'rmse',[]);
        signals{2,1} = struct('name','paircointegration',...
                        'instrument',instruments{2},...
                        'frequency',samplefreqstr,...
                        'direction',0,...
                        'coeff',[],...
                        'rmse',[]);
        fprintf('%s:no cointegration\n',reftimestr);
        return
    end
    
    %lines of code below guarantee the indicator calculation are inline
    %with the backtest in which the last candle close is used
    indicator = d_(2) - (params.coeff(1) + params.coeff(2) * d_(3));
    indicator = indicator / params.RMSE;
%     fprintf('%s:indicator:%5.2f; coeff:%4.1f\n',reftimestr,indicator,params.coeff(2));
    
    %note:I guess we would prefer to use the tick price rather than the
    %last candle close to compute the indicator again in real-trading
    tick1 = strategy.mde_fut_.getlasttick(instruments{1});bid1 = tick1(2);ask1 = tick1(3);
    tick2 = strategy.mde_fut_.getlasttick(instruments{2});bid2 = tick2(2);ask2 = tick2(3);
    
    indicator1 = (bid1 - (params.coeff(1) + params.coeff(2) * ask2))/params.RMSE;
    indicator2 = (ask1 - (params.coeff(1) + params.coeff(2) * bid2))/params.RMSE;
    
    fprintf('%s:indicator:%5.2f; coeff:%4.1f; indicator1:%5.2f; indicator2:%5.2f\n',reftimestr,indicator,params.coeff(2),indicator1,indicator2);
%     if indicator > strategy.upperbound_
    if indicator1 > strategy.upperbound_
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
%     elseif indicator < strategy.lowerbound_
    elseif indicator2 < strategy.lowerbound_
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
    elseif indicator2 < strategy.upperbound_ && indicator1 > strategy.lowerbound_ 
        signals = cell(2,1);
        signals{1,1} = struct('name','paircointegration',...
                        'instrument',instruments{1},...
                        'frequency',samplefreqstr,...
                        'direction',0,...
                        'coeff',params.coeff,...
                        'rmse',params.RMSE);
        signals{2,1} = struct('name','paircointegration',...
                        'instrument',instruments{2},...
                        'frequency',samplefreqstr,...
                        'direction',0,...
                        'coeff',params.coeff,...
                        'rmse',params.RMSE);
        return
    else
        signals = {};
        return
    end
        
end

