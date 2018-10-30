function signals = gensignals_futmultiwrplusbatman(strategy)
%note:both the highest high price and lowest low price for the given length
%of period are computed for all the registered instrument. If either the
%highest high price or the lowest low price changes, we replace it/them
%with the lastest one
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
            %note;here we are inline with the backtesting process, i.e. we
            %exclude the last candle stick, which might not be fully feeded
            %yet, to compute the highest high and lowest low
            highestpx_last = strategy.gethighnperiods(instruments{i});
            lowestpx_last = strategy.getlownperiods(instruments{i});
                    
            firstH = false;
            if isempty(strategy.highnperiods_(i)) || isnan(strategy.highnperiods_(i))
                strategy.highnperiods_(i) = highestpx_last;
                firstH = true;
            end
                    
            firstL = false;
            if isempty(strategy.lownperiods_(i)) || isnan(strategy.lownperiods_(i))
                strategy.lownperiods_(i) = lowestpx_last;
                firstL = true;
            end
                    
            highestpx_before = strategy.highnperiods_(i);
            if highestpx_last > highestpx_before, strategy.highnperiods_(i) = highestpx_last;end

            lowestpx_before = strategy.lownperiods_(i);
            if lowestpx_last < lowestpx_before, strategy.lownperiods_(i) = lowestpx_last;end
                    
            try
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','SampleFreq');
            catch e
                %note:the code is executed here because
                %1)either riskcontrols are not initiated at all
                %2)or riskcontrols for such instrument is not set
                fprintf('%s\n',e.message);
                continue
            end
                    
%             samplefreq = str2double(samplefreqstr(1:end-1));
            lengthofperiod = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','numofperiod');
                    
            %note:first time set highest and lowest
            if firstH || firstL
                signals{i,1} = struct('name','williamsr',...
                    'instrument',instruments{i},...
                    'frequency',samplefreqstr,...
                    'lengthofperiod',lengthofperiod,...
                    'checkflag',1,...
                    'highesthigh',highestpx_last,...
                    'lowestlow',lowestpx_last);
                continue;
            end
                    
            %note:first time set entrusts
            %IMPORTANT:shall be open entrust
            n = strategy.helper_.numberofentrusts('Offset','Open');
            if n == 0
                signals{i,1} = struct('name','williamsr',...
                    'instrument',instruments{i},...
                    'frequency',samplefreqstr,...
                    'lengthofperiod',lengthofperiod,...
                    'checkflag',1,...
                    'highesthigh',highestpx_last,...
                    'lowestlow',lowestpx_last);
                continue;
            end
                    
            if highestpx_last > highestpx_before || lowestpx_last < lowestpx_before
                signals{i,1} = struct('name','williamsr',...
                    'instrument',instruments{i},...
                    'frequency',samplefreqstr,...
                    'lengthofperiod',lengthofperiod,...
                    'checkflag',1,...
                    'highesthigh',highestpx_last,...
                    'lowestlow',lowestpx_last);
                continue;
            end
                    
            signals{i,1} = {};
        end                        
    end
    
end