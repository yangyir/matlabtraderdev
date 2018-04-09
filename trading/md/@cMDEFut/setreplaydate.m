function [] = setreplaydate(mdefut,datein)
    mdefut.mode_ = 'replay';
    if isnumeric(datein)
        mdefut.replay_date1_ = datein;
        mdefut.replay_date2_ = datestr(datein);
    elseif ischar(datein)
        mdefut.replay_date1_ = datenum(datein);
        mdefut.replay_date2_ = datein;
    end
    %
    %the replay time vector is on the same date as of the replay
    %date and it starts from 9am and ends until 2:30am on the next
    %calendar date
    dtstart = [mdefut.replay_date2_,' 09:00:00'];
    dtend = [datestr(mdefut.replay_date1_+1),' 02:30:00'];
    mdefut.replay_datetimevec_ = gendatetime(dtstart,dtend,struct('num',1,'str','m'));
    mdefut.replay_count_ = 0;
end
% end of setreplaydate