%节线法
%the knob-line method
%过溪桥中跨初始线形计算示例

%目前程序中的限制：
%1、吊杆间距一致
%2、不计算y坐标
%3、吊杆在横向也是竖直

%参考文献：
%1、自锚式悬索桥的力学特征和设计研究   刘涛
%2、用midas civil做悬索桥分析-实例解析.pdf
%文献2 P7(页码3) （地锚式悬索桥）将附属构件的荷载换算成集中荷载，加载吊杆下端节点上。
%主缆和吊杆的自重需要通过反复迭代计算才能确定（因为只有确定了主缆坐标位置才能确定重量）
%主缆荷载和加劲梁相比太小了，初步找形可以忽略不计。  ---林迪南

%solve函数计算示例
%syms x y real;
%[x,y]=solve(x^3+2*x*y-3*y^2-2,x^3-3*x*y+y^2+5);

%计算依据：莆田市绶溪公园一期过溪桥图纸（含变更内容）

%1#、2#塔顶塔顶ip点坐标：
%(25,-3.75,20.35),（95,3.75,20.35）

%跨中坐标:
%(60,-3.75,11.35),(60,3.75,11.35)

clear;clc;

saveFile='zCoor.txt';   %z坐标位置

nKnobs=15;  %结点数

%荷载作用下，悬索上每一点下垂的距离称为垂度（不严谨？）
f=9.00;   %中跨吊点垂度

%绶溪公园吊杆等间距
%d=zeros(1,nKnobs);  %吊杆间距：单位m
%for i=1:nKnobs
%   d(i)=5.0;
%end
d=5.0;

%恒荷载
%可以根据过溪桥主要材料数量表计算
%其中：
%主梁自重：141.35KN/m
%二期恒载:18.47+7.68
%索鞍自重、吊杆锚具自重、索夹自重若干（可忽略不计）

deadLoad=175.31;    %恒载,KN/m
Wsi=deadLoad*d/2;        %近似认为梁段之间的恒载由两根吊杆评分。 --林迪南理解
                       %结果：438.275 单位:kN

Wci=0;   %初步分析中，忽略主缆重量，3.75 单位:kN,主缆自重可忽略不计（林迪南理解）

syms Tx;   %水平力分量
z=sym('z',[1,nKnobs]);

%z(1)=20.35;     %对应节线法中z(0)
%z(15)=z(1);
%z(8)=(1/2)*(z(1)+z(15))-f;

%solve函数的左边
outputStr='Tx';    %输出变量初始化
for i=1:nKnobs
    outputStr=[outputStr ',z(' num2str(i) ')'];
end

%solve函数的右边
solveStr=['z(1)-20.35,z(15)-z(1),z(8)-((1/2)*(z(1)+z(15))-' num2str(f) ')'];

for i=1:nKnobs-2
    %solveStr=[solveStr ',Tx*(-1*((z(' num2str(i) ')-z(' num2str(i+1) '))/' num2str(d(i+1)) ')+(z(' num2str(i+1) ')-z(' num2str(i+2) '))/' num2str(d(i+2)) ')-(Wsi+Wci)'];
    solveStr=[solveStr ',Tx*(-1*((z(' num2str(i) ')-z(' num2str(i+1) '))/d)+(z(' num2str(i+1) ')-z(' num2str(i+2) '))/d)-(Wsi+Wci)'];
end

evelStr=['[' outputStr ']=solve(' solveStr ');'];

eval(evelStr);      %求解节线法方程组

%过溪桥eval(evelStr)示例：
%注:solve函数似乎不支持数组系数
%[Tx,z(1),z(2),z(3),z(4),z(5),z(6),z(7),z(8),z(9),z(10),z(11),z(12),z(13),z(14),z(15)]=solve( ...,
%    z(1)-20.35,z(15)-z(1),z(8)-((1/2)*(z(1)+z(15))-9.00),...,
%    Tx*(-1*((z(1)-z(2))/d(2))+(z(2)-z(3))/d(3))-(Wsi+Wci),...,
%    Tx*(-1*((z(2)-z(3))/d(3))+(z(3)-z(4))/d(4))-(Wsi+Wci), ...,
%    Tx*(-1*((z(3)-z(4))/d(4))+(z(4)-z(5))/d(5))-(Wsi+Wci), ...,
%    Tx*(-1*((z(4)-z(5))/d(5))+(z(5)-z(6))/d(6))-(Wsi+Wci), ...,
%    Tx*(-1*((z(5)-z(6))/d(6))+(z(6)-z(7))/d(7))-(Wsi+Wci), ...,
%    Tx*(-1*((z(6)-z(7))/d(7))+(z(7)-z(8))/d(8))-(Wsi+Wci), ...,
%    Tx*(-1*((z(7)-z(8))/d(8))+(z(8)-z(9))/d(9))-(Wsi+Wci), ...,
%    Tx*(-1*((z(8)-z(9))/d(9))+(z(9)-z(10))/d(10))-(Wsi+Wci) ,...,
%    Tx*(-1*((z(9)-z(10))/d(10))+(z(10)-z(11))/d(11))-(Wsi+Wci), ...,
%    Tx*(-1*((z(10)-z(11))/d(11))+(z(11)-z(12))/d(12))-(Wsi+Wci), ...,
%    Tx*(-1*((z(11)-z(12))/d(12))+(z(12)-z(13))/d(13))-(Wsi+Wci),...,
%    Tx*(-1*((z(12)-z(13))/d(13))+(z(13)-z(14))/d(14))-(Wsi+Wci),...,
%    Tx*(-1*((z(13)-z(14))/d(14))+(z(14)-z(15))/d(15))-(Wsi+Wci));
saveVar=double(z)';
save(saveFile,'saveVar','-ascii');
    

