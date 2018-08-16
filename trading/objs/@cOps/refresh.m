function [] = refresh(obj,varargin)
%cOps
    try
%         updateentrustsandbook(obj);
        updateentrustsandbook2(obj);
        %
        if obj.display_
            obj.printallentrusts
        end
    catch e
        msg = ['error:cOps:updateentrustsandbook:',e.message,'\n'];
        fprintf(msg);
    end
    
end