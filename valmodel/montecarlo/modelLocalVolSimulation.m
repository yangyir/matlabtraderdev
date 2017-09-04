function [paths,times,z] = modelLocalVolSimulation(yc,mktdata,vol,security,model)
%1.sanity check
if ~isa(yc,'cYieldCurve')
    error('modelLocalVolSimulation:yieldcurve is missing')
end

if ~isa(mktdata,'cMktData')
    error('modelLocalVolSimulation:mktdata is missing')
end

if yc.ValuationDate ~= mktdata.ValuationDate
    error('modelLocalVolSimulation:yield curve and mktdata shall be have the same valuation date')
end

if ~(isa(vol,'cVol') || isa(vol,'cLocalVol'))
    error('modelLocalVolSimulation:localvol is missing')
end

if ~isa(security,'cSecurity')
    error('modelLocalVolSimulation:security is missing')
end

if ~isa(model,'cModelX')
    error('modelLocalVolSimulation:modelX is missing')
end

if ~strcmpi(vol.VolType,'FlatVol')
    error('modelLocalVolSimulation:only FlatVol is supported now')
end

if ~strcmpi(mktdata.Type,'FORWARD')
    error('modelLocalVolSimulation:only forward type mktdata is supported')
end

%2.simulation paths
if ~strcmpi(security.SecurityName,'EUROPEAN')
    error('modelLocalVolSimulation:only EUROPEAN is supported')
end

maturity = security.ExpiryDate;
settle = yc.ValuationDate;
if model.UseBusinessCalendar
    bdays = gendates('fromdate',settle,'todate',maturity);
    dt = 1/252;
else
    bdays = datenum(settle):1:datenum(maturity);
    bdays = bdays';
    dt = 1/365;
end
nperiods = size(bdays,1)-1;

fwds = zeros(nperiods+1,1);
for i = 1:nperiods+1
    fwds(i) = mktdata.MktDataFwd(bdays(i),yc);
end

s0 = mktdata.Spot;
sigma = vol.getVol;
mdl = gbm(0,sigma,'startstate',s0);
nsims = model.NumSims;
nruns = model.NumRuns;

paths = cell(nruns,1);
z = cell(nruns,1);
for i = 1:nruns
    rng(i);
    if strcmpi(model.VarianceReduction,'Antithetic')
        rv1 = randn(nperiods+1,0.5*nsims);
        rv = [rv1,-rv1];
        Z = zeros(size(rv,1),1,size(rv,2));
        for j = 1:size(rv,1)
            Z(j,:) = rv(j,:);
        end
        [sims,times,z{i}] = mdl.simBySolution(nperiods,'ntrials',nsims,...
        'deltatime',dt,...
        'Z',Z);
    else
        [sims,times,z{i}] = mdl.simBySolution(nperiods,'ntrials',nsims,...
        'deltatime',dt);
    end
    
    temp = squeeze(sims);
    adj = mean(temp,2)-fwds;
    path = temp;
    for j = 1:nperiods+1
        path(j,:) = temp(j,:)-adj(j);
    end
    paths{i} = path;
    
    
    
end




    


end