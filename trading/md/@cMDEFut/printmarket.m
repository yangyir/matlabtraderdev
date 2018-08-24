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
        fprintf('%11s%11s%11s%12s\n','contract','bid','ask','time');
        for i = 1:n
            code = quotes{i}.code_ctp;
            bid = quotes{i}.bid1;
            ask = quotes{i}.ask1;
            timet = datestr(quotes{i}.update_time1,'HH:MM:SS');
            dataformat = '%11s%11s%11s%12s\n';
            
            fprintf(dataformat,code,num2str(bid),num2str(ask),timet);
        end
    else
        instruments = obj.qms_.instruments_.getinstrument;
        n = size(instruments,1);
        if n == 0
            fprintf('error:cMDEFut:printmarket:no quote returns...\n');
            return;
        end
        
        if isempty(obj.ticks_)
            return
        end
        
        fprintf('\nlatest market quotes (replay):\n');
        fprintf('%11s%11s%11s%12s\n','contract','bid','ask','time');
        for i = 1:n
            code = instruments{i}.code_ctp;
            lasttick = obj.getlasttick(instruments{i});
            if isempty(lasttick), continue;end
            bid = lasttick(2);
            ask = lasttick(3);
            timet = datestr(lasttick(1),'HH:MM:SS');
            dataformat = '%11s%11s%11s%12s\n';
            
            fprintf(dataformat,code,num2str(bid),num2str(ask),timet);
        end
        
    end

end

