function [flag] = hasfileindirectory(directory,filename)
    listing = dir(directory);
    n = size(listing,1);
    
    flag = false;
    for i = 1:n
        if strcmpi(listing(i).name,filename)
            flag = true;
            break
        end
    end
    
end