function [] = refresh(watcher,timestr)
    if isempty(watcher), return; end
    try
        if nargin <= 1
            data = watcher.getquotes;
        else
            data = watcher.getquotes(timestr);
        end
    catch e
        error('cWatcher:refresh:error in cWather:getquotes:%s',e.message);
    end
    
    if isempty(data)
        return
    end
    
    ns = watcher.countsingles;
    nu = watcher.countunderliers;
    watcher.init_quotes;

    for i = ns+1:ns+nu
        if isempty(watcher.qs{i})
            watcher.qs{i} = cQuoteFut;
        end
        watcher.qs{i}.update(watcher.underliers_ctp{i-ns},data(i,1),data(i,2),data(i,3),...
            data(i,4),data(i,5),data(i,6),data(i,7));
    end

    for i = 1:ns
        if strcmpi(watcher.types{i},'futures')
            if isempty(watcher.qs{i})
                watcher.qs{i} = cQuoteFut;
            end
            watcher.qs{i}.update(watcher.singles_ctp{i},data(i,1),data(i,2),data(i,3),...
                data(i,4),data(i,5),data(i,6),data(i,7));
        elseif strcmpi(watcher.types{i},'option')
            [~,~,~,underlierstr] = isoptchar(watcher.singles{i});
            [~,idx] = watcher.hasunderlier(underlierstr);
            if isempty(watcher.qs{i})
                watcher.qs{i} = cQuoteOpt;
            end
            watcher.qs{i}.update(watcher.singles_ctp{i},data(i,1),data(i,2),...
                data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),...
                watcher.qs{ns+idx},watcher.calcgreeks);
        elseif strcmpi(watcher.types{i},'stock')
            if isempty(watcher.qs{i})
                watcher.qs{i} = cQuoteStock;
            end
            watcher.qs{i}.update(watcher.singles_ctp{i},data(i,1),data(i,2),data(i,3),...
                data(i,4),data(i,5),data(i,6),data(i,7));
        else
            error('cWatcher:refresh:internal error')
        end
    end

    watcher.quotessingle2pair;

end
%end pf refresh