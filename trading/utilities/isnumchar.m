function flag = isnumchar(str)
if ~ischar(str)
    error('isnumchar:input type of char required')
end

flag = true;

for i = 1:length(str)
    switch str(i)
        case {'0','1','2','3','4','5','6','7','8','9'}
            flag = true;
        otherwise
            flag = false;
            return
    end
end

end