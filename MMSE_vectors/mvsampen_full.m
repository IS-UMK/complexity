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
mm=max(M);
mtau=max(tau);
nn=mm*mtau;


[nvar,nsamp]=size(ts);
N=nsamp-nn;
A=embd(M,tau,ts);%all the embedded vectors are created
y=pdist(A,'chebychev');%infinite norm is calculated between all possible pairs

% original code
%{
[r1,c1,v1]= find(y<=r);% threshold is implemented
p1=numel(v1)*2/(N*(N-1));%the probability that two templates of length m are closed within the tolerance r
clear  y r1 c1 v1 A;
%}
p1=numel(find(y<=r))*2/(N*(N-1));
clear y A;
 
M=repmat(M,nvar,1);
I=eye(nvar);
M=M+I;

B=[];

% number of match templates of length m+1 closed within the tolerance r where m=sum(M) is calculated afterwards
for h=1:nvar
Btemp=embd(M(h,:),tau,ts);
B=vertcat(B,Btemp);% all the delay embedded vectors of all the subspaces of dimension m+1 is concatenated into a single matrix
Btemp=[];
end
z=pdist(B,'chebychev'); %now comparison is done between subspaces
% original code
%{
[r2,c2,v2]= find(z<=r);
p2=numel(v2)*2/(nvar*N*(nvar*N-1));
clear  z r2 c2 v2 B;
%}
p2=numel(find(z<=r))*2/(nvar*N*(nvar*N-1));
clear z B;

e=log(p1/p2);


