function [] = print(obj,varargin)
%cETFWatcher
    obj.printmarket(varargin{:});
    %
    obj.printsignal;
    %
    obj.printtrade;

end