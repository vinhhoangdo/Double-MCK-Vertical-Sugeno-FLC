%%
% m2*x2.. =  (-(k2(x2-x1) + c2(x2.-x1.)) + F2)
% x1.. = (-(k1*x(1) + b1*x(3) +k2*(x(3)-x(4)) + c2*(x(4) - x(3)))+ F1)/m1
% dat x1 = x1; x3 = x1. 
%     x2 = x2; x4 = x2.
%%
function dxdt = odefun(t,x)
    global m1 m2 c1 c2 k1 k2 F1 F2 
    F10 = 3.987;
    dxdt_1 = x(3);
    dxdt_2 = x(4);
    dxdt_3 = (-(k1*x(1) + c1*x(3) +k2*(x(3)-x(4)) + c2*(x(4) - x(3)))+ F1 + F10)/m1;
    dxdt_4 = (-(k2*(x(2) - x(1)) + c2*(x(4) - x(3))) + F2)/m2;
    dxdt = [dxdt_1; dxdt_2; dxdt_3; dxdt_4];
end