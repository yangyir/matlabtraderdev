function [] = refresh(obj)
%cOps
    updateentrustsandbook(obj);
    %
    if obj.display_
        obj.printallentrusts
    end
    
end