function signals = gensignals_futmultiwr(strategy)
%cStratFutMultiWR
    signals = cell(size(strategy.count,1),1);
    instruments = strategy.getinstruments;

    for i = 1:strategy.count
        try
            calcsignalflag = strategy.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag = 0;
            msg = ['error:%s:getcalcsignalflag:',class(strategy),e.message,'\n'];
            fprintf(msg);
            if strcmpi(strategy.onerror_,'stop'), strategy.stop; end
        end
        %
        if ~calcsignalflag
            signals{i,1} = {};
        else
            wrmode = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','wrmode');
            overbought = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','overbought');
            oversold = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','oversold');
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
               'propname','samplefreq');
            lengthofperiod = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','numofperiod');
            includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','includelastcandle');
            
            ti = strategy.mde_fut_.calc_technical_indicators(instruments{i});
            %
            if strcmpi(wrmode,'classic')
                %note:in mode 'classic', we generate signal based on WR, i.e.
                %sell if WR is above overbought and buy if WR is below oversold
                if ~isempty(ti), strategy.wr_(i) = ti{1}(1); end
                %
                if strategy.wr_(i) <= oversold
                    signals{i,1} = struct('name','williamsr',...
                        'instrument',instruments{i},...
                        'frequency',samplefreqstr,...
                        'lengthofperiod',lengthofperiod,...
                        'direction',1,...
                        'highesthigh',ti{1}(2),...
                        'lowestlow',ti{1}(3),...
                        'wrmode',wrmode);
                elseif strategy.wr_(i) >= overbought
                    signals{i,1} = struct('name','williamsr',...
                        'instrument',instruments{i},...
                        'frequency',samplefreqstr,...
                        'lengthofperiod',lengthofperiod,...
                        'direction',-1,...
                        'highesthigh',ti{1}(2),...
                        'lowestlow',ti{1}(3),...
                        'wrmode',wrmode);
                else
                    signals{i,1} = {};
                end
                %
            elseif strcmpi(wrmode,'reverse1') || strcmpi(wrmode,'reverse2') || strcmpi(wrmode,'follow')
                if strcmpi(wrmode,'reverse1') 
                %note:in mode 'reverse1', we generate signals based on the
                %previous max and min prices of the selected period, i.e.
                %we sell at the previous max (plus specified bid spread);
                %and buy at the previous min (minus specified offer spread)
                %here the latest candle are included to avoid price jump
                    [maxpx_last,~,maxcandle] = strategy.getmaxnperiods(instruments{i},'IncludeLastCandle',includelastcandle);
                    [minpx_last,~,mincandle] = strategy.getminnperiods(instruments{i},'IncludeLastCandle',includelastcandle);
                elseif strcmpi(wrmode,'reverse2')
                %note in mode 'reverse2', we generate signals based on the
                %candle which contains either the latest max or min prices
                %then we try to open 1)long once the latest price
                %breaches above the highest of that candle or 2)short once the
                %lastest price breaches below the lowest of that candle   
                    [maxpx_last,~,maxcandle] = strategy.getmaxnperiods(instruments{i},'IncludeLastCandle',includelastcandle);
                    [minpx_last,~,mincandle] = strategy.getminnperiods(instruments{i},'IncludeLastCandle',includelastcandle);
                elseif strcmpi(wrmode,'follow')
                %note in mode 'follow', we generate signals based on the
                %candle which contains either the latest max or min prices
                %then we try to open 1)short once the latest price breaches
                %below the latest min price with stoploss at that candle's
                %high price or open 2)long once the latest price breaches
                %above the latest max price with stoploss at that candle's
                %low price
                    [maxpx_last,~,maxcandle] = strategy.getmaxnperiods(instruments{i},'IncludeLastCandle',includelastcandle);
                    [minpx_last,~,mincandle] = strategy.getminnperiods(instruments{i},'IncludeLastCandle',includelastcandle);
                end
                %
                firstMax = false;
                if isempty(strategy.maxnperiods_(i)) || isnan(strategy.maxnperiods_(i))
                    strategy.maxnperiods_(i) = maxpx_last;
                    firstMax = true;
                end
                   
                firstMin = false;
                if isempty(strategy.minnperiods_(i)) || isnan(strategy.minnperiods_(i))
                    strategy.minnperiods_(i) = minpx_last;
                    firstMin = true;
                end
                %refresh max and min prices
                maxpx_before = strategy.maxnperiods_(i);
                if maxpx_last > maxpx_before || maxpx_before <= 0, strategy.maxnperiods_(i) = maxpx_last;end

                minpx_before = strategy.minnperiods_(i);
                if minpx_last < minpx_before || minpx_before <= 0, strategy.minnperiods_(i) = minpx_last;end
                
                if firstMax || firstMin
                    signals{i,1} = struct('name','williamsr',...
                        'instrument',instruments{i},...
                        'frequency',samplefreqstr,...
                        'lengthofperiod',lengthofperiod,...
                        'checkflag',1,...
                        'highesthigh',maxpx_last,...
                        'lowestlow',minpx_last,...
                        'highestcandle',maxcandle,...
                        'lowestcandle',mincandle,...
                        'wrmode',wrmode);
                    continue;
                end
                %
                %note:first time set entrusts
                %IMPORTANT:shall be open entrust
                n = strategy.helper_.numberofentrusts('Offset','Open','Code',instruments{i}.code_ctp);
                if n == 0
                    signals{i,1} = struct('name','williamsr',...
                        'instrument',instruments{i},...
                        'frequency',samplefreqstr,...
                        'lengthofperiod',lengthofperiod,...
                        'checkflag',1,...
                        'highesthigh',maxpx_last,...
                        'lowestlow',minpx_last,...
                        'highestcandle',maxcandle,...
                        'lowestcandle',mincandle,...
                        'wrmode',wrmode);
                    continue;
                end
                
                if maxpx_last > maxpx_before || minpx_last < minpx_before ...
                    || maxpx_before <= 0 || minpx_before <= 0
                    signals{i,1} = struct('name','williamsr',...
                        'instrument',instruments{i},...
                        'frequency',samplefreqstr,...
                        'lengthofperiod',lengthofperiod,...
                        'checkflag',1,...
                        'highesthigh',maxpx_last,...
                        'lowestlow',minpx_last,...
                        'highestcandle',maxcandle,...
                        'lowestcandle',mincandle,...
                        'wrmode',wrmode);
                    continue;
                end
                signals{i,1} = {};
                %
            elseif strcmpi(wrmode,'all')
                error('ERROR:%s:gensignals_futmultiwr:invalid williamR mode')
            end
                        
            if strategy.printflag_
                tick = strategy.mde_fut_.getlasttick(instruments{i});
                fprintf('%s %s: trade:%4.1f; wlpr:%4.1f; high:%s; low:%s; lastclose:%s\n',...
                datestr(tick(1),'yyyy-mm-dd HH:MM:SS'),instruments{i}.code_ctp,tick(4),strategy.wr_(i),...
                num2str(ti{1}(2)),num2str(ti{1}(3)),num2str(ti{1}(4)));
            end
            
        end
    end
end
%end of gensignals_futmultiwr