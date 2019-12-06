function e=mvsampen_full(M,r,tau,ts)
% This function calculates multivariate sample entropy using the full multivariate approach
% Inputs:
 
% M - embedding vector parameter
% r - threshold scalar parameter 
% tau - time lag vector parameter
% ts - multivariate time series-a matrix of size nvarxnsamp

% Output:
% e- scalar quantity

%number of match templates of length m closed within the tolerance r where m=sum(M) is calculated first
A=embd(M,tau,ts);%all the embedded vectors are created
y=pdist(A,'chebychev');%infinite norm is calculated between all possible pairs
[~,~,v1]= find(y<=r);% threshold is implemented
p1=numel(v1)/length(y); %the probability that two templates of length m are closed within the tolerance r
clear  y  v1 A;

M=M+1;
% number of match templates of length m+1 closed within the tolerance r where m=sum(M) is calculated afterwards
B=embd(M,tau,ts);
z=pdist(B,'chebychev'); %now comparison is done between subspaces
[~,~,v2]= find(z<=r);
p2=numel(v2)/length(z);
clear  z  v2 B;

e=log(p1/p2);


