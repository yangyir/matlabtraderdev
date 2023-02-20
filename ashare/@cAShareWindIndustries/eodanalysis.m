function [] = eodanalysis(obj,varargin)
%cAShareWindIndustries
    n_index = size(obj.codes_index_,1);
    
    for i = 1:n_index
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
                    fprintf('%s:bullish closed:%s(%s)',tradeout.code_,tradeout.riskmanager_.closestr_,obj.names_index_{i});
                else
                    fprintf('%s:bearish closed:%s(%s)',tradeout.code_,tradeout.riskmanager_.closestr_,obj.names_index_{i});
                end
            else
                if trade.opendirection_ == 1
                    fprintf('%s:bullish live(%s).',trade.code_,obj.names_index_{i});
                else
                    fprintf('%s:bearish live(%s).',trade.code_,obj.names_index_{i});
                end
            end
            [signal,op] = fractal_signal_unconditional(extrainfo,0.001,2);
            if ~isempty(op) && op.use == 1
                if signal(1) == 1
                    fprintf('%s:breachup:%s(%s).',obj.codes_index_{i}(1:6),op.comment,obj.names_index_{i});
                else
                    fprintf('%s:breachdn:%s(%s).',obj.codes_index_{i}(1:6),op.comment,obj.names_index_{i});
                end
            end
            fprintf('\n');
        else
            extrainfo = obj.dailybarstruct_index_{i};
            [signal,op] = fractal_signal_unconditional(extrainfo,0.001,2);
            if ~isempty(op) && op.use == 1
                if signal(1) == 1
                    fprintf('%s:breachup:%s(%s).\n',obj.codes_index_{i}(1:6),op.comment,obj.names_index_{i});
                else
                    fprintf('%s:breachdn:%s(%s).\n',obj.codes_index_{i}(1:6),op.comment,obj.names_index_{i});
                end
            else
%                 [~,op] = fractal_signal_conditional(extrainfo,0.001,2);
%                 if ~isempty(op) && ~isempty(op{1})
%                     fprintf('%s:bullish:%s(%s).\n',obj.codes_index_{i}(1:6),op{1},obj.names_index_{i});
%                 end
            end
        end
    end
    %
    %
    fprintf('\n');
    
    


end