function [ret,e,msg] = condshortopen(strategy,code_ctp,condpx,lots,varargin)
%cStrategy
   p = inputParser;
   p.CaseSensitive = false;p.KeepUnmatched = false;
   p.addParameter('signalinfo',{},@isstruct);
   p.parse(varargin{:});
   signalinfo = p.Results.signalinfo;
   
   if isempty(strategy.timer_) || strcmpi(strategy.timer_.running,'off')
        ret = 0;
        e = [];
        msg = sprintf('%s:condshortopen:strategy is not running...',class(strategy));
        fprintf('%s\n',msg);
        return
   end
    
   if ~ischar(code_ctp)
        ret = 0;
        e = [];
        msg = sprintf('%s:condshortopen:invalid order code...',class(strategy));
        fprintf('%s\n',msg);
        return
   end
    
   if lots <= 0 
        ret = 0;
        e = [];
        msg = sprintf('%s:condshortopen:invalid order volume...',class(strategy));
        fprintf('%s\n',msg);
        return
   end
    
   isopt = isoptchar(code_ctp);
   isopt2 = isa(strategy,'cStratOptMultiFractal');
   instrument = code2instrument(code_ctp);

   if strcmpi(strategy.mode_,'realtime') || strcmpi(strategy.mode_,'demo')
       ordertime = now;
   else
       ordertime = strategy.getreplaytime;
   end
   
   if ~instrument.isable2trade(ordertime)
       ret = 0;
       e = [];
       msg = sprintf('%s:condshortopen:non-trableable time for %s...',class(strategy),code_ctp);
       fprintf('%s\n',msg);
       return
   end
   
   if strcmpi(strategy.mode_,'realtime') || strcmpi(strategy.mode_,'demo')
        if isopt || isopt2
            q = strategy.mde_opt_.qms_.getquote(code_ctp);
        else
            q = strategy.mde_fut_.qms_.getquote(code_ctp);
        end
        if isempty(q)
            ret = 0;
            e = [];
            msg = sprintf('%s:condshortopen:%s quote not found...\n',class(strategy),code_ctp);
            fprintf('%s\n',msg);
            return
        end
        bidpx = q.bid1;
    elseif strcmpi(strategy.mode_,'replay')
        if isopt
            error('%s:condshortopen:not implemented yet for option in replay mode',class(strategy))
        else
            try
                if isopt2
                    tick = strategy.mde_opt_.getlasttick(code_ctp);
                else
                    tick = strategy.mde_fut_.getlasttick(code_ctp);
                end
                bidpx = tick(2);
            catch err
                ret = 0;
                e = [];
                msg = sprintf('%s',err.message);
                fprintf('%s\n',msg);
                return
            end
        end
   end
   
   %note:condition short open holds in case the condpx < bidpx
   if condpx > bidpx
       ret = 0;
       e = [];
       msg = sprintf('%s:condshortopen:conditional price is higher than the market price...\n',class(strategy));
       fprintf('%s\n',msg);
       return
   else
       if isopt2 && ~isopt
           flag = 1;
       else
           [flag,errmsg] = strategy.riskcontrol2placeentrust(code_ctp,'price',condpx,'volume',lots,'direction',-1);
       end
       if flag
           cs = instrument.contract_size;
           if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
               cs = cs/100;
           end
           offset = 1;
           e = Entrust;
           e.fillEntrust(1,code_ctp,-1,condpx,lots,offset,code_ctp);
           e.multiplier = cs;
           if ~isopt, e.assetType = 'Future';end
           e.time = ordertime;
           e.date = floor(ordertime);
           if ~isempty(signalinfo)
               e.signalinfo_ = signalinfo;
           end
           msg = sprintf('%s placed conditional short open entrust with code:%8s,price:%6s,amount:%3d',...
               datestr(e.time,'yyyymmdd HH:MM:SS'),...
               code_ctp,num2str(condpx),lots);
           strategy.helper_.condentrustspending_.push(e);
           fprintf('%s\n',msg);
           ret = 1;
       else
           ret = 0;
           e = [];
           msg = errmsg;
       end
   end
   
end