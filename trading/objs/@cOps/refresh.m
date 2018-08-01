function [] = refresh(obj)
%cOps
    try
        updateentrustsandbook(obj);
        %
        if obj.display_
            obj.printallentrusts
        end
    catch e
        msg = ['error:cOps:updateentrustsandbook:',e.message,'\n'];
        fprintf(msg);
    end
    
end