function [] = addposition(port,instrument,px,volume,dtnum,closetoday)
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

    [bool,idx] = port.hasposition(instrument);
    if ~bool
        if closetoday ~= 0
            error('cPortfolio:addinstrument:position not found to close in the portfolio')
        end
        n = port.count;
%         list_ = cell(n+1,1);
%         c_ = zeros(n+1,1);
%         v_ = zeros(n+1,1);
        pos_list_ = cell(n+1,1);
%         vtoday_ = zeros(n+1,1);
%         list_{n+1,1} = instrument;
%         c_(n+1,1) = px;
%         v_(n+1,1) = volume;
        pos = cPos;
        pos.override('code',instrument.code_ctp,'price',px,'volume',volume,'time',dtnum);
        pos_list_{n+1,1} = pos;
%         if dtnum > getlastbusinessdate
%             vtoday_(n+1,1) = volume;
%         end
% 
        for i = 1:n
%             list_{i,1} = port.instrument_list{i,1};
%             c_(i,1) = port.instrument_avgcost(i,1);
%             v_(i,1) = port.instrument_volume(i,1);
%             vtoday_(i,1) = port.instrument_volume_today(i,1);
            pos_list_{i,1} = port.pos_list{i,1};
        end
%         port.instrument_list = list_;
%         port.instrument_avgcost = c_;
%         port.instrument_volume = v_;
%         port.instrument_volume_today = vtoday_;
        port.pos_list = pos_list_;
    else
%         avgcost_ = port.instrument_avgcost(idx,1);
%         volume_ = port.instrument_volume(idx,1);
%         volume_today_ = port.instrument_volume_today(idx,1);
%         port.instrument_volume(idx,1) = volume_+volume;
        port.pos_list{idx,1}.add('code',instrument.code_ctp,'price',px,'volume',volume,'time',dtnum,'closetodayflag',closetoday);
%         if dtnum > getlastbusinessdate
%             if volume_today_ > 0
%                 if volume > 0
%                     %same direction-long positions
%                     port.instrument_volume_today(idx,1) = volume_today_ + volume;
%                 else
%                     %unwind positions
%                     if closetoday
%                         if abs(volume_today_) < abs(volume)
%                             error('cPortfolio:addinstrument:closetoday volume exceeds existing volume as of today')
%                         end
%                         port.instrument_volume_today(idx,1) = volume_today_ + volume;
%                     else
%                         volume_yesterday_ = volume_ - volume_today_;
%                         if abs(volume_yesterday_) > abs(volume)
%                             port.instrument_volume_today(idx,1) = volume_today_;
%                         else
%                             %all the volume yesterday has been
%                             %unwinded
%                             port.instrument_volume_today(idx,1) = volume_ + volume;
%                         end
%                     end
%                 end
%             elseif volume_today_ < 0
%                 if volume < 0
%                     %same direction-short positions
%                     port.instrument_volume_today(idx,1) = volume_today_ + volume;
%                 else
%                     %unwind positions
%                     if closetoday
%                         if abs(volume_today_) < abs(volume)
%                             error('cPortfolio:addinstrument:closetoday volume exceeds existing volume as of today');
%                         end
%                         port.instrument_volume_today(idx,1) = volume_today_ + volume;
%                     else
%                         volume_yesterday_ = volume_ - volume_today_;
%                         if abs(volume_yesterday_) > abs(volume)
%                             port.instrument_volume_today(idx,1) = volume_today_;
%                         else
%                             %all the volume yesterday has been
%                             %unwinded
%                             port.instrument_volume_today(idx,1) = volume_ + volume;
%                         end
%                     end
%                 end
%             elseif volume_today_ == 0
%                 if closetoday
%                     error('cPortfolio:addinstrument:position not found to close in the portfolio')
%                 end
%                 if sign(volume_) == sign(volume) || sign(volume_) == 0
%                     port.instrument_volume_today(idx,1) = volume_today_ + volume;
%                 else
%                     %unwind trades
%                     port.instrument_volume_today(idx,1) = 0;
%                 end
% 
%             end
%         end
% 
%         if port.instrument_volume(idx,1) == 0
%             port.instrument_avgcost(idx,1) = 0;
%         else
%             port.instrument_avgcost(idx,1) = (avgcost_*volume_ + px*volume)/(volume_+volume);
%         end
    end
end
%end of addinstrument