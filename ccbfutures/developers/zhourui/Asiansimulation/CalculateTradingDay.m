function [ Tradingday ] = CalculateTradingDay( startday,endday,str_holiday )
    for i=1:1:size(str_holiday,1)
        holiday(i)=datenum(str_holiday(i,:));
    end
    naturalday=datenum(startday):1:datenum(endday);
    tradingday_num=0;
    for i=1:1:length(naturalday)
        is_holiday=0;
        for j=1:1:length(holiday)
            if naturalday(i)==holiday(j)
                is_holiday=1;
                break;
            end
        end
        if (weekday(datestr(naturalday(i)))~=1)&&(weekday(datestr(naturalday(i)))~=6)&&(~is_holiday)
            tradingday_num=tradingday_num+1;
            tradingday(tradingday_num)=naturalday(i);
        end
    end
    Tradingday=tradingday;
end

