function [] = init_quotes(watcher)
% private function to init quotes
    if isempty(watcher), return; end
    nq = size(watcher.qs,1);
    ns = watcher.countsingles;
    if nq ~= ns
        nu = watcher.countunderliers;
        watcher.qs = cell(ns+nu,1);
        %here we only initiate the quotes for option legs but not
        %the underlier
        for i = 1:ns
            if strcmpi(watcher.types{i},'option')
                q = cQuoteOpt;
                q.init(watcher.singles{i});
                %set interest rate level once a day
                %note:this now only works with Bloomberg
                if isempty(q.riskless_rate)
                    if isa(watcher.ds,'cBloomberg')
                        data = watcher.ds.realtime('CCSWOC CMPN Curncy','px_last');
                        q.riskless_rate = data.px_last/100;
                    else
                        q.riskless_rate = 0.035;
                    end
                end
            else
                q = cQuoteFut;
                q.init(watcher.singles{i});
            end
            watcher.qs{i} = q;
        end

        for i = 1:nu
            q = cQuoteFut;
            q.init(watcher.underliers{i});
            watcher.qs{ns+i} = q;
        end
    end
end