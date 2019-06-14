function [] = printmarket(obj)
    if strcmpi(obj.mode_,'realtime')
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
        
        fprintf('\nlatest market quotes:\n');
        fprintf('%10s%8s%8s%8s%9s%11s%10s%10s%10s%8s%8s%10s%10s%10s%10s\n',...
            'contract','bid','ask','close','change','time','wr','max','min','bs','ss','levelup','leveldn','macd','sig');
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
            timet = datestr(quotes{i}.update_time1,'HH:MM:SS');
            delta = ((lasttrade/obj.lastclose_(i))-1)*100;
            instr = code2instrument(code);
            wrinfo = obj.calc_wr_(instr,'IncludeLastCandle',1);
            [buysetup,sellsetup,levelup,leveldn] = obj.calc_tdsq_(instr,'IncludeLastCandle',1);
            [macdvec,sig] = obj.calc_macd_(instr,'IncludeLastCandle',1);
            dataformat = '%10s%8s%8s%8s%8.1f%%%11s%10.1f%10s%10s%8s%8s%10s%10s%10.1f%10.1f\n';
            
            fprintf(dataformat,code,num2str(bid),num2str(ask),num2str(obj.lastclose_(i)),...
                delta,timet,...
                wrinfo(1),num2str(wrinfo(2)),num2str(wrinfo(3)),...
                num2str(buysetup(end)),num2str(sellsetup(end)),num2str(levelup(end)),num2str(leveldn(end)),...
                macdvec(end),sig(end));
        end
    else
        %replay mode
        instruments = obj.qms_.instruments_.getinstrument;
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
                fprintf('%10s%8s%8s%8s%9s%11s%10s%10s%10s%8s%8s%10s%10s%10s%10s\n',...
            'contract','bid','ask','close','change','time','wr','max','min','bs','ss','levelup','leveldn','macd','sig');
            end
            lasttrade = lasttick(4);
            timet = datestr(lasttick(1),'HH:MM:SS');
            dataformat = '%10s%8s%8s%8s%8.1f%%%11s%10.1f%10s%10s%8s%8s%10s%10s%10.1f%10.1f\n';
            delta = ((lasttrade/obj.lastclose_(i))-1)*100;
            
            wrinfo = obj.calc_wr_(instruments{i},'IncludeLastCandle',1);
            [buysetup,sellsetup,levelup,leveldn] = obj.calc_tdsq_(instruments{i},'IncludeLastCandle',1);
            [macdvec,sig] = obj.calc_macd_(instruments{i},'IncludeLastCandle',1);
            
            fprintf(dataformat,code,num2str(lasttrade),num2str(lasttrade),num2str(obj.lastclose_(i)),...
                delta,timet,...
                wrinfo(1),num2str(wrinfo(2)),num2str(wrinfo(3)),...
                num2str(buysetup(end)),num2str(sellsetup(end)),num2str(levelup(end)),num2str(leveldn(end)),...
                macdvec(end),sig(end));
        end
        
    end

end

