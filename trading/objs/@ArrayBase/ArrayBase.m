classdef(Abstract) ArrayBase < handle
    %ARRAYBASE 数组基类（抽象类），一串ＸＸＸ放一起
    % 使用方法：
%         classdef DataArray < ArrayBase
%             node = DataClass  % 把node具体化成某个数据类
%             function set.node
    % ------------------------------------  
    % 程刚，20160204
    % cg, 20160224, 修改push方法，增加对第一个元素的处理
    % cg, 161017, 修改方法： clear_array(obj)
    % cg, 1703, 加入方法：  [obj] = insertByIndex(obj, i, onenode)
    
    
    properties
        latest@double   = 0 ;       % 
        capacity@double = 1000;     %
        isSorted        = 0;        % 升序1， 降序 -1， 无序 0.
    end
    
    % 抽象的，需要在子类中具体化
    properties(Abstract = true, SetAccess = public, GetAccess = public)
        node;    
    end
    
    
    properties(Hidden = true)
        headers@cell;
        table@cell;
%         data;
    end


    
    methods
        function [obj] = push(obj, node)
           
            lat = obj.latest;
            lat = lat + 1;            
            try
                if lat == 1 % 从空放入第一个，要特别处理
                    obj.node = node;
                else
                    obj.node(lat) = node;
                end
                obj.latest = lat;
            catch e
                fprintf('push(node)失败：%s', class(node));
            end
        end
        
        
          % 在i位置插入onenode， 原i:end位顺次后移
        function [obj] = insertByIndex(obj, i, onenode)
            
            lat = obj.latest;
%             lat = lat + 1;
            if i<=0
                error('插入位i<=0,');
                return;
            end
                
            if i> lat % 
                warning('插入位比原array长，在最后插入');
                obj.push(onenode);
            else
                obj.node(i+1:lat+1) = obj.node(i:lat);
                obj.node(i) = onenode;                
                obj.latest = lat + 1;
            end
            
        end
         
        
        function [obj] = push_front(obj, nodes)
            L = length(nodes);
            lat = obj.latest;
            try
                if lat == 0
                    obj.node = nodes;
                else
                    obj.node = [nodes, obj.node];
                end
                obj.latest = lat + L;
            catch e
                fprintf('push(node)失败：%s', class(nodes));
            end
        end
        
        function [ node ] = removeByIndex(obj, i) 
            
            % 用catch把一切错误都打包了: isempty, isnan, 超出索引,etc
            try                
                % 移除
                node = obj.node(i);
                obj.node(i) = [];
                obj.latest = obj.latest - 1;
            catch e
                warning('Array.removeByIndex操作失败');
            end
            
        end
        
        
      
        % 清空整个array， 但对象依然留着
        function [obj] = clear_array(obj)
            try
                obj.latest = 0;
%                 obj.node = [];
                classname = class(obj.node);
                eval(['obj.node = ' classname ';']);
            catch
                warning('ArrayBase.clear_array操作失败');
            end
        end
        
        % 判断是否为空
        function [ret] = isempty(obj)
            if obj.latest == 0
                ret = true;
            else                
                ret = false;
            end
        end
        
        % 逐一打印node，需要定义了node.println方法
        [txt] = print(obj);
        
        [ table, flds ] = toTable(obj, start_pos, end_pos);
        [ filename ] = toExcel(obj, filename, sheetname, start_pos, end_pos);        
        
        % 向已有的obj读入excel数据，className的问题比较好解决
        [obj] = loadExcel(obj, filename, sheetname);
        
        
    end
    
end

