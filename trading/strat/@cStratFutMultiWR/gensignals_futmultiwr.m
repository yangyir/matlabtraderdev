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
            ti = strategy.mde_fut_.calc_technical_indicators(instruments{i});

            if ~isempty(ti)
                strategy.wr_(i) = ti{1}(1);
            end
            
            if strategy.printflag_
                tick = strategy.mde_fut_.getlasttick(instruments{i});
                fprintf('%s %s: trade:%4.1f; wlpr:%4.1f; high:%s; low:%s; lastclose:%s\n',...
                datestr(tick(1),'yyyy-mm-dd HH:MM:SS'),instruments{i}.code_ctp,tick(4),strategy.wr_(i),...
                num2str(ti{1}(2)),num2str(ti{1}(3)),num2str(ti{1}(4)));
            end
            
            overbought = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','overbought');
            oversold = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','oversold');
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
               'propname','samplefreq');
            
            lengthofperiod = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,...
                'propname','numofperiod');
         
            if strategy.wr_(i) <= oversold
                signals{i,1} = struct('name','williamsr',...
                    'instrument',instruments{i},...
                    'frequency',samplefreqstr,...
                    'lengthofperiod',lengthofperiod,...
                    'direction',1,...
                    'highesthigh',ti{1}(2),...
                    'lowestlow',ti{1}(3));
            elseif strategy.wr_(i) >= overbought
                signals{i,1} = struct(...
                    'instrument',instruments{i},...
                    'frequency',samplefreqstr,...
                    'lengthofperiod',lengthofperiod,...
                    'direction',-1,...
                    'highesthigh',ti{1}(2),...
                    'lowestlow',ti{1}(3));
            else
                signals{i,1} = {};
            end
        end
    end
end
%end of gensignals_futmultiwr