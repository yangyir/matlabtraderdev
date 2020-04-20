function [] = refresh(obj,varargin)
%cMDEOptBBG
    if ~obj.conn_.ds_.isconnection, return;end
    
    nu = size(obj.underliers_,1);
    no = size(obj.options_,1);
    if mod(no,2) ~= 0, error('cMDEOptBBG:refresh:number of options shall be even');end
    
    predate = getlastbusinessdate;
    if predate == today && hour(now) >=15
        predate = businessdate(predate,-1);
    end
    
    for i = 1:nu
        opt_c_exp = zeros(no/2,1);
        opt_p_exp = zeros(no/2,1);
        k = zeros(no/2,1);
        count_c = 0;
        count_p = 0;
        for j = 1:no
            if ~strcmpi(obj.underliers_{i},[obj.options_{j}(1:6),' CH Equity']), continue;end
            if strcmpi(obj.options_{j}(20),'C')
                count_c = count_c+1;
                opt_c_exp(count_c) = datenum(obj.options_{j}(11:18),'mm/dd/yy');
                k(count_c) = str2double(obj.options_{j}(21:end-7));
            elseif strcmpi(obj.options_{j}(20),'P')
                count_p = count_p+1;
                opt_p_exp(count_p) = datenum(obj.options_{j}(11:18),'mm/dd/yy');
            end
        end
        if count_c ~= count_p, error('cMDEOptBBG:refresh:call/put unmatched');end
        opt_c_exp = opt_c_exp(1:count_c);
        opt_p_exp = opt_p_exp(1:count_p);
        if length(unique(opt_c_exp)) ~= 1 || length(unique(opt_p_exp)) ~= 1
            error('cMDEOptBBG:refresh:only same expiry is supported');
        end
               
        k = k(1:count_c);
        %sort strikes
        k = sort(k);
        opt_c = cell(count_c,1);
        opt_p = cell(count_p,1);
        for j = 1:count_c
            opt_c{j} = [obj.underliers_{i}(1:6),' CH ',datestr(opt_c_exp(j),'mm/dd/yy'),' C',num2str(k(j)),' Equity'];
            opt_p{j} = [obj.underliers_{i}(1:6),' CH ',datestr(opt_c_exp(j),'mm/dd/yy'),' P',num2str(k(j)),' Equity'];
        end
        
        sec_list = [obj.underliers_{i};opt_c;opt_p];
        d = obj.conn_.ds_.getdata(sec_list,{'bid';'ask';'last_price'});
        iv2 = zeros(count_c,1);
        iv1 = zeros(count_p,1);
        pxuchg = zeros(count_c,1);
        bid_u = d.bid(1);ask_u = d.ask(1);mid_u = 0.5*(bid_u+ask_u);last_u = d.last_price(1);
        bid_c = d.bid(2:count_c+1);ask_c = d.ask(2:count_c+1);last_c = d.last_price(2:count_c+1);
%         mid_c = 0.5*(bid_c+ask_c);
        bid_p = d.bid(count_c+2:end);ask_p = d.ask(count_c+2:end);last_p = d.last_price(count_c+2:end);
%         mid_p = 0.5*(bid_p+ask_p);
        
        % arb-monitor
        bid_fwd = k+bid_c-ask_p;
        ask_fwd = k+ask_c-bid_p;
        tau = (opt_c_exp(1)-today)/365;
        fprintf('\n%s(%sd)\n',datestr(opt_c_exp(1),'yyyy-mm-dd'),num2str(tau*365));
        
        if max(bid_fwd) > min(ask_fwd)
            ishort = find(bid_fwd == max(bid_fwd),1,'first');
            ilong = find(ask_fwd == min(ask_fwd),1,'first');
            fprintf('box-arb exist:short synthetic fwd at strike %s and long at strike %s\n',...
                num2str(k(ishort)),num2str(k(ilong)));
        end
        
        for j = 1:no
            if ~strcmpi(obj.underliers_{i},[obj.options_{j}(1:6),' CH Equity']), continue;end
            carryinfo = struct('code',obj.options_{j},...
                'date2',datestr(predate,'yyyy-mm-dd'),...
                'spot2',obj.spotyesterday_(j),...
                'fwd2',obj.fwdyesterday_(j),...
                'premium2',obj.pvcarryyesterday_(j),...
                'iv2',obj.impvolcarryyesterday_(j),...
                'thetacarry',obj.thetacarryyesterday_(j),...
                'deltacarry',obj.deltacarryyesterday_(j),...
                'gammacarry',obj.gammacarryyesterday_(j),...
                'vegacarry',obj.vegacarryyesterday_(j));
            if strcmpi(obj.options_{j}(20),'C')
                for jj = 1:count_c
                    if strcmpi(obj.options_{j},opt_c{jj})
                        break
                    end
                end
%                 rtprbd = pnlriskbreakdownbbg2(carryinfo,[bid_c(jj),ask_c(jj),bid_p(jj),ask_p(jj)],[bid_u,ask_u]);
                if ~isnan(last_c(jj)) && ~isnan(last_p(jj))
                    rtprbd = pnlriskbreakdownbbg2(carryinfo,[last_c(jj),last_p(jj)],last_u);
                    obj.deltacarry_(j) = rtprbd.deltacarry;
                    obj.gammacarry_(j) = rtprbd.gammacarry;
                    obj.thetacarry_(j) = rtprbd.thetacarry;
                    obj.vegacarry_(j) = rtprbd.vegacarry;
                    obj.impvol_(j) = rtprbd.iv2;
                    iv2(jj) = rtprbd.iv2;
                    iv1(jj) = rtprbd.iv1;
                    pxuchg(jj) = last_u/carryinfo.spot2-1;
                    obj.rtprbd_{j} = rtprbd;
                end
            else
                for jj = 1:count_c
                    if strcmpi(obj.options_{j},opt_p{jj})
                        break
                    end
                end
%                 rtprbd = pnlriskbreakdownbbg2(carryinfo,[bid_c(jj),ask_c(jj),bid_p(jj),ask_p(jj)],[bid_u,ask_u]);
                if ~isnan(last_c(jj)) && ~isnan(last_p(jj))
                    rtprbd = pnlriskbreakdownbbg2(carryinfo,[last_c(jj),last_p(jj)],last_u);
                    obj.deltacarry_(j) = rtprbd.deltacarry;
                    obj.gammacarry_(j) = rtprbd.gammacarry;
                    obj.thetacarry_(j) = rtprbd.thetacarry;
                    obj.vegacarry_(j) = rtprbd.vegacarry;
                    obj.impvol_(j) = rtprbd.iv2;
                    iv2(jj) = rtprbd.iv2;
                    iv1(jj) = rtprbd.iv1;
                    pxuchg(jj) = last_u/carryinfo.spot2-1;
                    obj.rtprbd_{j} = rtprbd;
                end
            end
        end
        
%         marked_fwd = mean([bid_fwd;ask_fwd]);
        
%         r = 0.025;
%         for j = 1:count_c
%             iv_c(j) = blkimpv(marked_fwd,k(j),r,tau,mid_c(j),[],[],{'call'});
%             iv_p(j) = blkimpv(marked_fwd,k(j),r,tau,mid_p(j),[],[],{'put'});
%         end
    
        fprintf('%10s','bid(c)');fprintf('%10s','ask(c)');
        fprintf('%10s','strike');
        fprintf('%10s','bid(p)');fprintf('%10s','ask(p)');
        fprintf('%10s','ivm');
        fprintf('%10s','ivmchg');
        fprintf('%10s','spot(m)');
        fprintf('%10s','spotchg');
        fprintf('%10s','bid_fwd');
        fprintf('%10s','ask_fwd');
        fprintf('\n');
        for j = 1:count_c
            if isnan(bid_c(j)), continue;end
            fprintf('%10s',num2str(bid_c(j)));
            fprintf('%10s',num2str(ask_c(j)));
            fprintf('%10s',num2str(k(j)));
            fprintf('%10s',num2str(bid_p(j)));
            fprintf('%10s',num2str(ask_p(j)));
            fprintf('%9.1f%%',iv2(j)*100);
            fprintf('%9.1f%%',(iv2(j)-iv1(j))*100);
            fprintf('%10s',num2str(mid_u));
            fprintf('%9.1f%%',pxuchg(j)*100);
            fprintf('%10s',num2str(bid_fwd(j)));
            fprintf('%10s',num2str(ask_fwd(j)));
            fprintf('\n');
        end
        
        if nu == 1
            figure(10);
            subplot(211);
            idx = iv1 ~= 0;
            plot(k(idx),iv1(idx),'-');hold on;
            if pxuchg(1) > 0
                color = 'r';
                plot(k(idx),iv2(idx),'r-');
            else
                color = 'g';
                plot(k(idx),iv2(idx),'g-');
            end
            hold off;
            xlabel('strike');ylabel('vol');
            %
            subplot(212);

            bar(k(idx),iv2(idx)-iv1(idx),color);
            xlabel('strike');ylabel('spread');
        
        end
    end
    
end