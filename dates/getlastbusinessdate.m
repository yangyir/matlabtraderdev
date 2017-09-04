function dateoutput = getlastbusinessdate(dtinput,isGovtbond)

if nargin < 1
    dtinput = now;
    isGovtbond = false;
end

if nargin < 2
    isGovtbond = false;
end

dateinput = floor(dtinput);

if dateinput == dtinput
    %integer input
    if ~isholiday(dateinput)
        dateoutput = dateinput;
    else
        dateoutput = businessdate(dateinput,-1);
    end
    return
end

if ~isholiday(dateinput)
    hh = hour(dtinput);
    mm = minute(dtinput);
    if isGovtbond
        if hh == 9 && mm < 15
            dateoutput = businessdate(dateinput,-1);
        elseif hh == 9 && mm >= 15
            %market is still open
            dateoutput = businessdate(dateinput,-1);
        elseif hh > 9 && hh < 15
            %market is still open
            dateoutput = businessdate(dateinput,-1);
        elseif hh == 15 && mm <= 15
            %market is still open
            dateoutput = businessdate(dateinput,-1);
        elseif hh == 15 && mm > 15
            %market closed
            dateoutput = dateinput;
        elseif hh > 15 && hh <= 23
            dateoutput = dateinput;
        elseif hh < 9 && hh >= 0
            dateoutput = businessdate(dateinput,-1);
        end
    else
        if hh >= 9 && hh < 15
            %market is open
            dateoutput = businessdate(dateinput,-1);
        elseif hh == 15 && mm == 0
            dateoutput = businessdate(dateinput,-1);
        elseif hh == 15 && mm > 0
            dateoutput = dateinput;
        elseif hh > 15 && hh <= 23
            dateoutput = dateinput;
        elseif hh < 9 && hh >= 0
            dateoutput = businessdate(dateinput,-1);
        end
    end
else
    dateoutput = businessdate(dateinput,-1);
end

end