function [] = eodanalysis(obj,varargin)
%cETFWatcher
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
%     n_stock = size(obj.codes_stock_,1);
    
    for i = 1:n_index
        if strcmpi(obj.codes_index_{i}(1:6),'159781') || strcmpi(obj.codes_index_{i}(1:6),'159782'), continue;end
        trade = obj.pos_index_{i};
        if isempty(trade),continue;end
        extrainfo = obj.dailybarstruct_index_{i};
        extrainfo.p = extrainfo.px;
        extrainfo.latestopen = extrainfo.px(end,5);
        extrainfo.latestdt = extrainfo.px(end,1);
        tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',extrainfo);
        if ~isempty(tradeout)
             fprintf('%s:closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
        else
            fprintf('%s:live.\n',trade.code_);
        end   
    end
    %
    %
    fprintf('\n');
    for i = 1:n_sector
        if strcmpi(obj.codes_sector_{i}(1:6),'512880') || strcmpi(obj.codes_sector_{i}(1:6),'512800'), continue;end
        trade = obj.pos_sector_{i};
        if isempty(trade),continue;end
        extrainfo = obj.dailybarstruct_sector_{i};
        extrainfo.p = extrainfo.px;
        extrainfo.latestopen = extrainfo.px(end,5);
        extrainfo.latestdt = extrainfo.px(end,1);
        tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',extrainfo);
        if ~isempty(tradeout)
             fprintf('%s:closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
        else
            fprintf('%s:live.\n',trade.code_);
        end   
    end
    


end