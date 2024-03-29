function [] = printmarket(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    tnum = p.Results.Time;
    tstr = datestr(tnum,'yyyy-mm-dd HH:MM:SS');
  
    dataformat = '%10s %8s %10s %8.2f%% %11s %10s %10s %4s %4s %10s %10s %10.3f %10.3f %10.3f %10s %4s %4s %10s\n';
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
%     n_stock = size(obj.codes_stock_,1);
    
    fprintf('\nlatest market quotes of indices on %s:\n',tstr);
    fprintf('%10s %8s %10s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s %10s %10s %4s %4s %10s\n',...
        'code','latest','preclose','change','Ktime','hh','ll','bs','ss','levelup','leveldn','teeth','lips','barrier','status-d','bs_i','ss_i','name');
    for i = 1:n_index
        code = obj.codes_index_{i}(1:end-3);
        if strcmpi(code,'159781') || strcmpi(code,'159782'), continue;end
        latest = obj.dailybarmat_index_{i}(end,5);
        lastclose = obj.dailybarmat_index_{i}(end-1,5);
        timet = datestr(obj.intradaybarmat_index_{i}(end,1),'HH:MM:SS');
        delta = (latest/lastclose-1)*100;
        buysetup = obj.dailybarstruct_index_{i}.bs(end);
        sellsetup = obj.dailybarstruct_index_{i}.ss(end);
        levelup = obj.dailybarstruct_index_{i}.lvlup(end);
        leveldn = obj.dailybarstruct_index_{i}.lvldn(end);
        teeth = obj.dailybarstruct_index_{i}.teeth(end);
        lips = obj.dailybarstruct_index_{i}.lips(end);
        HH = obj.dailybarstruct_index_{i}.hh(end);
        LL = obj.dailybarstruct_index_{i}.ll(end);
        buysetup_i = obj.intradaybarstruct_index_{i}.bs(end);
        sellsetup_i = obj.intradaybarstruct_index_{i}.ss(end);
        
        if ~isnan(obj.dailybarriers_conditional_index_(i,1))
            barrier = obj.dailybarriers_conditional_index_(i,1);
        elseif ~isnan(obj.dailybarriers_conditional_index_(i,2))
            barrier = obj.dailybarriers_conditional_index_(i,2);
        else
            barrier = NaN;
        end
            
        fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
            delta,timet,...
            num2str(HH),num2str(LL),...
            num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
            teeth,lips,barrier,...
            num2str(obj.dailystatus_index_(i)),...
            num2str(buysetup_i),...
            num2str(sellsetup_i),...
            obj.names_index_{i});
    end
    
    fprintf('\nlatest market quotes of sectors on %s:\n',tstr);
    fprintf('%10s %8s %10s %9s %11s %10s %10s %4s %4s %10s %10s %10s %10s %10s %10s %4s %4s %10s\n',...
        'code','latest','preclose','change','Ktime','hh','ll','bs','ss','levelup','leveldn','teeth','lips','barrier','status-d','bs_i','ss_i','name');
    for i = 1:n_sector
        code = obj.codes_sector_{i}(1:end-3);
        if strcmpi(code,'512800') || strcmpi(code, '512880'),continue;end
        latest = obj.dailybarmat_sector_{i}(end,5);
        lastclose = obj.dailybarmat_sector_{i}(end-1,5);
        timet = datestr(obj.intradaybarmat_sector_{i}(end,1),'HH:MM:SS');
        delta = (latest/lastclose-1)*100;
        buysetup = obj.dailybarstruct_sector_{i}.bs(end);
        sellsetup = obj.dailybarstruct_sector_{i}.ss(end);
        levelup = obj.dailybarstruct_sector_{i}.lvlup(end);
        leveldn = obj.dailybarstruct_sector_{i}.lvldn(end);
        teeth = obj.dailybarstruct_sector_{i}.teeth(end);
        lips = obj.dailybarstruct_sector_{i}.lips(end);
        HH = obj.dailybarstruct_sector_{i}.hh(end);
        LL = obj.dailybarstruct_sector_{i}.ll(end);
        buysetup_i = obj.intradaybarstruct_sector_{i}.bs(end);
        sellsetup_i = obj.intradaybarstruct_sector_{i}.ss(end);
        
        if ~isnan(obj.dailybarriers_conditional_sector_(i,1))
            barrier = obj.dailybarriers_conditional_sector_(i,1);
        elseif ~isnan(obj.dailybarriers_conditional_sector_(i,2))
            barrier = obj.dailybarriers_conditional_sector_(i,2);
        else
            barrier = NaN;
        end
            
        fprintf(dataformat,code,num2str(latest),num2str(lastclose),...
            delta,timet,...
            num2str(HH),num2str(LL),...
            num2str(buysetup),num2str(sellsetup),num2str(levelup),num2str(leveldn),...
            teeth,lips,barrier,...
            num2str(obj.dailystatus_sector_(i)),...
            num2str(buysetup_i),...
            num2str(sellsetup_i),...
            obj.names_sector_{i});
    end
    % not to print information for single stocks for now    
end