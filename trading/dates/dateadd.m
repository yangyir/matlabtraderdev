function dateout = dateadd(datein,interval,bump,midofthemonth)
    if nargin < 2
        error('dateadd:invalid input!');
    end
    
    if nargin < 3
        bump = 0;
    end
    
    if nargin < 4
        midofthemonth = 0;
    end
       
    if ~ischar(interval)
        error('dateout:invalid data type of interval,char expected!');
    end
    intervalstr = interval(end);
    intervalnum = str2double(interval(1:end-1));
    
    if strcmpi(intervalstr,'d')
        dateout = datein + intervalnum;
    elseif strcmpi(intervalstr,'b')
        %number of business days
        count = 1;
        dateout = datein;
        while count <= abs(intervalnum)
            dateout = businessdate(dateout,sign(intervalnum));
            count = count + 1;
        end
    elseif strcmpi(intervalstr,'m')
        yyyy = year(datein);
        mm = month(datein);
        dd = day(datein);
        mm = mm + intervalnum;
        if mm > 12
            nyear = floor(mm/12);
        elseif mm == 0
            nyear = -1;
        elseif mm < 0
            nyear = floor(mm/12);
        else
            nyear = 0;
        end
        mm = mm-nyear*12;
        yyyy = yyyy + nyear;
        dateout = datenum(yyyy,mm,dd);
    elseif strcmpi(intervalstr,'y')
        yyyy = year(datein) + intervalnum;
        mm = month(datein);
        dd = day(datein);
        dateout = datenum(yyyy,mm,dd);
    else
        error('dateout:invalid interval input')
    end
    
    if midofthemonth == 1
       dateout = datenum(year(dateout),month(dateout),15); 
    end
    
    if bump == 1 && isholiday(dateout)
        dateout = businessdate(dateout,1);
    elseif bump == -1 && isholiday(dateout)
        dateout = businessdate(dateout,-1);
    end 
    
    
end