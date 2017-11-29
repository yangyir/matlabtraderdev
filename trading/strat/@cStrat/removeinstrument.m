function [] = removeinstrument(strategy,instrument)

    if isempty(strategy.instruments_), return; end

    strategy.instruments_.removeinstrument(instrument);
    [optflag,~,~,underlierstr,~] = isoptchar(instrument.code_ctp);
    if optflag
        %note:we shall also remove the underlier in case all the
        %options with the instrument are gone
        list = strategy.instruments_.getinstrument;
        removeunderlier = true;
        for i = 1:size(list,1)
            codestr = list{i}.code_ctp;
            [check,~,~,underlierstr_i,~] = isoptchar(codestr);
            if check && strcmpi(underlierstr_i,underlierstr)
                removeunderlier = false;
                break
            end
        end

        if removeunderlier
            u = cFutures(underlierstr);
            u.loadinfo([underlierstr,'_info.txt']);
            strategy.underliers_.removeinstrument(u);
        end
    end

end
%end of 'removeinstrument'