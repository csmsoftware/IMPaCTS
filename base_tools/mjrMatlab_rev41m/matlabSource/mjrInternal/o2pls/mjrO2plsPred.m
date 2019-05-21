function modelPred=mjrO2plsPred(X,Y,model,oax,oay,dir);
%------------------------------------------------
%Author: Mattias Rantalainen, Imperial College, 2007
%Copyright: Mattias Rantalainen, 2007
%------------------------------------------------
	
if(strcmpi(dir,'x'))
To=[];
%if(oax>0)
        
    
	for(i = 1:oax)      
      to=X* model.Wo(:,i) *inv(model.Wo(:,i)'*model.Wo(:,i));
	  To=[To,to];
      X=X-to*model.Pyo(:,i)';
	end
	
	T=X*model.W*inv(model.W'*model.W);
	Yhat=T*model.Bts{oax+1,oay+1}*model.C';
	modelPred.T=T;
	modelPred.Yhat=Yhat;
	modelPred.To=To;
	return;
%end 
end

if(strcmpi(dir,'y'))
	Uo=[];
%	if(oay>0)
		for(i = 1:oay) 
		uo=Y*model.Co(:,i)*inv(model.Co(:,i)'*model.Co(:,i));
		Uo=[Uo,uo];
		Y=Y-uo*model.Pxo(:,i)';
        end

	U=Y*model.C*inv(model.C'*model.C);
	Xhat=U*model.Bus{oax+1,oay+1}*model.W';
	modelPred.U=U;
	modelPred.Xhat=Xhat;
	modelPred.Uo=Uo;
	return;

    %end

end
