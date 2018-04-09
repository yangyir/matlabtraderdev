function [] = replay_timer_fcn(mdefut,~,event)
    if strcmpi(mdefut.mode_,'realtime')
        dtnum = datenum(event.Data.time);
    elseif strcmpi(mdefut.mode_,'replay')
        mdefut.replay_count_ = mdefut.replay_count_+1;
        n = min(mdefut.replay_count_,size(mdefut.replay_datetimevec_,1));
        dtnum = mdefut.replay_datetimevec_(n);
        fprintf('replay time %s\n',datestr(dtnum));
    end

    hh = hour(dtnum);
    mm = minute(dtnum) + hh*60;

    %for friday evening market
    if isholiday(floor(dtnum))
        if weekday(dtnum) == 7 && mm >= 180
            mdefut.status_ = 'sleep';
            return
        elseif weekday(dtnum) == 7 && mm < 180
            %do nothing
        else
            mdefut.status_ = 'sleep';
            return
        end
    end

    if (mm > 150 && mm < 540) || ...
            (mm > 690 && mm < 780 ) || ...
            (mm > 915 && mm < 1260)
        %market closed for sure

        % save candles on 2:31am
        if mm == 151
            mdefut.savecandles2file;
        end

        %init the required data on 8:50
        if mdefut.candlesaveflag_ && mm == 530
            fprintf('init candles on %s......\n',datestr(dtnum));
            instruments = mdefut.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            for i = 1:ns
                freq = mdefut.getcandlefreq(instruments{i});
                mdefut.setcandlefreq(freq,instruments{i});
            end

            mdefut.candlesaveflag_ = false;
            mdefut.initcandles;
            mdefut.status_ = 'working';
        end

        return
    end

    mdefut.refresh;

    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    indicators = zeros(ns,1);
    for i = 1:ns
        if mdefut.technical_indicator_autocalc_(i)
            ti = mdefut.calc_technical_indicators(instruments{i});
            if ~isempty(ti)
                indicators(i) = ti(end);
                fprintf('%s %s of %s:%4.2f\n',datestr(event.Data.time),...
                    instruments{i}.code_ctp,...
                    mdefut.technical_indicator_table_{i}.name,...
                    indicators(i));
            end
        end
    end
end
%end of replay_timer_function