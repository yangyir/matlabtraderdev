function [] = printmarket(obj)
    instruments = obj.qms_.instruments_.getinstrument;
    if strcmpi(obj.mode_,'realtime') || strcmpi(obj.mode_,'demo')
        try
            quotes = obj.qms_.getquote;
        catch
            fprintf('error:cMDEFut:printmarket:no quote returns...\n');
            return
        end
        
        n = size(quotes,1);
        if n == 0
            fprintf('error:cMDEFut:printmarket:no quote returns...\n');
            return;
        end
        
        %todo:
        %enrich printed information with last close and change
        rowcount = 0;
        for i = 1:n
            code = quotes{i}.code_ctp;
            bid = quotes{i}.bid1;
            if bid > 1e6
                bid = NaN;
            elseif bid == 0
                bid = obj.lastclose_(i);
            end
            ask = quotes{i}.ask1;
            if ask > 1e6
                ask = NaN;
            elseif ask == 0
                ask = obj.lastclose_(i);
            end
            lasttrade = quotes{i}.last_trade;
            if lasttrade > 1e6
                lasttrade = NaN;
            elseif lasttrade == 0
                lasttrade = obj.lastclose_(i);
            end
            rowcount = rowcount + 1;
            if rowcount == 1
                fprintf('\nlatest market quotes:\n');
                if ~isempty(obj.hist_candles_) && ~isempty(obj.hist_candles_{i})
                    fprintf('%10s%8s%8s%8s%9s%11s%10s%10s%10s%8s%8s%10s%10s%10s%10s%10s\n',...
                        'contract','bid','ask','close','change','time','wr','max','min','bs','ss','levelup','leveldn','jaw','teeth','lips');
                    dataformat = '%10s%8s%8s%8s%8.1f%%%11s%10.1f%10s%10s%8s%8s%10s%10s%10.2f%10.2f%10.2f\n';
                else
                    fprintf('%10s%8s%8s%8s%9s%11s\n',...
                        'contract','bid','ask','close','change','time');
                    dataformat = '%10s%8s%8s%8s%8.1f%%%11s\n';
                end
            end
            timet = datestr(quotes{i}.update_time1,'HH:MM:SS');
            delta = ((lasttrade/obj.lastclose_(i))-1)*100;
            instr = code2instrument(code);

            if ~isempty(obj.hist_candles_) && ~isempty(obj.hist_candles_{i})
%                 wrinfo = obj.calc_wr_(instr,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                [buysetup,sellsetup,levelup,leveldn] = obj.calc_tdsq_(instr,'IncludeLastCandle',1,'RemoveLimitPrice',1);
%             [macdvec,sig] = obj.calc_macd_(instr,'IncludeLastCandle',1);
                [jaw,teeth,lips] = obj.calc_alligator_(instr,'includelastcandle',1,'RemoveLimitPrice',1);
                [~,~,HH,LL] = obj.calc_fractal_(instr,'includelastcandle',1,'RemoveLimitPrice',1);
            
                if obj.candle_freq_(i) == 1440 && ~isempty(strfind(instruments{i}.asset_name,'eqindex'))
                    adj = obj.hist_candles_{i}(end,5)/obj.lastclose_(i);
                    bid = bid*adj; 
                    ask = ask*adj; 
                end
                fprintf(dataformat,code,num2str(bid),num2str(ask),num2str(obj.lastclose_(i)),...
                    delta,timet,...
                    NaN,num2str(HH(end)),num2str(LL(end)),...
                    num2str(buysetup(end)),num2str(sellsetup(end)),num2str(levelup(end)),num2str(leveldn(end)),...
                    jaw(end),teeth(end),lips(end));
            else
                fprintf(dataformat,code,num2str(bid),num2str(ask),num2str(obj.lastclose_(i)),...
                    delta,timet);
            end
        end
        %
        if obj.showfigures_, mde_fin_plot(obj);end
        %
    else
        %replay mode
        
        n = size(instruments,1);
        if n == 0
            fprintf('error:cMDEFut:printmarket:no quote returns...\n');
            return;
        end
        
        if isempty(obj.ticksquick_)
            return
        end
        
        rowcount = 0;
        for i = 1:n
            code = instruments{i}.code_ctp;
            count = obj.ticks_count_(i);
            if count > 0
                lasttick = obj.ticksquick_(i,:);
            else
                lasttick = [];
            end
            if isempty(lasttick), continue;end
            rowcount = rowcount + 1;
            if rowcount == 1
                fprintf('\nlatest market quotes (replay):\n');
                if ~isempty(obj.hist_candles_) && ~isempty(obj.hist_candles_{i})
                    fprintf('%10s%8s%8s%8s%9s%11s%10s%10s%10s%8s%8s%10s%10s%10s%10s%10s\n',...
                        'contract','bid','ask','close','change','time','wr','max','min','bs','ss','levelup','leveldn','jaw','teeth','lips');
                    dataformat = '%10s%8s%8s%8s%8.1f%%%11s%10.1f%10s%10s%8s%8s%10s%10s%10.2f%10.2f%10.2f\n';
                else
                    fprintf('%10s%8s%8s%8s%9s%11s\n',...
                        'contract','bid','ask','close','change','time');
                    dataformat = '%10s%8s%8s%8s%8.1f%%%11s\n';
                end
            end
            lasttrade = lasttick(4);
            timet = datestr(lasttick(1),'HH:MM:SS');
            
            delta = ((lasttrade/obj.lastclose_(i))-1)*100;
            if obj.candle_freq_(i) == 1440 && ~isempty(strfind(instruments{i}.asset_name,'eqindex'))
                adj = obj.hist_candles_{i}(end,5)/obj.lastclose_(i);
                lasttrade = lasttrade*adj; 
            end
            
            if ~isempty(obj.hist_candles_) && ~isempty(obj.hist_candles_{i})
%                 wrinfo = obj.calc_wr_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
                [buysetup,sellsetup,levelup,leveldn] = obj.calc_tdsq_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
                [jaw,teeth,lips] = obj.calc_alligator_(instruments{i},'includelastcandle',1,'RemoveLimitPrice',1);
                [~,~,HH,LL] = obj.calc_fractal_(instruments{i},'includelastcandle',1,'RemoveLimitPrice',1);
                fprintf(dataformat,code,num2str(lasttrade),num2str(lasttrade),num2str(obj.hist_candles_{i}(end,5)),...
                    delta,timet,...
                    NaN,num2str(HH(end)),num2str(LL(end)),...
                    num2str(buysetup(end)),num2str(sellsetup(end)),num2str(levelup(end)),num2str(leveldn(end)),...
                    jaw(end),teeth(end),lips(end));
            else
                fprintf(dataformat,code,num2str(lasttrade),num2str(lasttrade),num2str(obj.lastclose_(i)),...
                    delta,timet);
            end
        end
        
        if obj.showfigures_, mde_fin_plot(obj);end
        
    end

end

