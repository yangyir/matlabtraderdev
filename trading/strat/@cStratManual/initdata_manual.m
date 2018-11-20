function [] = initdata_manual(obj)
%cStratManual
    if ~obj.usehistoricaldata_, return; end
    
    obj.mde_fut_.initcandles;
    
end