close all;

%example to infer GARCH Model Conditional Variance
%infer conditional variance from a GARCH(1,1) model with known
%coefficients. When you use, and then do not use presample data, compare
%the results from 'infer'

Mdl = garch('Constant',5e-06,'GARCH',0.9,'ARCH',0.05);
rng default;
[vSim,ySim] = simulate(Mdl,101);
y0 = ySim(1);
v0 = vSim(1);
y = ySim(2:end);
v = vSim(2:end);

figure
subplot(2,1,1)
plot(v)
title('Conditional Variance')
subplot(2,1,2)
plot(y)
title('Innovations')

%Infer the conditional variance of y without using presample data. Compare
%them to the known (simulated) conditional variance
vInfer = infer(Mdl,y);

figure
plot(1:length(v),v,'r','LineWidth',2)
hold on
plot(1:length(vInfer),vInfer,'k:','LineWidth',1.5)
legend('Simulated','Inferred','Location','NorthEast')
title('Inferred Conditional Variances - No Presamples')
hold off
%notice the transient response(discrepancy) in the early time periods due
%to the absense of presample data

%Infer conditional variances using the set-aside presample innovation, y0.
%Compare them to the known (simulated) conditional variance
vE = infer(Mdl,y,'E0',y0);

figure;
plot(1:length(v),v,'r','LineWidth',2)
hold on
plot(1:length(vE),vE,'k:','LineWidth',1.5)
legend('Simulated','Inferred','Location','NorthEast')
title('Inferred Conditional Variances - Presample E')
hold off
%there is a slightly reduced transient response in the early time periods.

%Infer conditional variances using the set-aside presample conditional
%variance,v0.Compare them to the known (simulated) conditional variances
vO = infer(Mdl,y,'V0',v0);

figure
plot(v)
plot(1:length(v),v,'r','LineWidth',2)
hold on
plot(1:length(v0),vO,'k:','LineWidth',1.5)
legend('Simulated','Inferred','Location','NorthEast')
title('Inferred Conditional Variances - Presample V')
hold off

%There is a much smaller transient response in the early time periods
%Infer conditional variance using both presample innovation and conditional
%variance.When you use sufficient presample innovations and conditional 
%variances, the inferred conditional variances are exact
vEO = infer(Mdl,y,'E0',y0,'V0',v0);

figure
plot(v)
plot(1:length(v),v,'r','LineWidth',2)
hold on
plot(1:length(vEO),vEO,'k:','LineWidth',1.5)
legend('Simulated','Inferred','Location','NorthEast')
title('Inferred Conditional Variances - Presamples')
hold off