clear all;  clc; close all

fprintf('M�todo dos m�nimos quadrados em batelada\n\n');

load dryer2;          % l�dados do hairdryer, u2e y

npts = size(u2,1); % n�mero de amostras a considera
u = u2;              % sinal de entrada npts x 1

y  = y2;               % sinal de sa�da   npts x 
Y   = [ ];  
fi   = [ ];
ordem = 2;