assets = {'iron ore';'deformed bar';'nickel';'aluminum';'gold';'sugar';'soymeal'};

defaultProfile = parallel.defaultClusterProfile('local');
myCluster = parcluster(defaultProfile);
myJob = myCluster.createJob;
nasset = size(assets,1);
myTasks = cell(nasset,1);
for i = 1:nasset
    myTasks{i} = myJob.createTask(@rollfutures,1,{assets{i},...
        'lengthofperiod','3y',...
        'forecastperiod',63});
end

%%
myJob.submit;

wait(myJob);

taskoutput = myJob.fetchOutputs;

%%
%print results
alpha = 0.995;
for i = 1:nasset
    Y = taskoutput{i}.ForecastResults.ForecastedReturn(1);
    YMSE = taskoutput{i}.ForecastResults.ForecastedReturnError(1);
    upper = Y + norminv(alpha)*sqrt(YMSE);
    lower = Y - norminv(alpha)*sqrt(YMSE);
    fprintf('%12s:lv:%4.1f%%; hv:%4.1f%%; ewma:%4.1f%%; forecast:%4.1f%%; upper:%4.1f%%; lower:%4.1f%%;\n',...
        assets{i},...
        taskoutput{i}.ForecastResults.LongTermAnnualVol*100,...
        taskoutput{i}.ForecastResults.HistoricalAnnualVol*100,...
        taskoutput{i}.ForecastResults.EWMAAnualVol*100,...
        taskoutput{i}.ForecastResults.ForecastedAnnualVol*100,...
        upper*100,lower*100);
end
fprintf('\n')
