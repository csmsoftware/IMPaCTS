function model=mjrO2pls(X,Y,pax,oax,oay,mtype,varargin)
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------

if(~isempty(varargin)) %double checks here for backward compatibilty
	if(~isempty(varargin{1}))
		splitSize=varargin{1};
	else
		splitSize=300; %this is the Y block size (if mtype='large');
	end
end

ssx=sum(sum(X.^2));
ssy=sum(sum(Y.^2));

if(strcmp(mtype,'large')) %large matrices
    [m,n]=size(Y);    
    nsplits=floor(n/splitSize);
    Wtot=[];
    Ctot=[];
    
    h=waitbar(0,['estimating Wp for Y-blocks...']);%,num2str(1),' of ',num2str(nsplits)]);
    for i = 1:nsplits
            %disp(['ysplit',num2str(i)]);
            waitbar((i-1)/nsplits,h);%,['estimating Wp for Y-block: ',num2str(i),' of ',num2str(nsplits)]);
            [Wtmp,Stmp,Ctmp] = svd([Y(:, [((i-1)*splitSize+1):(i*splitSize)] )'*X]',0);        
             Wtmp=Wtmp(:,1:pax);
             Stmp=Stmp(1:pax,1:pax); 
             Wtot=[Wtot,Wtmp*Stmp];
             
             if(i==nsplits && mod(n,splitSize)~=0)
                %disp(['last Y-block - got remaining part of ',num2str(mod(n,splitSize)),' vars...']);
                [Wtmp,Stmp,Ctmp] = svd([Y(:, [((i*splitSize)+1):end] )'*X]',0); 
                if(mod(n,splitSize)<pax)
                    paxTmp=mod(n,splitSize);
                else
                    paxTmp=pax;
                end
                Wtmp=Wtmp(:,1:paxTmp);
                Stmp=Stmp(1:paxTmp,1:paxTmp); 
                Wtot=[Wtot,Wtmp*Stmp];
                 
             end
    end
    
    close(h);
  
    

    [W,S,c]=svd(Wtot,0);
    clear Wtot;
    W=W(:,1:pax);
    S=S(1:pax,1:pax);
    Ts{1}=X*W;
    T=Ts{1};
    C=Y'*T;
    C=[C*diag(1./sqrt(sum(C(:,1:pax).^2)))];

else %conventional 
    [W,S,C] = svd([Y'*X]',0);
	W=W(:,1:pax);
	C=C(:,1:pax);
	S=S(1:pax,1:pax);
	Ts{1}=X*W;
	T=Ts{1};
end


Exy=X-T*W';
Xr=X;

R2Xo=0;
R2Xcorr=sum(sum((Ts{1}*W').^2))/ssx;
R2X=1-sum(sum(Exy.^2))/ssx;

Wo=[];
Pyo=[];
To=[];

	for(i = 1:oax)
	      [wo,syo,wor]=svd([Exy'*Ts{i}],0);
		  wo=wo(:,1); %/sqrt(wo'*wo);
		  to=Xr*wo; %/(wo'*wo);
		  pyo=Xr'*to/(to'*to);
		  Xr=Xr-to*pyo';
          
		  Wo=[Wo,wo];
		  Pyo=[Pyo,pyo];
		  To=[To,to];			
		  
		  Ts{i+1}=Xr*W;
		  Exy=X-Ts{i+1}*W'-To*Pyo';		 
		  
			R2Xo=[R2Xo,sum(sum((To*Pyo').^2))/ssx];
			R2Xcorr=[R2Xcorr,sum(sum((Ts{i+1}*W').^2))/ssx];
			R2X=[R2X,1-sum(sum(Exy.^2))/ssx];
			T=Ts{i+1}; 
	end
		


	Yr=Y;
	Us{1}=Yr*C;
	U=Us{1};
	Fxy=Y-Us{1}*C';

    R2Yo=0;
	R2Ycorr=sum(sum((Us{1}*C').^2))/ssy;
	R2Y=1-sum(sum(Fxy.^2))/ssy;
	
	Uo=[];
	Pxo=[];
	Co=[];

	for(i = 1:oay)
		[co,sxo,cor]=svd(Fxy'*Us{i},0);
		co=co(:,1); %/sqrt(co'*co);
		uo=Yr*co; %/(co'*co);
		pxo=Yr'*uo/(uo'*uo);
		Yr=Yr-uo*pxo';
		
		Co=[Co,co];
		Pxo=[Pxo,pxo];
		Uo=[Uo,uo];
					  
		Us{i+1}=Yr*C;
		Fxy=Y-Us{i+1}*C'-Uo*Pxo';

		R2Yo=[R2Yo,sum(sum((Uo*Pxo').^2))/ssy];
		R2Ycorr=[R2Ycorr,sum(sum((Us{i+1}*C').^2))/ssy];
		R2Y=[R2Y,1-sum(sum(Fxy.^2))/ssy];
		U=Us{i+1};

    end
	
    Bus=cell(1,1);
    bts=cell(1,1);
    for(i = 1:oax+1)
        for(j = 1:oay+1)
            Bus{i,j}= inv(Us{j}'*Us{j})*Us{j}'*Ts{i};
            Bts{i,j}= inv(Ts{i}'*Ts{i})*Ts{i}'*Us{j};	 
        end
    end
    
	Bu= inv(U'*U)*U'*T;
	Bt= inv(T'*T)*T'*U;
    
    
    

    
    
R2Yhat=[];
R2Xhat=[];

%Isn't this the correct way? ...keeping the OC way for now (below)....
% for(i = 1:oax+1)
%         for(j = 1:oay+1)
%          BtTmp=inv(Ts{i}'*Ts{i})*Ts{i}'*Us{j};
% 	     YhatTmp=Ts{i}* BtTmp * C';
% 	     R2Yhat(i,j)=1-sum(sum((YhatTmp-Y).^2))/ssy;
% 
%          BuTmp=inv(Us{i}'*Us{i})*Us{1}'*Ts{i};
% 	     XhatTmp=Us{i}* BuTmp * W';
% 	     R2Xhat(i,j)=1-sum(sum((XhatTmp-X).^2))/ssx;
%         end
% end


%This is OC style - keeping for now... :
for(i = 1:oax+1)
	     BtTmp=inv(Ts{i}'*Ts{i})*Ts{i}'*U;
	     YhatTmp=Ts{i}* BtTmp * C';
	     R2Yhat=[R2Yhat, 1-sum(sum((YhatTmp-Y).^2))/ssy];
end
for(i = 1:oay+1)
         BuTmp=inv(Us{i}'*Us{i})*Us{i}'*T;
	     XhatTmp=Us{i}* BuTmp * W';
	     R2Xhat=[R2Xhat, 1-sum(sum((XhatTmp-X).^2))/ssx];

end


model.T=T;
model.Ts=Ts;
model.W=W;
model.Wo=Wo;
model.Pyo=Pyo;
model.To=To;

model.U=U;
model.Us=Us;
model.C=C;
model.Co=Co;
model.Pxo=Pxo;
model.Uo=Uo;

model.Bt=Bt;
model.Bu=Bu;


model.Bts=Bts;
model.Bus=Bus;

model.R2X=R2X;
model.R2Xcorr=R2Xcorr;
model.R2Xo=R2Xo;
model.R2Xhat=R2Xhat;

model.R2Y=R2Y;
model.R2Ycorr=R2Ycorr;
model.R2Yo=R2Yo;
model.R2Yhat=R2Yhat;

model.ssx=ssx;
model.ssy=ssy;


end
























 