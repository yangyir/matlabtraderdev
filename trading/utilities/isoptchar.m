function [flag,opt_type,opt_strike,underlierstr,opt_expiry] = isoptchar(codestr)
%check whether input string is a valid string for listed option traded in
%zhengzhou, dalian, shanghai etc

%NOTE:the current implementation is only valid for comdty option traded in
%zhengzhou and dalian and shall be extended for ETF option traded in
%shanghai stock exchange and other options

%note:the format of comdty options traded in dalian is as of: future ctp
%code-option type-option strike, e.g.m1801-C-2700, c1905-C-1900
%however, the format of comdty option traded in zhengzhou is as of: future
%ctp code option type option strike, e.g.SR801C6600
%
%the format of copper option traded in shanghai is as of:future ctop code
%option type option strike, e.g.cu1901C50000, ru1905c11750


flag = false;
opt_type = '';
opt_strike = [];
underlierstr = '';
opt_expiry = [];

if ~ischar(codestr), return; end

for i = 1:length(codestr)
    if isnumchar(codestr(i))
        break
    end
end

idx = i-1;
if idx == 0, return; end

assetshortcode = codestr(1:idx);
if strcmpi(assetshortcode,'IO')
    assetshortcode = 'IF';
end

tenor = codestr(idx+1:end);

if length(tenor) <= 4, return; end

[~,~,~,codelist,exlist]=getassetmaptable;
for i = 1:size(codelist)
    if strcmpi(assetshortcode,codelist{i})
        %we need to use the capital letter for 'C' and 'P'
        idx = strfind(upper(tenor),'C');
        
        if isempty(idx)
            idx = strfind(upper(tenor),'P');
            if isempty(idx), return; end
            opt_type = 'P';
        else
            opt_type = 'C';
        end
                
        if strcmpi(exlist{i},'.DCE')
            underlierstr = [assetshortcode,tenor(1:4)];
            mmnum = str2double(tenor(3:4));
            yynum = 2000+str2double(tenor(1:2));
            %dalian:the expiry date of the option is the 5th business date of the
            %pre-month of the underlier future'expiry
            if mmnum == 1
                mmnum_opt = 12;
                yynum_opt = yynum - 1;
            else
                mmnum_opt = mmnum - 1;
                yynum_opt = yynum;
            end
            opt_expiry = getbusinessdate(yynum_opt,mmnum_opt,5,1);
        elseif strcmpi(exlist{i},'.SHF')
            underlierstr = [assetshortcode,tenor(1:4)];
            mmnum = str2double(tenor(3:4));
            yynum = 2000+str2double(tenor(1:2));
            %shanghai:the expiry date of the option is on the last 5 business date of the
            %pre-month of the underlier futures' exiry
            if mmnum == 1
                mmnum_opt = 12;
                yynum_opt = yynum - 1;
            else
                mmnum_opt = mmnum - 1;
                yynum_opt = yynum;
            end
            opt_expiry = getbusinessdate(yynum_opt,mmnum_opt,5,-1);
        elseif strcmpi(exlist{i},'.CFE')
            underlierstr = [assetshortcode,tenor(1:4)];
            %equity index option:the expiry date of the option is on the
            %3rd friday of the month, the same as the futures
            fut = code2instrument(underlierstr);
            opt_expiry = fut.last_trade_date1;
            %
        else
            underlierstr = [assetshortcode,tenor(1:3)];
            mmnum = str2double(tenor(2:3));
            if str2double(tenor(1)) == 8 || str2double(tenor(1)) == 9
                yynum = 2010+str2double(tenor(1));
            else
                yynum = 2020+str2double(tenor(1));
            end
            if ~isempty(strfind(underlierstr,'SR'))
                %zhengzhou:the expiry date of the sugar option is the last 5th business date of
                %the month which is two month before the underlier future's expiry
                if mmnum == 2
                    mmnum_opt = 12;
                    yynum_opt = yynum - 1;
                elseif mmnum == 1
                    mmnum_opt = 11;
                    yynum_opt = yynum - 1;
                else
                    mmnum_opt = mmnum - 2;
                    yynum_opt = yynum;
                end
                opt_expiry = getbusinessdate(yynum_opt,mmnum_opt,5,-1);
            elseif ~isempty(strfind(underlierstr,'CF'))
                %zhengzhou:the expiry date of the cotton option is the 3rd business date of
                %the pre-month of the underlier future's expiry
                if mmnum == 1
                    mmnum_opt = 12;
                    yynum_opt = yynum - 1;
                else
                    mmnum_opt = mmnum - 1;
                    yynum_opt = yynum;
                end
                opt_expiry = getbusinessdate(yynum_opt,mmnum_opt,3,1);     
            end
        end
        
        idx = idx+1;
        for j = idx:length(tenor)
            if isnumchar(tenor(j)),break;end
        end
        opt_strike = str2double(tenor(j:end));
        flag = true;
        
        break

    end
end


end