function [flag,holidays] = isholiday(dateIn,city)

if nargin < 1
    error('isholiday:invalid date input');
end

if (nargin < 3 || isempty(city)) || strcmpi(city,'shanghai')
    holidays = [736330,...
                736368,...
                736369,...
                736370,...
                736371,...
                736372,...
                736424,...
                736452,...
                736490,...
                736491,...
                736588,...
                736589,...
                736606,...
                736607,...
                736608,...
                736609,...
                736610,...
                736697,...
                736722,...
                736725,...
                736726,...
                736727,...
                736728,...
                736788,...
                736789,...
                736816,...
                736844,...
                736845,...
                736970,...
                736971,...
                736972,...
                736973,...
                736974,...
                737061,...
                737106,...
                737107,...
                737110,...
                737111,...
                737112,...
                737155,...
                737156,...
                737180,...
                737181,...
                737229,...
                737327,...
                737334,...
                737335,...
                737336,...
                737337,...
                737338,...
                737425,...
                737426,...
                737460,...
                737461,...
                737462,...
                737463,...
                737464,...
                737520,...
                737546,...
                737547,...
                737548,...
                737583,...
                737681,...
                737699,...
                737700,...
                737701,...
                737702,...
                737705,...
                737791];
end

d = weekday(dateIn);
if d == 1 || d == 7
    flag = 1;
else  
    answer = find(holidays == datenum(dateIn), 1);
    if isempty(answer)
        flag = 0;
    else
        flag = 1;
    end
end
    



end