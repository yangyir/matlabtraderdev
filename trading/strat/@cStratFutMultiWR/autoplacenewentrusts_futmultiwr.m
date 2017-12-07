function [] = autoplacenewentrusts_futmultiwr(strategy,signals)
    if isempty(strategy.counter_) && ~strcmpi(strategy.mode_,'debug'), return; end

    %now check the signals
    for i = 1:size(signals,1)
        signal = signals{i};
        if isempty(signal), continue; end

        instrument = signal.instrument;
        direction = signal.direction;
        if direction == 0, continue; end

        [flag,idx] = strategy.portfolio_.hasposition(instrument);
        if ~flag
            volume_exist = 0;
        else
            pos = strategy.portfolio_.pos_list{idx};
            volume_exist = pos.direction_*pos.position_total_;
        end

        [~,ii] = strategy.instruments_.hasinstrument(instrument);
        
        if ~strategy.autotrade_(ii),continue;end

        if volume_exist == 0
            volume = strategy.getbaseunits(instrument);
        else
            maxvolume = strategy.getmaxunits(instrument);
            executiontype = strategy.getexecutiontype(instrument);
            if strcmpi(executiontype,'martingale')
                volume = max(min(maxvolume-abs(volume_exist),abs(volume_exist)),0);
            elseif strcmpi(executiontype,'fixed')
                n = strategy.getbaseunits(instrument);
                volume = max(min(maxvolume-abs(volume_exist),n),0);
            end
        end

        if volume == 0, continue;end

        %check wheter we've already executed trades within the
        %bucket and if so check whether the maximum executed number
        %is breached or not
        bucketnum = strategy.mde_fut_.getcandlecount(instrument);
        if bucketnum > 0 && bucketnum == strategy.executionbucketnumber_(ii);
            if strategy.executionperbucket_(ii) >=  strategy.maxexecutionperbucket_(ii)
                %note: if the maximum execution time is reached we
                %won't open up new positions for this bucket
                continue;
            end
        end

%         multi = instrument.contract_size;
%         code = instrument.code_ctp;
%         if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
%             multi = multi/100;
%         end
% 
%         offset = 1;
%         tick = strategy.mde_fut_.getlasttick(instrument);
%         bid = tick(2);
%         ask = tick(3);

        %firstly to unwind all existing entrusts associated with
        %the instrument
        if ~strcmpi(strategy.mode_,'debug')
            strategy.withdrawentrusts(instrument);
        end
        
        if direction < 0
            [ret,e] = strategy.shortopensingleinstrument(instrument.code_ctp,abs(volume));
        else
            [ret,e] = strategy.longopensingleinstrument(instrument.code_ctp,abs(volume));
        end

%         e = Entrust;
%         e.assetType = 'Future';
%         e.multiplier = multi;
%         if direction < 0
%             price =  bid - strategy.bidspread_(ii);
%         else
%             price =  ask + strategy.askspread_(ii);
%         end
% 
%         if ~strcmpi(strategy.mode_,'debug')
%             e.fillEntrust(1,code,direction,price,abs(volume),offset,code);
%             ret = strategy.counter_.placeEntrust(e);
%             if ret
%                 strategy.entrusts_.push(e);
%             end
%         end
        strategy.counter_.queryEntrust(e);
        f2 = e.is_entrust_closed;
        
        if strcmpi(strategy.mode_,'debug') || (~strcmpi(strategy.mode_,'debug')&&ret&& f2)
            if strategy.executionbucketnumber_(ii) ~= bucketnum;
                strategy.executionbucketnumber_(ii) = bucketnum;
                strategy.executionperbucket_(ii) = 1;
            else
                strategy.executionperbucket_(ii) = strategy.executionperbucket_(ii)+1;
            end
% 
%             %update portfolio and pnl_close_ as required in the
%             %following
%             %assuming the entrust is completely filled
%             t = cTransaction;
%             t.instrument_ = instrument;
%             t.price_ = price;
%             t.volume_= abs(volume);
%             t.direction_ = direction;
%             t.offset_ = offset;
%             t.datetime1_ = e.time;
%             t.datetime2_ = datestr(e.time);
%             strategy.portfolio_.updateportfolio(t);
        end

    end

end
%end of autoplacenewentrusts