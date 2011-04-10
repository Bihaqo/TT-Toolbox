function [tt] = tt_compr2(tt,eps, max_r)
%[TT]=TT_COMPR2(TT,EPS)
% Most important subroutine, reapproximates a given TT tensor  with prescribed 
% accuracy EPS
%
%
%
%
% TT Toolbox 1.0, 2009
%
%This is TT Toolbox, written by Ivan Oseledets.
%Institute of Numerical Mathematics, Moscow, Russia
%webpage: http://spring.inm.ras.ru/osel
%
%For all questions, bugs and suggestions please mail
%ivan.oseledets@gmail.com
%---------------------------
d = size(tt,1);
%First, estimate the logarithm of the squared norm, and then --- the norm
%of each core :-)
nrm_full=tt_dot2(tt,tt);
nrm1=nrm_full/(2*d); nrm1=exp(nrm1);

exists_max_r=1;
if ((nargin<3)||(isempty(max_r)))
    exists_max_r=0;
end;

% if ( nrm_full < log(1e-200) ) %Something really small
%   n=size(tt{1},1);
%   tt{1}=zeros(n,0);
%   n=size(tt{d},1);
%   tt{d}=zeros(n,0);
%   for i=2:d-1
%   n=size(tt{i},1);
%   tt{i}=zeros(n,0,0);
%   end
%   return
% end
%nrmf=zeros(d,1); %Place to store the norms of QR-factors
%first, we orthogonalize the tensor from right to left until the first mode
mat=tt{d};
[q,rv]=qr(mat,0); rv=rv./nrm1; q=q.*nrm1;
tt{d}=q;
for i=(d-1):-1:2
    tt{i} = ten_conv(tt{i},3,conj(rv'));
    ncur=size(tt{i},1);
    r2=size(tt{i},2);
    r3=size(tt{i},3);
    core=permute(tt{i},[1,3,2]);
    core=reshape(core,[ncur*r3,r2]);
    [tt{i},rv]=qr(core,0); rv=rv./nrm1;
    rnew=min(r2,ncur*r3);
    tt{i}=reshape(tt{i}.*nrm1,[ncur,r3,rnew]);
    tt{i}=permute(tt{i},[1,3,2]);
end
tt{1}=tt{1}*conj(rv');
%nrmf(1)=norm(tt{1},'fro');
%nrm_full=sum(log(nrmf(1:d))); nrm1=nrm_full/d; nrm1=exp(nrm1); %This would
%be the norm of each core
%Now gradually start compression from the left, using the knowledge 
%of norms
mat=tt{1};
%return;
mat(abs(mat)<1e-300)=0;
[u0,s0,ru]=svd(mat,0); 
%If no scaling factors were taken out,
%then everything would be simple --- nrm=norm(diag(s0)) is the norm,
%singular values are filtered at absolute accuracy eps*nrm/sqrt(d-1)
%Here the "True" s0 matrix is up to factor of product of nrm(2:d)
%so for it we can filter the singular values just at 
%eps*nrmf(1)/sqrt{d-1}
%nrmf(1)=norm(diag(s0));  
%nrm=norm(diag(s0));
eps1=eps*norm(diag(s0))/sqrt(d-1); %This is the absolute accuracy to filter with
%r0=my_chop2(diag(s0),eps1);
r0=numel(find(s0>eps1));
if (exists_max_r) r0 = min(r0, max_r); end;
%keyboard;
%r0=rank(mat,eps1);
u0=u0(:,1:r0);
s0=diag(s0);
s0=s0(1:r0); % -eps1*sign(s0);
ru=ru(:,1:r0)*diag(s0)./nrm1; %This should be scaled properly
%ru=ru;
tt{1}=u0.*nrm1; %Now it is properly scaled
for i=2:d-1
    %Convolve tt{i} over the second index
%     fprintf('norm_tt{%d}=%g, norm_ru = %g\n', i, norm(reshape(tt{i}, size(tt{i},1)*size(tt{i},2), size(tt{i},3)), 'fro'), norm(ru,'fro'));        
    tt{i}=ten_conv(tt{i},2,conj(ru));
    ncur=size(tt{i},1);
    r2=size(tt{i},2);
    r3=size(tt{i},3);
    core=reshape(tt{i},[ncur*r2,r3]);
    %r=rank(core,eps1);
    %keyboard;  
    core(abs(core)<1e-300)=0;
    [u0,s0,ru]=svd(core,0);
    
    nrm=norm(diag(s0));
    eps1=eps*nrm/sqrt(d-1); %Nothing more
    %keyboard;
    %r=my_chop2(diag(s0),eps1);
    r=numel(find(s0>eps1));
    if (exists_max_r) r = min(r, max_r); end;
    u0=u0(:,1:r);
    s0=(s0(1:r,1:r))./nrm1;
    ru=ru(:,1:r)*s0;
    core=u0.*nrm1;
    tt{i}=reshape(core,[ncur,r2,r]);
end
tt{d}=tt{d}*conj(ru);
return
end
