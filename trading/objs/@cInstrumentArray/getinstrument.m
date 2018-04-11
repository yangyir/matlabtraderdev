function list = getinstrument(obj,codestr)
    if ~obj.isvalid
        list = {};
        return
    end

    if nargin < 2
        list = obj.list_;
    else
        n = obj.count;
        for i = 1:n
            if strcmpi(obj.list_{i}.code_ctp,codestr)
                list = cell(1);
                list{1} = obj.list_{i};
                return
            end
        end
        list = {};
    end

end
%end of getinstrument