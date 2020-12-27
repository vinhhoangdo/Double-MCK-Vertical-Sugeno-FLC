clear all; close all; clc;
%%
%Create newfis("Name","Type","sugeno/mamdami") or create with sugfis
sys = newfis('SugenoFLC','FISType','sugeno')
% fis = sugfis("NumInputs",2,"NumOutputs",1)
%% Inputs
sys = addInput(sys,[-3 10],"Name","Error1");
sys = addMF(sys,"Error1","trimf",[-3 -3 3.5],'Name',"N");
sys = addMF(sys,"Error1","trimf",[-3 3.5 10],'Name',"Z");
sys = addMF(sys,"Error1","trimf",[2.5 10 10],'Name',"P");


sys = addInput(sys,[-0.3 0.3],"Name","Change_in_error1");
sys = addmf(sys,"Change_in_error1","trimf",[-0.3 -0.3 0],'Name',"N");
sys = addmf(sys,"Change_in_error1","trimf",[-0.3 0 0.3],'Name',"Z");
sys = addmf(sys,"Change_in_error1","trimf",[0 0.3 0.3],'Name',"P");


sys = addOutput(sys,[-20 25],"Name","Uscript",'MFType',"constant");
sys = addmf(sys,"Uscript","constant",-15.4,'Name',"NB");
sys = addmf(sys,"Uscript","constant",-7.25,'Name',"NS");
sys = addmf(sys,"Uscript","constant",2,'Name',"Z");
sys = addmf(sys,"Uscript","constant",8.25,'Name',"PS");
sys = addmf(sys,"Uscript","constant",16.4,'Name',"PB");

%% Add Rule-Base                 
% So the rule-base is interpreted as
% rulelist = [E CE U Weight &&=1;||=2)]
rulelist = [1 1 1 1 1; 1 1 2 1 1;1 2 1 1 1; 1 2 2 1 1;1 3 4 1 1;1 3 3 1 1;1 3 5 1 1;
            2 1 3 1 1;2 1 4 1 1; 2 1 5 1 1; 2 2 3 1 1; 2 2 4 1 1; 2 2 5 1 1;2 3 4 1 1; 2 3 3 1 1; 2 3 5 1 1;
            3 1 5 1 1; 3 1 4 1 1;3 1 3 1 1; 3 2 4 1 1; 3 2 3 1 1;3 2 3 1 1;3 3 3 1 1;3 3 4 1 1;3 3 5 1 1];

sys = addrule(sys,rulelist);
%%
global m1 m2 c1 c2 k1 k2 F1 F2 t
m1 = 1.01; m2 = 1.01; % mass
a1 = 100; a2 = 200;
k1 = 2*sin(a1*pi*t); k2 = 2*sin(a1*pi*t);
c1 = 2; c2 = 2;
F2 = 4;
% Initial states
x1 = 0; dx1 = 0; x2 = 0; dx2 = 0;
x0 = [x1 x2 dx1 dx2];
X = x0;
%Sample time
tsamp = 0.01;
t = 20;
T = 0;
Runing_time = t/tsamp; 
tspan = [0 tsamp];
ts = 0.01;
ref = 10; %reference
%PID
kp = 2; ki = 10; kd = 800;
for i = 1:Runing_time  
    time(i) = i*ts;
    tp = i*ts;
    k1 = 2*sin(a1*pi*tp);
    k2 = 2*sin(a1*pi*tp);
    if (i==1)
        e(1) = ref;
    else
        e(i) = ref - position(i-1);
    end
    if (i==1)
        erot(1) = 0;
    else
        erot(i) = e(i) - e(i-1);
    end
    if (i==1)
        usug(1) = 0;
        upid(1) = 0;
    else
        usug(i) = evalfis([e(i) erot(i)],sys);
        upid(i) = kp*e(i) + ki*(e(i) + e(i-1)) + kd*(e(i) - e(i-1));
    end
    u(i) = usug(i);
%     if(u(i) > 300)
%         u(i) = 250;
%     else (u(i) < -300)
%         u(i) = -250;
%     end
    FF(i) = u(i);
    F1 = FF(i);
    
    if (i==1)
        y(1) = 0;
    else
        [t,y] = ode45(@odefun,tspan,x0);
        x0 = y(length(y),:);
    end
    T = [T;i*tsamp];
    X = [X;x0];
    position(i) = X(i,1);
end
%% Plot step responce
for i = 1:Runing_time
    reference(i) = ref;
end
plot(time,reference,'-- b','LineWidth',2);
hold on;
plot(T,X(:,1),'r','LineWidth',2);
xlabel('Time(s)');
ylabel('System output');
%ylim([0 15]);
title('Response of the mass position using Fuzzy controller');
legend('Reference output','FLC');
grid on;
%ruleview(sys)
