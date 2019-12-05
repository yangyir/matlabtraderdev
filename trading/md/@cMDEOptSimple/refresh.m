function [] = refresh(obj,varargin)
%cMDEOptSimple
    if ~isempty(obj.qms_)
        if strcmpi(obj.mode_,'realtime')
            obj.qms_.refresh;
        else
            return
        end
        
        fprintf('%s mdeoptsimple runs......\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
    end

    n = obj.underliers_.count;
    us = obj.underliers_.getinstrument;
    for i = 1:n
        [sellfwdlongspot,sellspotlongfwd] = cpparb(obj,us{i});
        if obj.tradeflag_
            threshold = obj.threshold_(i);
            if ~isempty(find(sellfwdlongspot>=threshold,1,'first'))
                
                
                
            end
            if ~isempty(find(sellspotlongfwd>=threshold,1,'first'))
            end
        end
        
        
        fprintf('\n');
    end
    
    
        
        
        
    
    
end
%end of refresh