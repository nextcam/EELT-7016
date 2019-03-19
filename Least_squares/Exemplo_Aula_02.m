%   Estimador dos m�nimos quadrados recursivo

%     aplicado a uma planta de segunda ordem

clear all; clc

nit = input(' Quantas itera��es ? ');

for i=1:nit                      
    
    % Gerar sinais de entrada (PRBS) e ru�do

if rand>0.5

u(i)=1;

else

u(i)=-1;

end

end

e = u*0.01;

p =1000*eye(4,4);

teta = [0;0;0;0];   % Condi��es iniciais (NULAS)

for t=1:4

y(i)=0;  erro(t)=0;    

a1(t)=teta(1);  a2(t)=teta(2);  b0(t)=teta(3);  b1(t)=teta(4);

end

v = 1.5144;

for t = 4:nit                                  
    % Itera��o da simula��o

y(t) = v*y(t-1)-0.5506*y(t-2)+0.599*u(t-1)+0.163*u(t-2) + e(t);  

% Sa�da

if t > 100,   v = -0.8; end     % Mudan�a param�trica (sistema real)

fi=[-y(t-1);-y(t-2);u(t-1);u(t-2)];  % Vetor de regressores

erro(t)=y(t)-teta'*fi;          % Erro de estima��o

k=p*fi/(1+fi'*p*fi);          % Vetor de ganho (de Kalman)

teta=teta+k*erro(t);               % Vetor de par�metros

p=(p-k*fi'*p);                            % Matriz de covari�ncia

P(t) = trace(p);                 

% Soma dos elementos da diag. principal

a1(t)=teta(1);  a2(t)=teta(2); b0(t)=teta(3);  b1(t)=teta(4);

end

t=1:nit;                          

% Fazer o gr�fico  dos par�metros estimados

subplot(231),plot(t,a1(t)),title('a1'),xlabel('amostragem');

subplot(232),plot(t,a2(t)),title('a2'),xlabel('amostragem');

subplot(233),plot(t,b0(t)),title('b0'),xlabel('amostragem');

subplot(234),plot(t,b1(t)),title('b1'),xlabel('amostragem'); 

subplot(235),plot(t,P(t)),title('tra�o da matriz de cov. P'),xlabel('amostragem');