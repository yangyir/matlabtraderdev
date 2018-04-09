function [] = savequotes2mem(obj)
    obj.quotes_ = obj.qms_.getquote;
end
%end of savequotes2mem