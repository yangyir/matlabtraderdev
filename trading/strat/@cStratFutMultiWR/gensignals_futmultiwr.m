function signals = gensignals_futmultiwr(strategy)
%cStratFutMultiWR
    signals = cell(size(strategy.count,1),1);
    instruments = strategy.getinstruments;

    for i = 1:strategy.count
        try
            calcsignalflag = strategy.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag = 0;
            msg = ['ERROR:%s:getcalcsignalflag:',class(strategy),e.message,'\n'];
            fprintf(msg);
            if strcmpi(strategy.onerror_,'stop'), strategy.stop; end
        end
        %
        if ~calcsignalflag
            signals{i,1} = {};
        else
            wrmode = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','wrmode');
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
               'propname','samplefreq');
            lengthofperiod = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','numofperiod');
            includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','includelastcandle');
            
            if strcmpi(wrmode,'flash') && includelastcandle
                error('ERROR:%s:gensignals_futmultiwr:last candle shall be excluded with flash mode',class(obj))
            end
            
            if strcmpi(wrmode,'flashma') && includelastcandle
                error('ERROR:%s:gensignals_futmultiwr:last candle shall be excluded with flashma mode',class(obj))
            end
            
            if strcmpi(wrmode,'follow') && includelastcandle
                error('ERROR:%s:gensignals_futmultiwr:last candle shall be excluded with follow mode',class(obj))
            end
            
            ti = strategy.mde_fut_.calc_technical_indicators(instruments{i},'includeextraresults',true);
            if strcmpi(wrmode,'classic')
                maxpx_last = ti{1}(2);
                minpx_last = ti{1}(3);
                if strategy.printflag_ && strcmpi(strategy.mode_,'replay')
                    tick = strategy.mde_fut_.getlasttick(instruments{i});
                    if isempty(tick),continue;end
                    fprintf('%s %s: trade:%s; wlpr:%4.1f; high:%s; low:%s; lastclose:%s\n',...
                        datestr(tick(1),'yyyy-mm-dd HH:MM:SS'),instruments{i}.code_ctp,num2str(tick(4)),strategy.wr_(i),...
                        num2str(maxpx_last),num2str(minpx_last),num2str(ti{1}(4)));
                end
            elseif strcmpi(wrmode,'flash') || strcmpi(wrmode,'flashma')
                maxpx_last = ti{1}(2);
                minpx_last = ti{1}(3);
                maxpx_before = ti{1}(end-1);
                minpx_before = ti{1}(end);
                maxcandle = ti{3};
                mincandle = ti{4};
            elseif (strcmpi(wrmode,'reverse') || strcmpi(wrmode,'follow'))
                maxpx_last = ti{1}(2);
                minpx_last = ti{1}(3);
                maxcandle = ti{3};
                mincandle = ti{4};
                %refresh max and min prices
                maxpx_before = strategy.maxnperiods_(i);
                if maxpx_last > maxpx_before || maxpx_before <= 0, strategy.maxnperiods_(i) = maxpx_last;end

                minpx_before = strategy.minnperiods_(i);
                if minpx_last < minpx_before || minpx_before <= 0, strategy.minnperiods_(i) = minpx_last;end
                %
            elseif strcmpi(wrmode,'all')
                error('ERROR:%s:gensignals_futmultiwr:all mode not supported!!!',class(strategy))
            else
                error('ERROR:%s:gensignals_futmultiwr:unknown wr mode!!!',class(strategy))
            end
            %
            if strcmpi(wrmode,'classic')
                %note:in mode 'classic', we generate signal based on WR, i.e.
                %sell if WR is above overbought and buy if WR is below oversold
                overbought = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                    'propname','overbought');
                oversold = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                    'propname','oversold');
                if ~isempty(ti), strategy.wr_(i) = ti{1}(1); end
                %
                if strategy.wr_(i) <= oversold
                    signals{i,1} = struct('name','williamsr',...
                        'instrument',instruments{i},...
                        'frequency',samplefreqstr,...
                        'lengthofperiod',lengthofperiod,...
                        'direction',1,...
                        'highesthigh',maxpx_last,...
                        'lowestlow',minpx_last,...
                        'highestcandle',[],...
                        'lowestcandle',[],...
                        'wrmode',wrmode);
                    continue;
                end
                
                if strategy.wr_(i) >= overbought
                    signals{i,1} = struct('name','williamsr',...
                        'instrument',instruments{i},...
                        'frequency',samplefreqstr,...
                        'lengthofperiod',lengthofperiod,...
                        'direction',-1,...
                        'highesthigh',maxpx_last,...
                        'lowestlow',minpx_last,...
                        'highestcandle',[],...
                        'lowestcandle',[],...
                        'wrmode',wrmode);
                    continue;
                end
                signals{i,1} = {};
                %
            elseif strcmpi(wrmode,'reverse') || strcmpi(wrmode,'follow')
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
                signals{i,1} = {};
                %
            elseif strcmpi(wrmode,'flash') || strcmpi(wrmode,'flashma')
                candlesticks = strategy.mde_fut_.getcandles(instruments{i});
                if ~isempty(candlesticks)
                    candlesticks = candlesticks{1};
                    latesthigh = candlesticks(end,3);
                    latestlow = candlesticks(end,4);
                    %double check whether the latest high or low has breached the old ones
                    %if it has breached, we need to check again once the
                    %candle is fully poped up at a later stage
                    if latesthigh <= maxpx_last && latestlow >= minpx_last
                        isgensignal = true;
                    else
                        isgensignal = false;
                    end
                else
                    %the code reaches here is because candles not
                    %poped up yet. the signal can be generated purely
                    %based on historical data
                    isgensignal = true;
                end
                if isgensignal && (maxpx_last > maxpx_before || minpx_last < minpx_before ...
                        || maxpx_before <= 0 || minpx_before <= 0)
                    if maxpx_last > maxpx_before || maxpx_before <= 0
                        checkflag = 1;
                    elseif minpx_last < minpx_before || minpx_before <= 0
                        checkflag = -1;
                    end
                    signals{i,1} = struct('name','williamsr',...
                        'instrument',instruments{i},...
                        'frequency',samplefreqstr,...
                        'lengthofperiod',lengthofperiod,...
                        'checkflag',checkflag,...
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
                error('ERROR:%s:gensignals_futmultiwr:all mode not supported!!!',class(strategy))
            else
                error('ERROR:%s:gensignals_futmultiwr:unknown wr mode!!!',class(strategy))
            end
        end
    end
end
%end of gensignals_futmultiwr