%choose atm call and put and OTM call/puts
codes = {'m1805-C-2800';'m1805-C-2850';'m1805-C-2900';...
    'm1805-P-2700';'m1805-P-2750';'m1805-P-2800'};
n = size(codes,1);
d = zeros(n,1);
g = zeros(n,1);
v = zeros(n,1);
t = zeros(n,1);
for i = 1:n
    [~,idx] = strat.instruments_.hasinstrument(codes{i});
    d(i,1) = strat.deltacarry_(idx);
    g(i,1) = strat.gammacarry_(idx);
    v(i,1) = strat.vegacarry_(idx);
    t(i,1) = strat.thetacarry_(idx);
end


%%
max_size = 100;
pr = 0.85;
target_d =  18000;
target_g = n*max_size*max(g)*pr;
target_v = n*max_size*max(v)*pr;

%% 用线性规划求解最优组合
% 引入辅助变量v
% 约束条件：
% delta'* x <= target_delta
% gamma'* x <= target_gamma
% vega'* x <= target_vega
% x <= v
% x >= -v
% f = theta'* x

N = length(d);

A = [d';g';v'];
b = [target_d;target_g;target_v;];
f = t';
lb = ones(N,1);
ub = max_size*ones(N,1);

x = linprog(f,A,b,[],[],lb,ub);

fprintf('\n');
d_total = d'*round(x);
g_total = g'*round(x);
v_total = v'*round(x);
t_total = t'*round(x);
fprintf('目标 delta:%4.0f; gamma:%4.0f; vega:%4.0f; theta:%4.0f\n',target_d,target_g,target_v,target_t);
fprintf('实现 delta:%4.0f; gamma:%4.0f; vega:%4.0f; theta:%4.0f\n',d_total,g_total,v_total,t_total);
for i = 1:n
    fprintf('%s volume:%4.0f\n',codes{i},-round(x(i)));
end

%%
c = CounterCTP.ccb_liyang_fut;
c.login;
%%
direction = -1;
offset = 1;
multi = 10;
base_size = 5;
loop_x = round(x);

%%
strat.mde_opt_.refresh;
strat.mde_fut_.refresh;
for i = 1:n
    q = strat.mde_opt_.qms_.getquote(codes{i});
    lots = min(base_size,loop_x(i));
    if lots <= 0, continue;end
    e = Entrust;
    e.fillEntrust(1,codes{i},direction,q.bid1,lots,offset,codes{i});
    e.multiplier = multi;
    ret = c.placeEntrust(e);    
end

loop_x = loop_x - base_size;
for i = 1:n
    if loop_x(i) <0, loop_x(i) = 0;end
end



