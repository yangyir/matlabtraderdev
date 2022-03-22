function [] = print(obj,varargin)
%cETFWatcher
    %
    obj.printsignal;
    %
    obj.printmarket(varargin{:});
    %
    obj.printtrade;

end