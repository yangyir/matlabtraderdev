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
        [sellfwdlongspot,sellspotlongfwd,fwdbid,fwdask] = cpparb(obj,us{i});
        
        if obj.tradeflag_
            %
            if strcmpi(obj.countertype_,'ctp')
                c = obj.counterctp_;
            else
                c = obj.counterrh_;
            end
            %
            %first to check box-arbitrage
            k = obj.strikes_{i};
            maxfwdbid = max(fwdbid);
            minfwdask = min(fwdask);
            if maxfwdbid > minfwdask
                isell = find(fwdbid == maxfwdbid,1,'first');%short call and long put
                ibuy = find(fwdask == minfwdask,1,'last');%short put and long call
                if strcmpi(us{i}.exchange,'.DCE')
                    portfolio = {[us{i}.code_ctp,'-C-',num2str(k(isell))];...
                        [us{i}.code_ctp,'-P-',num2str(k(isell))];...
                        [us{i}.code_ctp,'-C-',num2str(k(ibuy))];...
                        [us{i}.code_ctp,'-P-',num2str(k(ibuy))]};
                else
                    portfolio = {[us{i}.code_ctp,'C',num2str(k(isell))];...
                        [us{i}.code_ctp,'P',num2str(k(isell))];...
                        [us{i}.code_ctp,'C',num2str(k(ibuy))];...
                        [us{i}.code_ctp,'P',num2str(k(ibuy))]};
                end
                volume = [-1;1;1;-1];
                try       
                    [es] = peast(c,obj,portfolio,abs(volume),sign(volume),ones(4,1));
                    for ies = 1:4
                        c.queryEntrust(es{ies});
                        if ~es{ies}.is_entrust_closed
                            %todo:if entrust is not filled
                        end                    
                    end
                catch
                end
                
            end
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