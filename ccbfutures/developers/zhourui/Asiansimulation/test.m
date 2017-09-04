% clear;
% clc;
% 
% w=windmatlab;
% w.menu;
ret = price2ret(data(1:20));
T = length(ret);
md = garch(1,1);
EstMd = estimate(md,ret);
vI = infer(EstMd,ret);
vf = forecast(EstMd,1,'Y0',vI);
vol = sqrt(vf)  * sqrt(252);


GarVol=garchVol(cell2mat(ExerciseData(:,2)),cell2mat(ExerciseData(:,3)),ExerciseTimes,Times);