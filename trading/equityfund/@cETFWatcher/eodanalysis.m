function [] = eodanalysis(obj,varargin)
%cETFWatcher
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
%     n_stock = size(obj.codes_stock_,1);
    
    for i = 1:n_index
        if strcmpi(obj.codes_index_{i}(1:6),'159781') || strcmpi(obj.codes_index_{i}(1:6),'159782'), continue;end
        trade = obj.pos_index_{i};
        if ~isempty(trade)
            trade.status_ = 'set';
            trade.riskmanager_.status_ = 'set';
            extrainfo = obj.dailybarstruct_index_{i};
            extrainfo.p = extrainfo.px;
            extrainfo.latestopen = extrainfo.px(end,5);
            extrainfo.latestdt = extrainfo.px(end,1);
            trade.riskmanager_.setusefractalupdateflag(0);
            trade.riskmanager_.setusefibonacciflag(0);
            tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
                'usecandlelastonly',false,...
                'debug',false,...
                'updatepnlforclosedtrade',true,...
                'extrainfo',extrainfo);
            if ~isempty(tradeout)
                if tradeout.opendirection_ == 1
                    fprintf('%s:bullish closed:%s',tradeout.code_,tradeout.riskmanager_.closestr_);
                else
                    fprintf('%s:bearish closed:%s',tradeout.code_,tradeout.riskmanager_.closestr_);
                end
            else
                if trade.opendirection_ == 1
                    fprintf('%s:bullish live.',trade.code_);
                else
                    fprintf('%s:bearish live.',trade.code_);
                end
            end
            [signal,op] = fractal_signal_unconditional(extrainfo,0.001,2);
            if ~isempty(op) && op.use == 1
                if signal(1) == 1
                    fprintf('%s:breachup:%s.',obj.codes_index_{i}(1:6),op.comment);
                else
                    fprintf('%s:breachdn:%s.',obj.codes_index_{i}(1:6),op.comment);
                end
            end
            fprintf('\n');
        else
            extrainfo = obj.dailybarstruct_index_{i};
            [signal,op] = fractal_signal_unconditional(extrainfo,0.001,2);
            if ~isempty(op) && op.use == 1
                if signal(1) == 1
                    fprintf('%s:breachup:%s.\n',obj.codes_index_{i}(1:6),op.comment);
                else
                    fprintf('%s:breachdn:%s.\n',obj.codes_index_{i}(1:6),op.comment);
                end
            else
                [~,op] = fractal_signal_conditional(extrainfo,0.001,2);
                if ~isempty(op) && ~isempty(op{1})
                    fprintf('%s:bullish:%s.\n',obj.codes_index_{i}(1:6),op{1});
                end
            end
        end
    end
    %
    %
    fprintf('\n');
    for i = 1:n_sector
        if strcmpi(obj.codes_sector_{i}(1:6),'512880') || strcmpi(obj.codes_sector_{i}(1:6),'512800'), continue;end
        trade = obj.pos_sector_{i};
        if ~isempty(trade)
            trade.status_ = 'set';
            trade.riskmanager_.status_ = 'set';
            extrainfo = obj.dailybarstruct_sector_{i};
            extrainfo.p = extrainfo.px;
            extrainfo.latestopen = extrainfo.px(end,5);
            extrainfo.latestdt = extrainfo.px(end,1);
            trade.riskmanager_.setusefractalupdateflag(0);
            trade.riskmanager_.setusefibonacciflag(0);
            tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
                'usecandlelastonly',false,...
                'debug',false,...
                'updatepnlforclosedtrade',true,...
                'extrainfo',extrainfo);
            if ~isempty(tradeout)
                if tradeout.opendirection_ == 1
                    fprintf('%s:bullish closed:%s',tradeout.code_,tradeout.riskmanager_.closestr_);
                else
                    fprintf('%s:bearish closed:%s',tradeout.code_,tradeout.riskmanager_.closestr_);
                end
            else
                if trade.opendirection_ == 1
                    fprintf('%s:bullish live.',trade.code_);
                else
                    fprintf('%s:bearish live.',trade.code_);
                end
            end
            [signal,op] = fractal_signal_unconditional(extrainfo,0.001,2);
            if ~isempty(op) && op.use == 1
                if signal(1) == 1
                    fprintf('%s:breachup:%s.',obj.codes_sector_{i}(1:6),op.comment);
                else
                    fprintf('%s:breachdn:%s.',obj.codes_sector_{i}(1:6),op.comment);
                end
            end
            fprintf('\n'); 
        else
            extrainfo = obj.dailybarstruct_sector_{i};
            [signal,op] = fractal_signal_unconditional(extrainfo,0.001,2);
            if ~isempty(op) && op.use == 1
                if signal(1) == 1
                    fprintf('%s:breachup:%s.\n',obj.codes_sector_{i}(1:6),op.comment);
                else
                    fprintf('%s:breachdn:%s.\n',obj.codes_sector_{i}(1:6),op.comment);
                end
            else
                [~,op] = fractal_signal_conditional(extrainfo,0.001,2);
                if ~isempty(op) 
                    if ~isempty(op{1})
                        fprintf('%s:bullish:%s.\n',obj.codes_sector_{i}(1:6),op{1});
                    elseif ~isempty(op{2})
%                         fprintf('%s:breachdn:%s.\n',obj.codes_sector_{i}(1:6),op{2});
                    end 
                end
            end
        end
    end
    


end