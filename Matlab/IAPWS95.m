function IAPWS_results=IAPWS95(input,P_or_rho,NA_flg)
%function results=IAPW95(input,P_or_rho, NA_flg)
%    results=rho,vel,G,Cp,alpha,S,U,H,A,Cv,Kt,gamma,Pout
% where:
%   input is either a cell (points on grid) or a matrix [P in first column and T in second]
%   flag is a string,  'P' for entering pressures and temperatures, any other string for entering densities and temperatures
% 
% if the optional NA_flg is given as 0, the Non-analytic contributions are NOT included
%
% examples: 
% you want answers for the grid of p=1:1000 MPa and t=300:400 K use 
%             results=IAPWSp({1:1000,300:400,'P')
% you want answers for a list of scattered points with a unique P and T for each, (:) to force columns 
%            results=IAPWSp([P(:) T(:)],'P')
% If you want the results for a range of densities from 1000 to 1100 at one temperature (300 K): 
%            results=IAPWSp({1000:1100,300},'notP')
% Units:  P in MPa, T in K rho (kg/m^3), Cv,Cp in J/kg/K  E, G J-kg units, vel in m/s
% E Abramson and J M Brown 2000
% JM Brown 2015 - added structured output, cells and vector input and output, changed units, added rho-T input

%check for availability of parallel computing
has_parfor = ~isempty(which('parfor'));
if(nargin==2)
    NA_flg=1;
end
    
if(strcmp(P_or_rho,'P'))
    flg_P=1;
    if(iscell(input))
        P=input{1};
        Pout=P;
        T=input{2};
        flg_grd=1;
        nP=length(P);
        nT=length(T);
        G=zeros(nP,nT);
        rho=G;
    else
        P=input(:,1);
        Pout=P;
        T=input(:,2);
        flg_grd=0;
        nP=length(P);
        nT=length(T);
        G=zeros(nP,1);
        rho=G;
    end
else
    flg_P=0;
    if(iscell(input))
        rho=input{1};
        T=input{2};
        flg_grd=1;
        nP=length(rho);
        nT=length(T);
        G=zeros(nP,nT);
        Pout=G;
    else
        rho=input(:,1);
        T=input(:,2);
        flg_grd=0;
        nP=length(rho);
        nT=length(T);
        G=zeros(nP,1);
        Pout=G;
    end
end
% preallocate all outputs:
H=G;
S=G;
Cv=G;
Cp=G;
alpha=G;
vel=G;
U=G;
gamma=G;
Kt=G;
EOS=IAPWSparms(NA_flg);

if has_parfor
if flg_P
if flg_grd
    parfor i=1:nP
        for j=1:nT
            [rho(i,j),Pout(i),H(i,j),S(i,j),Cv(i,j),Cp(i,j),alpha(i,j),vel(i,j),U(i,j),G(i,j),gamma(i,j),Kt(i,j),A(i,j)]=P_search(EOS,P(i),T(j));  
        end
    end
else
    parfor i=1:nP
        [rho(i),Pout(i),H(i),S(i),Cv(i),Cp(i),alpha(i),vel(i),U(i),G(i),gamma(i),Kt(i),A(i)]=P_search(EOS,P(i),T(i));  
    end
end
else
  if flg_grd
   parfor i=1:nP
     for j=1:nT
         [Pout(i,j),H(i,j),S(i,j),Cv(i,j),Cp(i,j),alpha(i,j),vel(i,j),U(i,j),G(i,j),gamma(i,j),Kt(i,j),A(i,j)]=multparmEOS(EOS,rho(i),T(j));
     end
   end 
  else
    parfor i=1:nP
      [Pout(i),H(i),S(i),Cv(i),Cp(i),alpha(i),vel(i),U(i),G(i),gamma(i),Kt(i),A(i)]=multparmEOS(EOS,rho(i),T(i));
    end   
  end

end

else
    
if flg_P
if flg_grd
    for i=1:nP
        for j=1:nT
            [rho(i,j),Pout(i),H(i,j),S(i,j),Cv(i,j),Cp(i,j),alpha(i,j),vel(i,j),U(i,j),G(i,j),gamma(i,j),Kt(i,j),A(i,j)]=P_search(EOS,P(i),T(j));  
        end
    end
else
    for i=1:nP
        [rho(i),Pout(i),H(i),S(i),Cv(i),Cp(i),alpha(i),vel(i),U(i),G(i),gamma(i),Kt(i),A(i)]=P_search(EOS,P(i),T(i));  
    end
end
else
  if flg_grd
   for i=1:nP
     for j=1:nT
         [Pout(i,j),H(i,j),S(i,j),Cv(i,j),Cp(i,j),alpha(i,j),vel(i,j),U(i,j),G(i,j),gamma(i,j),Kt(i,j),A(i,j)]=multparmEOS(EOS,rho(i),T(j));
     end
   end 
  else
    for i=1:nP
      [Pout(i),H(i),S(i),Cv(i),Cp(i),alpha(i),vel(i),U(i),G(i),gamma(i),Kt(i),A(i)]=multparmEOS(EOS,rho(i),T(i));
    end   
  end

end

end
    IAPWS_results.rho=rho;
    IAPWS_results.vel=vel;
    IAPWS_results.G=G;
    IAPWS_results.Cp=Cp;
    IAPWS_results.Cv=Cv;
    IAPWS_results.Kt=Kt;
    IAPWS_results.alpha=alpha;
    IAPWS_results.S=S;
    IAPWS_results.U=U;
    IAPWS_results.H=H;
    IAPWS_results.gamma=gamma;
    IAPWS_results.P=Pout;
    IAPWS_results.T=T;
    IAPWS_results.A=A;
    IAPWS_results.F=A;
    
end

function   [rho_out,P,H,S,Cv,Cp,alpha,vel,E,G,gamma,Kt,A]=P_search(EOS,P,T)         
Ptrial=P;
Ttrial=T;
%Tc=373+12.45*P*1000;
%  if (T>Tc & P<.025),
%      rho_guess=.005;
%  elseif (T>640 & T<720 & P>.025 & P<.05)
%if (T>400 & P<.1)
     %rho_guess=.2;
    % rho_guess=.8;
 if P>=.1,
     rho_guess=1100;
 else
     rho_guess=750;
 end
 if (T<647 & P<liquidvapor(T))
     rho_guess=.1;
 end

rho_out=fzero(@(rho) (Ptrial-multparmEOS(EOS,rho,Ttrial)),rho_guess,optimset('disp','off')); %,'TolX',1e-10

% failure if starting density is liquid for 'gas" regime - try again with
% "gas' density
if isnan(rho_out),
    rho_guess=5;
    rho_out=fzero(@(rho) (Ptrial-multparmEOS(EOS,rho,Ttrial)),rho_guess,optimset('disp','off'));  %,'TolX',1e-10
end

[P,H,S,Cv,Cp,alpha,vel,E,G,gamma,Kt,A]=multparmEOS(EOS,rho_out,T);
end

function eos=IAPWSparms(NA_flg)
% set up the parameters for IAPWS

n=[ 12533547935523e-1
	 78957634722828e1
	-87803203303561e1
	 31802509345418
	-26145533859358
	-78199751687981e-2
	 88089493102134e-2
	-66856572307965
	 20433810950965
	-66212605039687e-4
	-19232721156002
	-25709043003438
	 16074868486251
	-40092828925807e-1
	 39343422603254e-6
	-75941377088144e-5
	 56250979351888e-3
	-15608652257135e-4
	 11537996422951e-8
	 36582165144204e-6
	-13251180074668e-11
	-62639586912454e-9
	-10793600908932
	 17611491008752e-1
	 22132295167546
	-40247669763528
	 58083399985759
	 49969146990806e-2
	-31358700712549e-1
	-74315929710341
	 47807329915480
	 20527940895948e-1
	-13636435110343
	 14180634400617e-1
	 83326504880713e-2
	-29052336009585e-1
	 38615085574206e-1
	-20393486513704e-1
	-16554050063734e-2
	 19955571979541e-2
	 15870308324157e-3
	-16388568342530e-4
	 43613615723811e-1
	 34994005463765e-1
	-76788197844621e-1
	 22446277332006e-1
	-62689710414685e-4
	-55711118565645e-9
	-19905718354408
	 31777497330738
	-11841182425981];
n=n*1e-14;

c=zeros(51,1);
c(8:22)=1;
c(23:42)=2;
c(43:46)=3;
c(47)=4;
c(48:51)=6;

g=zeros(51,1);
g(8:51)=1;

d=[1 1 1 2 2 3 4 1 1 1 2 2 3 4 4 5 7 9 10 11 13 15 1 2 2 2 3 4 4 4 5 6 6 7 9 9 9 9 9 10 10 12 3 4 4 5 14 3 6 6 6 3 3 3]';
t=[-0.5 0.875 1 0.5 0.75 0.375 1 4 6 12 1 5 4 2 13 9 3 4 11 4 13 1 7 1 9 10 10 3 7 10 10 6 10 10 1 2 3 4 8 6 9 8 16 22 23 23 10 50 44 46 50 0 1 4]';

parms=[n(1:51) d(1:51) t(1:51) g c];

% ideal gas components:
n0=[-8.32044648201 6.6832105268 3.00632 0.012436 0.97315 1.27950 0.96956 0.24873]';
gamma0=[nan nan nan 1.28728967 3.53734222 7.74073708 9.24437796 27.5075105]';
p0=[n0 gamma0];

%R=0.46151805*1e3; %J/Kg/K
%R=8.314472;
CPvalues=[647.096 322];
MW=18.015268;

eos.parm_ideal=p0;
eos.parm_resid=parms;
eos.CPvalues=CPvalues;
eos.MW=MW;
eos.parms_extra=[];
if NA_flg
eos.NAparm.n=[	-.31306260323435e2
	             .31546140237781e2
	            -.25213154341695e4
	            -.14874640856724
	             .31806110878444];
    
    eos.NAparm.d=[3 3 3 0 0]';
    eos.NAparm.t=[0 1 4 0 0]';
    eos.NAparm.alpha=[20 20 20 0 0]';
    eos.NAparm.beta=[150 150 250 0 0]';
    eos.NAparm.gamma=[1.21 1.21 1.25 0 0]';
    eos.NAparm.epsil=[1 1 1 0 0]';
    eos.NAparm.al=[3.5 3.5]';
    eos.NAparm.bl=[.85 .95]';
    eos.NAparm.Bl=[.2 .2]';
    eos.NAparm.Cl=[28 32]';
    eos.NAparm.Dl=[700 800]';
    eos.NAparm.Al=[.32 .32]';
    eos.NAparm.betal=[.3 .3]';
else
    eos.NAparm=[];
end
end

function [phi_0,phi0_d,phi0_dd,phi0_t, phi0_tt,phi0_dt]=ideal_phi(parms,del,tau)

n0=parms(:,1);
gamma0=parms(:,2);
id=4:8;

phi_0=log(del)+n0(1)+n0(2)*tau+n0(3)*log(tau)+sum(n0(id).*log(1-exp(-gamma0(id)*tau)));
phi0_t=n0(2) + n0(3)./tau + sum(n0(id).*gamma0(id).*( (1-exp(-gamma0(id)*tau)).^(-1) -1) );
phi0_tt=-n0(3)./tau.^2 - sum(n0(id).*gamma0(id).^2.*exp(-gamma0(id)*tau).*(1-exp(-gamma0(id)*tau)).^(-2));
phi0_d=del.^(-1);
phi0_dd=-del.^(-2);
phi0_dt=0;   
end

function [phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt]=NA_phi(parms,del,tau)


n=parms.n;
d=parms.d;
t=parms.t;
alpha=parms.alpha;
beta=parms.beta;
gamma=parms.gamma;
epsil=parms.epsil;
al=parms.al;
bl=parms.bl;
Bl=parms.Bl;
Cl=parms.Cl;
Dl=parms.Dl;
Al=parms.Al;
betal=parms.betal;

nd=length(del);
phi=zeros(nd,1);phi_d=phi;phi_dd=phi;phi_t=phi;phi_tt=phi;phi_dt=phi;


for i=1:nd
    S=exp( -Cl*(del(i)-1)^2-Dl*(tau(i)-1)^2 );  %phi  S
    T=(1-tau(i))+Al.*((del(i)-1)^2).^(0.5./betal);

    D=T.^2 + Bl.*((del(i)-1)^2).^al;	%Delta (upper case)  D

    %derivatives of phi
    Sd=-2*Cl*(del(i)-1).*S;
    Sdd=(2*Cl*(del(i)-1).^2-1)*2.*Cl.*S;  
    St=-2*Dl*(tau(i)-1).*S;
    Stt=(2*Dl*(tau(i)-1)^2-1)*2.*Dl.*S;
    Sdt=4*Cl.*Dl*(del(i)-1)*(tau(i)-1).*S;

    %derivatives of Delta
    Dd=(del(i)-1).*( Al.*T*2./betal.*((del(i)-1).^2).^(0.5./betal-1) + 2*Bl.*al.*((del(i)-1).^2).^(al-1) );
    Ddd=Dd./(del(i)-1) + (del(i)-1).^2*( 4*Bl.*al.*(al-1).* (del(i)-1).^2.^(al-2) + 2*Al.^2./betal.^2.* ( ((del(i)-1).^2).^(1./betal/2-1) ).^2 + Al.*T./betal*4.*(1./betal/2-1).*(del(i)-1).^2.^(1./betal/2-2) );
        
    %derivatives of Delta^bi
    Dbd=bl.*D.^(bl-1).*Dd;
    Dbdd=bl.*(D.^(bl-1).*Ddd + (bl-1).*D.^(bl-2).*Dd.^2);

    Dbt=-2*T.*bl.*D.^(bl-1);
    Dbtt=2*bl.*D.^(bl-1) + 4*T.^2.*bl.*(bl-1).*D.^(bl-2);
    Dbdt=-Al.*bl*2./betal.*D.^(bl-1).*(del(i)-1).*((del(i)-1).^2).^(.5./betal-1) - 2*T.*bl.*(bl-1).*D.^(bl-2).*Dd;

    % phi
    id=1:3;
    phi(i)=sum( n(id).*del.^d(id).*tau.^t(id).*exp(-alpha(id).*(del-epsil(id)).^2-beta(id).*(tau-gamma(id)).^2) );
    id=4:5;   
    phi(i)=phi(i)+sum( n(id).*D.^bl*del.*S );

    % phi_d
    id=1:3;
    phi_d(i)=sum( n(id).*del(i).^d(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 -beta(id).*(tau(i)-gamma(id)).^2).*(d(id)/del(i)-2*alpha(id).*(del(i)-epsil(id))) );
    id=4:5;
    phi_d(i)=phi_d(i)+sum(n(id).*(D.^bl.*(S+del(i)*Sd)+Dbd*del(i).*S));

    % phi_dd
    id=1:3;
    phi_dd(i)=sum(n(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 -beta(id).*(tau(i)-gamma(id)).^2).* ...
                (-2*alpha(id).*del(i).^d(id) + 4*alpha(id).^2.*del(i).^d(id).*(del(i)-epsil(id)).^2 - 4*d(id).*alpha(id).*del(i).^(d(id)-1).*(del(i)-epsil(id)) + d(id).*(d(id)-1).*del(i).^(d(id)-2)));
      id=4:5;
    phi_dd(i)=phi_dd(i)+sum(n(id).*( D.^bl.*(2*Sd+del(i)*Sdd) + 2*Dbd.*(S+del(i)*Sd)+Dbdd*del(i).*S));

       
    %phi_t
    id=1:3;
    phi_t(i)=sum(n(id).*del(i).^d(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 - beta(id).*(tau(i)-gamma(id)).^2)   .*( t(id)/tau(i)-2*beta(id).*(tau(i)-gamma(id)) ) );
    id=4:5;
    phi_t(i)=phi_t(i)+sum(n(id).*del(i).*( Dbt.*S +D.^bl.*St));

    %phi_tt
    id=1:3;
    phi_tt(i)=sum(n(id).*del(i).^d(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 - beta(id).*(tau(i)-gamma(id)).^2).*( (t(id)/tau(i)-2*beta(id).*(tau(i)-gamma(id))).^2 - t(id)/tau(i)^2 -2*beta(id)) );
    id=4:5;
    phi_tt(i)=phi_tt(i)+sum(n(id).*del(i).*( Dbtt.*S + 2*Dbt.*St +D.^bl.*Stt));

    % phi_dt
    id=1:3;
    phi_dt(i)=sum( n(id).*del(i).^d(id).*tau(i).^t(id).*exp(-alpha(id).*(del(i)-epsil(id)).^2 - beta(id).*(tau(i)-gamma(id)).^2).*(d(id)/del(i)-2*alpha(id).*(del(i)-epsil(id))).*(t(id)/tau(i)-2*beta(id).*(tau(i)-gamma(id))) );
    id=4:5;
    phi_dt(i)=phi_dt(i)+sum( n(id).*( D.^bl.*(St+del(i)*Sdt) + del(i)*Dbd.*St + Dbt.*(S+del(i)*Sd) + Dbdt*del(i).*S));
end
end

function [phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt,phi_dtt]=resid_phi(parms,del,tau)
%calculate residual function and derivatives
% [phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt,phi_dtt]=resid_phi(parms,del,tau)
% where phi*RT is the residual helmholtz energy, del and tau are rho and
% temperature scaled by critical point values
%  phi_d etc are derivatives of phi etc
% parms = [coef d t gamma p] for each term
n=parms(:,1);
d=parms(:,2);
t=parms(:,3);
gamma=parms(:,4);
p=parms(:,5);

% vector of contributions to phi
    fac=del.^p;
    phi=n.*del.^d.*tau.^t.*exp(-gamma.*fac);
% vector for first density derivatives
    a=(d-gamma.*p.*fac);
%vector for second density derivative
    b=(a.*(a-1)-gamma.^2.*p.^2.*fac);
% vector for first temperature derivative
    c=t/tau;
%vector for second temperature derivative
    tt=c.*(t-1)/tau;
%add up contributions

    phi_d=sum(a.*phi/del);
    phi_dd=sum(b.*phi/del^2);
    phi_t=sum(c.*phi);
    phi_tt=sum(tt.*phi);
    phi_dt=sum(a.*c.*phi/del);
    phi_dtt=sum(a.*tt.*phi/del);
    phi=sum(phi);
end

function [P,H,S,Cv,Cp,alpha,vel,E,G,gamma,Kt,A]=multparmEOS(eos,rho,T)
% [H,P,S,Cv,Cp,alpha,vel,G,E]=multparmEOS(EOS,rho,T)
% T in K rho in gm/cc 
% Cpvalues=[Tc rhoc]
% parms_ideal = [n0 gamma0]
% parms_resid =[n d t gamma p]
% output:  P - MPa  vel m/s

parm_ideal=eos.parm_ideal;
parm_resid=eos.parm_resid;

 parm_NA=eos.NAparm;

CPvalues=eos.CPvalues;
MW=eos.MW;

R=8.314472/MW*1000;  %J/Kg/K
del=rho/CPvalues(2);
if del==1, del=1-eps; end 

tau=CPvalues(1)*T.^(-1);

% [phi_0,phi0_d,phi0_dd,phi0_t, phi0_tt,phi0_dt]=ideal_phi(parm_ideal,del,tau);
% [phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt,phi_dtt]=resid_phi(parm_resid,del,tau);
[phi_0,~,~,phi0_t, phi0_tt,~]=ideal_phi(parm_ideal,del,tau);

[phi,phi_d,phi_dd,phi_t,phi_tt,phi_dt,~]=resid_phi(parm_resid,del,tau);

% code for the "non-analytic" terms - only interesting in critical region
 if (isempty(parm_NA)~=1)
       [phi2,phi_d2,phi_dd2,phi_t2,phi_tt2,phi_dt2]=NA_phi(parm_NA,del,tau);
       phi=phi+phi2;
       phi_d=phi_d+phi_d2;
       phi_dd=phi_dd+phi_dd2;
       phi_t=phi_t+phi_t2;
       phi_tt=phi_tt+phi_tt2;
       phi_dt=phi_dt+phi_dt2;
 end

P=rho*R*T*(1+(del*phi_d))/1e6;  % MPa units

vel=1 + 2*del*phi_d + del^2*phi_dd - (1+del*phi_d-del*tau*phi_dt)^2/tau^2/(phi0_tt+phi_tt);
vel=real(sqrt(R*T*vel));  %m/s units  
Cp=(-tau^2*(phi0_tt+phi_tt) + (1+del*phi_d-del*tau*phi_dt)^2/(1+2*del*phi_d+del^2*phi_dd)); %J/g/K 
Cv=-R*tau^2*(phi0_tt+phi_tt);
Cp=Cp*R;

E=R*T*tau*(phi0_t + phi_t);
H=R*T*(1 + tau*(phi0_t + phi_t) + del*phi_d);
A=R*T*(phi_0+phi);
S=(E/T - R*(phi_0+phi));
G=R*T*(1+phi_0+phi+del*phi_d);
PR=R*T*(1+2*del*phi_d+del^2*phi_dd);
PT=R*rho*(1+del*phi_d - del*tau*phi_dt);
alpha=PT/PR/rho;
Ks=rho.*vel.^2/1e6;
gamma=alpha.*Ks./rho./Cp*1e6;
Kt=  Ks.*(1 + alpha*gamma.*T).^(-1) ;


end
