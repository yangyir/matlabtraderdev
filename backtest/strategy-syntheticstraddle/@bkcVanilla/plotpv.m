function [] = plotpv(obj)
%bkcVanilla
    if isempty(obj.pvs_),return;end
    figure(1);
    subplot(211);plot(obj.pvs_);title([obj.name_,' pv']);xlabel('time points');
    subplot(212);plot(obj.S_);title('spot');xlabel('time point');
end