function tradingLength = trading_length(obj)
    %this function calculate how many minutes does the futures
    %trade in a day. This will help to scale the volatility from
    %daily to different time intevals
    tradingHours = regexp(obj.trading_hours,';','split');

    tradingLength = 0;
    for i = 1:length(tradingHours)
        mktOpenStr = tradingHours{i}(1:5);
        mktCloseStr = tradingHours{i}(end-4:end);
        mktOpenMin = str2double(mktOpenStr(1:2))*60+...
            str2double(mktOpenStr(end-1:end));
        mktCloseMin = str2double(mktCloseStr(1:2))*60+...
            str2double(mktCloseStr(end-1:end));
        if mktCloseMin < mktOpenMin
            tradingLength = tradingLength + 1440-mktOpenMin + mktCloseMin;
        else
            tradingLength = tradingLength + mktCloseMin-mktOpenMin;
        end
    end

    if ~isempty(obj.trading_break)
        tradingLength = tradingLength - 15;
    end
end
%end of trading_lengthfunction [ output_args ] = trading_length( input_args )





