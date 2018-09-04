classdef cWatcher < handle
    %watcher class to monitor the futures.options traded in exchange in
    %China
    properties
        singles@cell    %single underliers to watch
        types@cell      %single underlier types, i.e. futures,option and etc
        pairs@cell      %pairs underliers to watch (long/short pair)
        structs@cell    %structs underliers to watch (more than 2 underliers)
        
        conn@char       %data source connection, i.e. bloomberg,wind or CTP
        ds@cDataSource
        %
        qs@cell         %quotes of single
        qp@cell         %quotes of pair
        qt@cell         %quotes of structs
        %
        ws@cell         %weights of structs
        
        underliers@cell %option underliers
        
        calcgreeks@logical = true
        
    end
    
    properties (Hidden = true)
        singles_w@cell
        singles_b@cell
        singles_ctp@cell
        %
        pairs_w@cell
        pairs_b@cell
        pairs_ctp@cell
        %
        structs_w@cell
        structs_b@cell
        structs_ctp@cell
        %
        underliers_w@cell
        underliers_b@cell
        underliers_ctp@cell
        
    end
    
    methods 
        function ds_ = get.ds(obj)
            if strcmpi(obj.conn,'wind')
                if ~isa(obj.ds,'cWind')
                    ds_ = cWind;
                    obj.ds = ds_;
                else
                    ds_ = obj.ds;
                end
            elseif strcmpi(obj.conn,'bloomberg')
                if ~isa(obj.ds,'cBloomberg')
                    ds_ = cBloomberg;
                    obj.ds = ds_;
                else
                    ds_ = obj.ds;
                end
            elseif strcmpi(obj.conn,'ctp')
                if ~isa(obj.ds,'cCTP')
                    %default values
                    ds_ = cCTP.citic_kim_fut;
                    %note:20180904we are doing login here anymore
%                     if ~ds_.isconnect
%                         ds_.login;
%                     end
                    obj.ds = ds_;
                else
                    ds_ = obj.ds;
                end
            elseif strcmpi(obj.conn,'local')
                if ~isa(obj.ds,'cLocal')
                    ds_ = cLocal;
                    obj.ds = ds_;
                else
                    if isempty(obj.ds.ds_)
                        obj.ds.ds_ = getenv('DATAPATH');
                    end
                    ds_ = obj.ds;
                end
            else
                ds_ = {};
            end
        end
        %end of get.ds
               
    end
    
    methods
        [] = addsingle(obj,singlestr)
        [] = addsingles(obj,singlearray)
        n = countsingles(obj)
        %
        [] = addpair(obj,pairstr)
        [] = addpairs(obj,pairarray)
        n = countpairs(obj)
        %
        [] = addstruct(obj,structstr,weights)
        [] = addstructs(obj,structarray)
        n = countstructs(obj)
        %
        [] = removesingle(obj,singlestr)
        [] = removepair(obj,pairstr,keepsingle)
        [] = removestruct(obj,structstr,keepsingle)
        [] = removeall(obj)
        [] = removesingles(obj,singlearray)
        [] = removepairs(obj,pairarray)
        [] = removestructs(obj,structarray)
        %
        [flag,idx] = hassingle(obj,singlestr)
        [flag,idx] = haspair(obj,pairstr)
        [flag,idx] = hasstruct(obj,structstr)
        %
        [] = refresh(obj,timestr)
        quotes = getquotes(obj,timestr)
        quote = getquote(obj,codestr)
        %
        [] = close(obj)
        flag = isconnect(obj)
        [] = printquotes(obj)
        
    end
    
    methods (Access = private)
        
        [] = init_quotes(obj)
        quotes = getquotes_wind(obj)
        quotes = getquotes_bbg(obj)
        quotes = getquotes_ctp(obj)
        quotes = getquotes_local(obj,timestr)
        quotes_pair = quotessingle2pair(obj)
        
        [] = addunderlier(obj,underlierstr)
        [flag,idx] = hasunderlier(obj, underlierstr)
        [] = removeunderlier(obj,underlierstr)
        n = countunderliers(obj)
        
    end
    
end