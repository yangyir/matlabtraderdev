function [] = addinstrument(obj,instrument,px,volume,dtnum,closetoday)
    if nargin < 3
        px = 0;
        volume = 0;
        dtnum = now;
        closetoday = 0;
    end

    if nargin == 3
        error('cPortfolio:addinstrument:missing input of volume')
    end

    if nargin == 4
        dtnum = now;
        closetoday = 0;
    end

    if nargin == 5
        closetoday = 0;
    end

    [bool,idx] = obj.hasinstrument(instrument);
    if ~bool
        if closetoday ~= 0
            error('cPortfolio:addinstrument:position not found to close in the portfolio')
        end
        n = obj.count;
        list_ = cell(n+1,1);
        c_ = zeros(n+1,1);
        v_ = zeros(n+1,1);
%         pos_
        vtoday_ = zeros(n+1,1);
        list_{n+1,1} = instrument;
        c_(n+1,1) = px;
        v_(n+1,1) = volume;
        if dtnum > getlastbusinessdate
            vtoday_(n+1,1) = volume;
        end

        for i = 1:n
            list_{i,1} = obj.instrument_list{i,1};
            c_(i,1) = obj.instrument_avgcost(i,1);
            v_(i,1) = obj.instrument_volume(i,1);
            vtoday_(i,1) = obj.instrument_volume_today(i,1);
        end
        obj.instrument_list = list_;
        obj.instrument_avgcost = c_;
        obj.instrument_volume = v_;
        obj.instrument_volume_today = vtoday_;
    else
        avgcost_ = obj.instrument_avgcost(idx,1);
        volume_ = obj.instrument_volume(idx,1);
        volume_today_ = obj.instrument_volume_today(idx,1);
        obj.instrument_volume(idx,1) = volume_+volume;
        if dtnum > getlastbusinessdate
            if volume_today_ > 0
                if volume > 0
                    %same direction-long positions
                    obj.instrument_volume_today(idx,1) = volume_today_ + volume;
                else
                    %unwind positions
                    if closetoday
                        if abs(volume_today_) < abs(volume)
                            error('cPortfolio:addinstrument:closetoday volume exceeds existing volume as of today')
                        end
                        obj.instrument_volume_today(idx,1) = volume_today_ + volume;
                    else
                        volume_yesterday_ = volume_ - volume_today_;
                        if abs(volume_yesterday_) > abs(volume)
                            obj.instrument_volume_today(idx,1) = volume_today_;
                        else
                            %all the volume yesterday has been
                            %unwinded
                            obj.instrument_volume_today(idx,1) = volume_ + volume;
                        end
                    end
                end
            elseif volume_today_ < 0
                if volume < 0
                    %same direction-short positions
                    obj.instrument_volume_today(idx,1) = volume_today_ + volume;
                else
                    %unwind positions
                    if closetoday
                        if abs(volume_today_) < abs(volume)
                            error('cPortfolio:addinstrument:closetoday volume exceeds existing volume as of today');
                        end
                        obj.instrument_volume_today(idx,1) = volume_today_ + volume;
                    else
                        volume_yesterday_ = volume_ - volume_today_;
                        if abs(volume_yesterday_) > abs(volume)
                            obj.instrument_volume_today(idx,1) = volume_today_;
                        else
                            %all the volume yesterday has been
                            %unwinded
                            obj.instrument_volume_today(idx,1) = volume_ + volume;
                        end
                    end
                end
            elseif volume_today_ == 0
                if closetoday
                    error('cPortfolio:addinstrument:position not found to close in the portfolio')
                end
                if sign(volume_) == sign(volume) || sign(volume_) == 0
                    obj.instrument_volume_today(idx,1) = volume_today_ + volume;
                else
                    %unwind trades
                    obj.instrument_volume_today(idx,1) = 0;
                end

            end
        end

        if obj.instrument_volume(idx,1) == 0
            obj.instrument_avgcost(idx,1) = 0;
        else
            obj.instrument_avgcost(idx,1) = (avgcost_*volume_ + px*volume)/(volume_+volume);
        end
    end
end
%end of addinstrument