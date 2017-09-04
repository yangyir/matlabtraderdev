function [ Vol ] = HisVol( PerPrice,Price,ExerciseTimes,Times )
    LogReturn=log(Price./PerPrice);
    Stand=zeros(length(Times),1);
    for i=1:1:length(Times)
        Stand(i,1)=std(LogReturn(i:1:i+length(ExerciseTimes)-length(Times)));
    end
    Vol=Stand.*sqrt(252);
end

