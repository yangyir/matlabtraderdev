function obj = init(obj,varargin)
%bkcButterfly
    init@bkcVanilla(obj,varargin{:});
    
    obj.name_ = 'butterfly';
    
    if length(obj.strike_) ~= 3
        error('%s:3 strikes required for butterfly',class(obj))
    end
    
    if obj.strike_(1)+obj.strike_(3)-2*obj.strike_(2) ~= 0
        error('%s:invalid strikes, pls check',class(obj))
    end
    
end