function x=simplepick(Sp,ppm,peakthresh)

next=1;
noise=std(Sp(1:500));
for i = 2:1:length(Sp)-1 %%find all peaks higher than given multiplier of noise%%
    if (Sp(i) > peakthresh*noise) && (Sp(i-1) < Sp(i)) && (Sp(i) >Sp(i+1))
        x(next)=i;
        next = next+1;
    end
end
