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
        fprintf('%11s%11s%11s%11s%12s%12s%11s%11s%11s\n','contract','bid','ask','close','change','time','wr','max','min');
        for i = 1:n
            code = quotes{i}.code_ctp;
            bid = quotes{i}.bid1;
            if bid > 1e6
                bid = NaN;
            end
            ask = quotes{i}.ask1;
            if ask > 1e6
                ask = NaN;
            end
            timet = datestr(quotes{i}.update_time1,'HH:MM:SS');
            delta = ((quotes{i}.last_trade/obj.lastclose_(i))-1)*100;
            wrinfo = obj.calc_technical_indicators(code);
            dataformat = '%11s%11s%11s%11s%11.1f%%%12s%11.1f%11s%11s\n';
            
            if ~isempty(wrinfo{1})
                fprintf(dataformat,code,num2str(bid),num2str(ask),num2str(obj.lastclose_(i)),...
                    delta,timet,...
                    wrinfo{1}(1),num2str(wrinfo{1}(2)),num2str(wrinfo{1}(3)));
            else
                dataformat = '%11s%11s%11s%11s%11.1f%%%12s%11s%11s%11s\n';
                fprintf(dataformat,code,num2str(bid),num2str(ask),num2str(obj.lastclose_(i)),...
                    delta,timet,...
                    'nan','nan','nan');
            end
        end
    else
        instruments = obj.qms_.instruments_.getinstrument;
        n = size(instruments,1);
        if n == 0
            fprintf('error:cMDEFut:printmarket:no quote returns...\n');
            return;
        end
        
%         if isempty(obj.ticks_)
%             return
%         end
        if isempty(obj.ticksquick_)
            return
        end
        
        rowcount = 0;
        for i = 1:n
            code = instruments{i}.code_ctp;
%             lasttick = obj.getlasttick(instruments{i});
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
                fprintf('%11s%11s%11s%12s\n','contract','bid','ask','time');
            end
            bid = lasttick(2);
            ask = lasttick(3);
            timet = datestr(lasttick(1),'HH:MM:SS');
            dataformat = '%11s%11s%11s%12s\n';
            
            fprintf(dataformat,code,num2str(bid),num2str(ask),timet);
        end
        
    end

end

