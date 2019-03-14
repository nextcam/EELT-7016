clear all;  clc; close all

fprintf('M�todo dos m�nimos quadrados em batelada\n\n');

load dryer2;          % l�dados do hairdryer, u2e y

npts = size(u2,1); % n�mero de amostras a considera
u = u2;              % sinal de entrada npts x 1

y  = y2;               % sinal de sa�da   npts x 
Y   = [ ];  
fi   = [ ];
ordem = 2;

for j = 1:npts

if j<=2

y1=y(2);  y2=y(1);  u1=u(2);  u2=u(1);

else

y1=y(j-1);  y2=y(j-2);  u1=u(j-1);  u2=u(j-2);

end

Y  = [Y; y(j)];

fi = [fi;-y1 -y2 u1 u2];

end

theta = inv(fi'*fi)*fi'*Y;

for i=1:size(theta,1)

fprintf('theta(%d) = %f\n',i, theta(i));

end

for t=1:ordem

yest(t) = y(t);     
yest2(t) = y(t);

end

a1 = theta(1); a2 = theta(2);  

b1 = theta(3); b2 = theta(4);

for t = ordem+1 : npts

yest(t) = -a1*yest(t-1)-a2*yest(t-2) + b1*u(t-1)+b2*u(t-2);

yest2(t) = -a1*y(t-1)-a2*y(t-2) + b1*u(t-1)+b2*u(t-2);

end

plot(y,'g');        hold on;

plot(yest,'r');      plot(yest2,'b'); 

ylabel ('sa�da');    xlabel ('amostra');

legend('real','prevista n passos � frente','prevista um passo � frente');