function [tt] = full_to_tt(b,varargin)
%[TT]=FULL_TO_TT(B,EPS)
%[TT]=FULL_TO_TT(B,EPS,RMAX)
%This subroutine gets a full d-dimensional tensor B as an input,
%accuracy EPS is given, and TT approximation with 
%guaranteed precision ||TT-B||_EPS <= EPS*||B||_F is computed, with
%almost optimal ranks. The norm of the cores are balanced for
%enhanced stability
%
%
% TT Toolbox 1.1, 2009-2010
%
%This is TT Toolbox, written by Ivan Oseledets, Olga Lebedeva
%Institute of Numerical Mathematics, Moscow, Russia
%webpage: http://spring.inm.ras.ru/osel
%
%For all questions, bugs and suggestions please mail
%ivan.oseledets@gmail.com
%---------------------------
if ( nargin == 2 )
  eps=varargin{1};
  rmax=numel(b);
elseif (nargin == 3)
  rmax=varargin{2};
  if ( isempty(rmax) ) 
      rmax=numel(b);
  eps=varargin{1};
  end
end
    
arr=b;
d=size(size(arr),2); %Dimensionality
tt=cell(d,1);
%Gradually compress modes
sz=size(arr);
nl=sz(1);
nr=1;
for i=2:d
    nr = nr*sz(i);
end
%First mode is somewhat different
nrm=norm(reshape(b,[nl*nr,1])); %For compression
%Estimate how much norm is needed for a single core
if ( nrm < 1e-100 ) %Too small
   for i=2:d-1
     tt{i}=zeros(2,0,0);
   end
   tt{1}=zeros(2,0); tt{d}=zeros(2,0);
   return
end
eps1=eps/sqrt(d-1);
b=reshape(b,[nl,nr]);
[u0,s0,v0]=svd(b,'econ');
%r=my_chop(diag(s0),eps);
r=my_chop2(diag(s0),eps1*norm(diag(s0)));
r=min(r,rmax);
%r=rank(b,eps1);
u0=u0(:,1:r);
b=u0'*b;
%norm(b-u0*s0*v0(:,1:r)','fro')/norm(b,'fro')
%b=v0(:,1:r)*s0;
%b=b';
tt{1}=u0;
for i=2:d-1
    nl=sz(i);
    nr=nr/sz(i);
    b=reshape(b,[r*nl,nr]);
    [u0,s0,v0]=svd(b,'econ');
    %fprintf('%f \n',norm(diag(s0)));
    %r1=my_chop(diag(s0),eps);
    %r1=rank(b,eps1);
    r1=my_chop2(diag(s0),eps1*norm(diag(s0)));
    r1=min(r1,rmax);
    u0=u0(:,1:r1); %u0 is rxnlxr1
    b=u0'*b;
    %b=(v0(:,1:r1)*s0);
    %B is r1xn2xn3
    tt{i}=reshape(u0,[r,nl,r1]);
    tt{i}=permute(tt{i},[2,1,3]);   
    r=r1;
end
%In the final, b is just r1xn_d
%fprintf('%f \n',nrm);
tt{d}=b';
return
end
