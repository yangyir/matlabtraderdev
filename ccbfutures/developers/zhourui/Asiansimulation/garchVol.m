function [ Vol ] = garchVol( PerPrice,Price,ExerciseTimes,Times )
    LogReturn=log(Price./PerPrice);
    Stand=zeros(length(Times),1);
    md = garch(1,1);
    for i=1:1:length(Times)
       EstMd = estimate(md,LogReturn(i:1:i+length(ExerciseTimes)-length(Times)));
       Y0 = infer(EstMd,LogReturn(i:1:i+length(ExerciseTimes)-length(Times)));
       vf = forecast(EstMd,1);
       Stand(i,1) = sqrt(vf);
       clear EstMd;
    end
    Vol=Stand.*sqrt(252);
    
%     LogReturn=log(Price./PerPrice);
%     Stand=zeros(length(Times),1);
%     for i=1:1:length(Times)
%         Stand(i,1)=std(LogReturn(i:1:i+length(ExerciseTimes)-length(Times)));
%     end
%     Vol=Stand.*sqrt(252);
    
end

