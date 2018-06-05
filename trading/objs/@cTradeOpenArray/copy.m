 function new = copy(obj)
    % copy() is for deep copy case.
    new = feval(class(obj));
    % copy all non-hidden properties
    p = properties(obj);
    for i = 1:length(p)
        new.(p{i}) = obj.(p{i});
    end
 end