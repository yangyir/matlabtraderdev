function [] = printunderlier(mdeopt)
% a cMDEOpt function

    instruments = mdeopt.qms_.instruments_.getinstrument;
    if strcmpi(mdeopt.mode_,'realtime') || strcmpi(mdeopt.mode_,'demo')
        try
            quotes = obj.qms_.getquote;
        catch
            fprintf('ERROR:%s:printunderlier:no quote returns...\n',class(mdeopt));
            return
        end
        
        n = size(quotes,1);
        if n == 0
            fprintf('ERROR:%s:printunderlier:no quote returns...\n',class(mdeopt));
            return;
        end
        
        %todo:
        %enrich printed information with last close and change
        
        code = mdeopt.underlier_.code_ctp;
        bid = quotes{1}.bid1;
        if bid > 1e6
            bid = NaN;
        elseif bid == 0
            bid = mdeopt.lastclose_(1);
        end
        ask = quotes{1}.ask1;
        if ask > 1e6
            ask = NaN;
        elseif ask == 0
            ask = mdeopt.lastclose_(1);
        end
        lasttrade = quotes{1}.last_trade;
        if lasttrade > 1e6
            lasttrade = NaN;
        elseif lasttrade == 0
            lasttrade = mdeopt.lastclose_(1);
        end
        %
        fprintf('\nlatest market quotes:\n');
        if ~isempty(mdeopt.hist_candles_) && ~isempty(mdeopt.hist_candles_{1})
            fprintf('%10s%8s%8s%8s%9s%11s%10s%10s%8s%8s%10s%10s%10s%10s%10s\n',...
                'contract','bid','ask','close','change','time','max','min','bs','ss','levelup','leveldn','jaw','teeth','lips');
            dataformat = '%10s%8s%8s%8s%8.1f%%%11s%10s%10s%8s%8s%10s%10s%10.2f%10.2f%10.2f\n';
        else
            fprintf('%10s%8s%8s%8s%9s%11s\n',...
                'contract','bid','ask','close','change','time');
            dataformat = '%10s%8s%8s%8s%8.1f%%%11s\n';
        end
        
        timet = datestr(quotes{1}.update_time1,'HH:MM:SS');
        delta = ((lasttrade/obj.lastclose_(1))-1)*100;
        
        
        if ~isempty(mdeopt.hist_candles_) && ~isempty(mdeopt.hist_candles_{1})
            
            freq = mdeopt.getcandlefreq(mdeopt.underlier_);
            if freq == 1440
                if hour(quotes{1}.update_time1) == 14 && minute(quotes{1}.update_time1) == 59
                    includelastk = 1;
                else
                    includelastk = 0;
                end
            else
                includelastk = 1;
            end
            [buysetup,sellsetup,levelup,leveldn] = mdeopt.calc_tdsq_('IncludeLastCandle',includelastk,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdeopt.calc_alligator_('includelastcandle',includelastk,'RemoveLimitPrice',1);
            [~,~,HH,LL] = mdeopt.calc_fractal_('includelastcandle',includelastk,'RemoveLimitPrice',1);
            
            
            fprintf(dataformat,code,num2str(bid),num2str(ask),num2str(mdeopt.lastclose_(1)),...
                delta,timet,...
                num2str(HH(end)),num2str(LL(end)),...
                num2str(buysetup(end)),num2str(sellsetup(end)),num2str(levelup(end)),num2str(leveldn(end)),...
                jaw(end),teeth(end),lips(end));
        else
            fprintf(dataformat,code,num2str(bid),num2str(ask),num2str(mdeopt.lastclose_(1)),...
                delta,timet);
        end
        %
        if mdeopt.showfigures_, mdeopt_fin_plot(mdeopt);end
        %
    else
        %replay mode
        n = size(instruments,1);
        if n == 0
            fprintf('ERROR:%s:printmarket:no quote returns...\n',class(mdeopt));
            return;
        end
        
        if isempty(mdeopt.ticksquick_)
            return
        end
        
        
        code = mdeopt.underlier_.code_ctp;
        count = mdeopt.ticks_count_(1);
        if count > 0
            lasttick = mdeopt.ticksquick_(1,:);
        else
            lasttick = [];
        end
        if isempty(lasttick), return;end
        
        fprintf('\nlatest market quotes (replay):\n');
        if ~isempty(mdeopt.hist_candles_) && ~isempty(mdeopt.hist_candles_{1})
            fprintf('%10s%8s%8s%8s%9s%11s%10s%10s%8s%8s%10s%10s%10s%10s%10s\n',...
                'contract','bid','ask','close','change','time','max','min','bs','ss','levelup','leveldn','jaw','teeth','lips');
            dataformat = '%10s%8s%8s%8s%8.1f%%%11s%10s%10s%8s%8s%10s%10s%10.2f%10.2f%10.2f\n';
        else
            fprintf('%10s%8s%8s%8s%9s%11s\n',...
                'contract','bid','ask','close','change','time');
            dataformat = '%10s%8s%8s%8s%8.1f%%%11s\n';
        end
        
        lasttrade = lasttick(4);
        timet = datestr(lasttick(1),'HH:MM:SS');
        
        delta = ((lasttrade/mdeopt.lastclose_(1))-1)*100;
        
        if ~isempty(mdeopt.hist_candles_) && ~isempty(mdeopt.hist_candles_{1})
            
            freq = mdeopt.getcandlefreq(mdeopt.underlier_);
            if freq == 1440
                if hour(lasttick(1)) == 14 && minute(lasttick(1)) == 59
                    includelastk = 1;
                else
                    includelastk = 0;
                end
            else
                includelastk = 1;
            end
            [buysetup,sellsetup,levelup,leveldn] = mdeopt.calc_tdsq_('IncludeLastCandle',includelastk,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdeopt.calc_alligator_('includelastcandle',includelastk,'RemoveLimitPrice',1);
            [~,~,HH,LL] = mdeopt.calc_fractal_('includelastcandle',includelastk,'RemoveLimitPrice',1);
            fprintf(dataformat,code,num2str(lasttrade),num2str(lasttrade),num2str(mdeopt.lastclose_(1)),...
                delta,timet,...
                num2str(HH(end)),num2str(LL(end)),...
                num2str(buysetup(end)),num2str(sellsetup(end)),num2str(levelup(end)),num2str(leveldn(end)),...
                jaw(end),teeth(end),lips(end));
        else
            fprintf(dataformat,code,num2str(lasttrade),num2str(lasttrade),num2str(obj.lastclose_(1)),...
                delta,timet);
        end
    
        
        if mdeopt.showfigures_, mdeopt_fin_plot(mdeopt);end
        
    end
end