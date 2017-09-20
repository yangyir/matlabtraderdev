function bd = getbusinessdate(y,m,num,dir)
% function to get the numth business date of the month
if nargin == 2
    %by default, we get the first business date of the month
    num = 1;
    dir = 1;
end

if nargin == 3, dir = 1; end

if mod(y,4) == 0
    isleapyear = true;
else
    isleapyear = false;
end

if ~(dir == 1 || dir == -1)
    error('getbusinessdate:invalid direction input,must be 1 or -1')
end

if dir == 1
    d = 1;
else
    switch m
        case {1,3,5,7,8,10,12}
            d = 31;
        case {4,6,9,11}
            d = 30;
        case 2
            if isleapyear
                d = 29;
            else
                d = 28;
            end
        otherwise
            error('getbusinessdate:invalid month input')
    end
end

ystr = num2str(y);
if m < 10
    mstr = ['0',num2str(m)];
else
    mstr = num2str(m);
end

if d < 10
    dstr = ['0',num2str(d)];
else
    dstr = num2str(d);
end


% bd = datetime(y,m,d);
bd = [ystr,'-',mstr,'-',dstr];
if ~isholiday(bd)
    num = num - 1;
end

while num > 0
    bd = businessdate(bd,dir);
    num = num-1;
end

bd = datenum(bd);




            
        

