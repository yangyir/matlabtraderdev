function c = bbgconnect(varargin)
%return a bloomberg connection instance in matlab
if nargin < 1
    debug = 0;
else
    debug = 1;
end

path = 'C:\blp\APIv3\JavaAPI\v3.8.8.2\lib\blpapi3.jar';
flag = dir(path);
if isempty(flag)
    error('Bloomberg application not installed!')
end

pathList = javaclasspath('-dynamic');
if isempty(pathList)
    javaaddpath(path);
    if debug
        fprintf('\tbloomberg java dynamic path added!\n');
    end
else
    %the path has been added already
    flag = 0;
    for i = 1:length(pathList)
        if strcmpi(pathList{i,1},path)
            flag = 1;
            if debug
                fprintf('\tbloomberg java dynamic path found!\n');
            end
            break
        end
    end
    if flag ~= 1
        javaaddpath(path);
        if debug
            fprintf('\tbloomberg java dynamic path added!\n');
        end
    end
end

answer = who('c');
if isempty(answer)
    c = blp;
end


end