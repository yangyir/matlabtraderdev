function [] = printmarket(obj,varargin)
        dataformat = '%10s %8s %8s %8.2f%% %11s %10s %10s %4s %4s %10s %10s %10.3f %10.3f %10.3f %10s\n';
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
%     n_stock = size(obj.codes_stock_,1);
    
    fprintf('\nlatest market quotes of indices:\n');
    fprintf('%10s %8s %8s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s %10s %10s\n',...
        'code','latest','close','change','Ktime','hh','ll','bs','ss','levelup','leveldn','jaw','teeth','lips','name');
    for i = 1:n_index
        code = obj.codes_index_{i}(1:end-3);
        latest = obj.dailybarmat_index_{i}(end,5);
        lastclose = obj.dailybarmat_index_{i}(end-1,5);
        timet = datestr(obj.intradaybarmat_index_{i}(end,1),'HH:MM:SS');
        delta = (latest/lastclose-1)*100;
        buysetup = obj.intradaybarstruct_index_{i}.bs(end);
        sellsetup = obj.intradaybarstruct_index_{i}.ss(end);
        levelup = obj.intradaybarstruct_index_{i}.lvlup(end);
        leveldn = obj.intradaybarstruct_index_{i}.lvldn(end);
        jaw = obj.intradaybarstruct_index_{i}.jaw(end);
        teeth = obj.intradaybarstruct_index_{i}.teeth(end);
        lips = obj.intradaybarstruct_index_{i}.lips(end);
        HH = obj.intradaybarstruct_index_{i}.hh(end);
        LL = obj.intradaybarstruct_index_{i}.ll(end);
            
        fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
            delta,timet,...
            num2str(HH),num2str(LL),...
            num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
            jaw,teeth,lips,...
            obj.names_index_{i});
    end
    
    fprintf('\nlatest market quotes of sectors:\n');
    fprintf('%10s %8s %8s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s %10s %10s\n',...
        'code','latest','close','change','Ktime','hh','ll','bs','ss','levelup','leveldn','jaw','teeth','lips','name');
    for i = 1:n_sector
        code = obj.codes_sector_{i}(1:end-3);
        latest = obj.dailybarmat_sector_{i}(end,5);
        lastclose = obj.dailybarmat_sector_{i}(end-1,5);
        timet = datestr(obj.intradaybarmat_sector_{i}(end,1),'HH:MM:SS');
        delta = (latest/lastclose-1)*100;
        buysetup = obj.intradaybarstruct_sector_{i}.bs(end);
        sellsetup = obj.intradaybarstruct_sector_{i}.ss(end);
        levelup = obj.intradaybarstruct_sector_{i}.lvlup(end);
        leveldn = obj.intradaybarstruct_sector_{i}.lvldn(end);
        jaw = obj.intradaybarstruct_sector_{i}.jaw(end);
        teeth = obj.intradaybarstruct_sector_{i}.teeth(end);
        lips = obj.intradaybarstruct_sector_{i}.lips(end);
        HH = obj.intradaybarstruct_sector_{i}.hh(end);
        LL = obj.intradaybarstruct_sector_{i}.ll(end);
            
        fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
            delta,timet,...
            num2str(HH),num2str(LL),...
            num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
            jaw,teeth,lips,...
            obj.names_sector_{i});
    end
    % not to print information for single stocks for now    
end