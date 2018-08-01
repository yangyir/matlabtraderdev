function [] = withdrawentrusts(strategy,instrument,varargin)
    if nargin < 2
        %note:withdraw all pending entrusts, i.e.entrusts not associated
        %with any particular instrument
        code_ctp = 'all';
%         t = [];
%         direction = [];
%         offset = [];
%         price = [];
%         volume = [];
    else
        if ischar(instrument)
            code_ctp = instrument;
        elseif isa(instrument,'cInstrument')
            code_ctp = instrument.code_ctp;
        else
            error('cStrat:withdrawentrusts:invalid instrument input')
        end
%         p = inputParser;
%         p.CaseSensitive = false;p.KeepUnmatched = true;
%         p.addParameter('time',[],@isnumeric);
%         p.addParameter('direction',[],@isnumeric);
%         p.addParameter('offset',[],@isnumeric);
%         p.addParameter('price',[],@isnumeric);
%         p.addParameter('volume',[],@isnumeric);
%         
%         p.parse(varargin{:});
%         t = p.Results.time;
%         direction = p.Results.direction;
%         offset = p.Results.offset;
%         price = p.Results.price;
%         volume = p.Results.volume;
    end
    
    strategy.trader_.cancelorders(code_ctp,strategy.helper_,varargin{:});

%     strategy.helper_.refresh;

%     n = strategy.entrustspending_.count;
% 
%     for i = n:-1:1
%         e = strategy.entrustspending_.node(i);
%         f0 = strcmpi(e.instrumentCode,code_ctp) || strcmpi(code_ctp,'all');
%         if ~f0, continue;end
%         f1 = strategy.counter_.queryEntrust(e);
%         f2 = ~e.is_entrust_filled;
%         f3 = ~e.is_entrust_closed;
%         
%         if f1&&f2&&f3
%             ret = withdrawentrust(strategy.counter_,e);
% %             rmidx = i;
%             if ret
%                 fprintf('entrust: %d cancelled...\n',e.entrustNo);
%                 flag1 = strategy.counter_.queryEntrust(e);
%                 flag2 = e.is_entrust_closed;
%                 if flag1&&flag2
% %                     %the entrust is successfully cancelled and we shall
% %                     %first to remove it from the pending entrusts arrray
% %                     strategy.entrustspending_.removeByIndex(rmidx);
% %                     %and then we shall insert the entrust into the finished
% %                     %entrust array
% %                     strategy.entrustsfinished_.push(e);
%                     updateportfoliowithentrust(strategy,e);
%                 end
%             end
%         end
%     end
end
%end of withdrawentrusts
