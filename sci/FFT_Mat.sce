// Copyright (C) 2016 - Corporation - Author
//
// About your license if you have any
//
// Date of creation: 26 oct. 2016
//
//// Copyright (C) 2016 - Corporation - Author
////
//// About your license if you have any
////
//// Date of creation: 10 oct. 2016
//// Anntenne SMA

//chdir('C:\Users\phili\Golf\portaudio_0.2\');
//exec('C:\Users\phili\Golf\portaudio_0.2\loader.sce',-1)
chdir('C:\Users\phili\Golf\Radar');
//stacksize('max');

/////////////////////////////////////////////////////////////////

function phase = angle(A)
    phase = atan(imag(A),real(A))
endfunction;


////////////////////////////////////////////////////////////////////
function [s2Centre, s2f,MaxFreq] = plotFFT(s2,Fs)
    //[wft,wfm,fr]=wfir('bp',48,[1000/22050 5000/22050],'hm',[-1 -1]);
    [wft,wfm,fr] = wfir('bp',64,[0.03 0.11],'hm',[-1 -1]);
    N=size(s2,'c'); // definition du nombre d'échantillons
    tau = 1 / Fs; // interval temporel de l'echantillonnage
    t = (0:N - 1) * tau; // construction du vecteur temps
    w = 6000*%pi/180;
    //s2 = sin(w*t).*sin(w/3*t);
    s2Centre = s2 - mean(s2); // recentrage du signal autour de l'axe abscice.
    //s2Centre(abs(s2Centre)<0.0012)=0; // filtrage bourin pour supprimer les valeurs faibles
    //s2=s2(1:9000)=0;
    f=Fs*(0:(N)-1)/N;
    [s2f zf] = filter(wft,1,s2Centre); // filtrage du signal par le filtre passe bande

    //densite spectrale 
    s2_fft = (fft(s2Centre));
    s2f_fft = fft(s2f);
    conjuguee_s2 = conj(s2_fft);
    conjuguee_s2f = conj(s2f_fft);

    s2_densite = s2_fft.*conjuguee_s2;
    s2f_densite = s2f_fft.*conjuguee_s2f;


    s2f_densite_real = abs(real(s2f_densite));
    n=50;
    s2f_densite_real_moy = filter(ones(1,n),n,s2f_densite_real);
    s2_densite_real = abs(real(s2_densite));
    n=50;
    s2_densite_real_moy = filter(ones(1,n),n,s2_densite_real);    //

    s2_fft_real = abs(real(s2_fft));
    s2f_fft_real = abs(real(s2f_fft));
    [m,n]=max(s2f_fft_real(2:$/2));
    a = f(2:$/2);
    MaxFreq = a(n);
    //s2_densite(1,$/2+1:$) = [];
    figure();title(' signal');plot2d(t,s2Centre);
    figure();title(' fft complète');plot2d(f(2:$/2),s2_fft_real(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(' fft filtrée');plot2d(f(2:$/2),s2f_fft_real(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(' densite complète');plot2d(f(2:$/2),s2_densite(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(' densite filtrée');plot2d(f(2:$/2),s2f_densite(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(' densite filtrée moyenne');plot2d(f(2:$/2),s2f_densite_real_moy(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(' densite  moyenne');plot2d(f(2:$/2),s2_densite_real_moy(2:$/2));plot2d(fr*Fs,wfm);    
    //title(a_tl,"Signal Filtré");plot(a_tl,t,s2f);
    //title(a_bl,"FFT Filtrée");plot(a_bl,f(2:$/2),s2f_fft(2:$/2));
    s2_densite = s2_densite(2:$/2);
endfunction
//////////////////////// Fin de plotFFT() //////////////////////////////

/////////////////////////////////////////////////////////////////////////
// Tracking ball
function TrackingBall()
    n = aviopen('red-car-video.avi');
    im = avireadframe(n); //get a frame
    obj_win = camshift(im, [12, 6, 15, 13]); //initialize tracker
    while ~isempty(im),
        obj_win = camshift(im); //camshift tracking          
        obj_win
        im = rectangle(im, obj_win, [0,255,0]);
        imshow(im);
        im = avireadframe(n);
    end;
    aviclose(n);
endfunction;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%% fenetre de Hanning
function H=hanning(N)
    t=[1:N];
    H=0.5-0.5*cos(2*%pi*t/N);
endfunction

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function wrpm = Freq2RpmSpin(RadarFreq)
    //wrpm = RadarFreq * 60 * 3.6 /(%pi*0.043 * 19.49);//v = 2πr × RPM × (60/1000) km/hr
    wrpm = RadarFreq*60/(2*%pi*0.0215*19.49*3.6);
endfunction
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RadarFreq = RpmSpin2Freq(wrpm)
    //RadarFreq = wrpm /( 60 * 3.6 /(%pi*0.043 * 19.49));
    RadarFreq = wrpm * 2*%pi*0.0215*19.49*3.6/60;
endfunction

function [tt,f,M1] = animFFT(s2,Fs,nbEchantillon,pas,anim,seuil)
    N = size(s2,2);
    tau = 1 / Fs; // interval temporel de l'echantillonnage
    t = (0:N - 1) * tau; // construction du vecteur temps
    f=Fs*(0:(nbEchantillon)-1)/nbEchantillon;
    s2Centre = s2;// - mean(s2); // recentrage du signal autour de l'axe abscice.
    b=modulo(N,nbEchantillon);
    s2Centre=[s2Centre, zeros(nbEchantillon - b,1)'];


    if (anim > 0) then 
        figure();
        subplot(2,1,1);
        a = gca();
        a.auto_clear = "off";
        plot(t,s2);
        subplot(2,1,2);
        a = gca();
        a.auto_clear = "on";
        s2max = max(s2);
        subplot(2,1,1);
        plot([0 0],[0 s2max],'r');
        e = gce();
    end;
    M1=[];tt=[];
    for ii=1:pas:(size(s2Centre,2) - nbEchantillon),
        if (anim > 1) then 
            drawlater();
            delete(e);
            subplot(2,1,1);
            plot([t(ii) t(ii)],[0 s2max],'r');
            e = gce();
        end;
        //densite spectrale 
        s2_fft = (fft(s2Centre(1,ii:ii + nbEchantillon)));
        if max(real(s2_fft)) < seuil then
            s2_densite = zeros(s2_fft);
        else
            s2_densite = abs(real(s2_fft));
            //s2_densite = s2_densite/max(s2_densite);
        end;
        tt = [tt;t(ii)];
        M1 = [M1;s2_densite];
        if (anim > 1) then 
            subplot(2,1,2);
            plot(f(1:$/2),s2_densite(1,1:$/2));
            drawnow();
        end;
    end;
    M1 = M1(:,1:$/2);
    f= f(1:$/2);
    if (anim > 0) then 
        subplot(2,1,2);
        xset("colormap",jetcolormap(64));
        Sgrayplot(tt,f,M1);
    end;
endfunction

function y = fftpadding(x)
    //y = fft([x zeros(size(x,2)-1)]);
    y = fft([x zeros(2-1)]);
endfunction

function [fftFiltree, f1] = FftFiltree(x, Fs, FreqMin, FreqMax, fType)
    if (fType == 0), 
        [wft,wfm,fr] = wfir('bp',64,[FreqMin/Fs FreqMax/Fs ],'re',[-1 -1]);
        fftFiltree = real(abs(fftpadding(filter(wft,1,x))));
        f1 = Fs*(0:(size(fftFiltree,2))-1)/size(fftFiltree,2);
    else
        ll = find(((f1) <= FreqMin) | ((f1) >= FreqMax));// Filtrage bourin par suppression de valeur
        fftFiltree(ll) = fftFiltree(ll)/20;    
        f1 = Fs*(0:(size(fftFiltree,2))-1)/size(fftFiltree,2);
    end;
endfunction

function [densiteFiltree, f1] = DensiteFiltree(x, Fs, FreqMin, FreqMax, fType)
    [fftFiltree, f1] = FftFiltree(x, Fs, FreqMin, FreqMax, fType)
    densiteFiltree = abs(real(fftFiltree.*conj(fftFiltree)));
endfunction

function [M1, tt, f] = animDensite(s2,Fs,nbEchantillon,pas,anim,seuil,normalize)
    //s2 = [s2, zeros(1,pas/2)];
    N = size(s2,2);
    tau = 1 / Fs; // interval temporel de l'echantillonnage
    t = (0:N - 1) * tau; // construction du vecteur temps
    f=Fs*(0:(nbEchantillon)-1)/nbEchantillon;
    s2Centre = s2 - mean(s2); // recentrage du signal autour de l'axe abscice.
    b=modulo(N,nbEchantillon);
    s2Centre=[s2Centre, zeros(nbEchantillon - b,1)'];//     s2Centre=[s2Centre, zeros(2*(nbEchantillon - b),1)'];


    if (anim > 0) then 
        figure();
        subplot(2,1,1);
        a = gca();
        a.auto_clear = "off";
        plot(t,s2);
        subplot(2,1,2);
        a = gca();
        a.auto_clear = "on";
        s2max = max(s2);
        subplot(2,1,1);
        plot([0 0],[0 s2max],'r');
        e = gce();
    end;
    M1=[];tt=[];
    for ii=1:pas:(size(s2Centre,2) - nbEchantillon),
        if (anim > 1) then 
            drawlater();
            delete(e);
            subplot(2,1,1);
            plot([t(ii) t(ii)],[0 s2max],'r');
            e = gce();
        end;
        //densite spectrale 
        s2_fft = (fftpadding(s2Centre(1,ii:ii + nbEchantillon)));
        a = find(dbv(real(s2_fft)) < seuil);
        s2_fft(a) = 0;
//        if max(dbv(real(s2_fft))) < seuil then
//            s2_densite = zeros(s2_fft);
//        else
            s2_densite = abs(real(s2_fft.*conj(s2_fft)));//abs(real(s2_fft.*conj(s2_fft)));
            s2_densite = s2_densite .* s2_densite;
            if (normalize == 0) then
                s2_densite = s2_densite;
            else
                if (max(s2_densite) == 0) then  s2_densite = zeros(s2_densite); else s2_densite = s2_densite/max(s2_densite);end;
            end;
//        end;
        tt = [tt;t(ii)];
        M1 = [M1;s2_densite];
        if (anim > 1) then 
            subplot(2,1,2);
            plot(f(1:$/2),s2_densite(1,1:$/2));
            drawnow();
        end;
    end;
    M1 = M1(:,1:$/2);
    f= f(1:$/2);
    if (anim > 0) then 
        subplot(2,1,2);
        xset("colormap",jetcolormap(64));
        Sgrayplot(tt,f/19.49,M1(:,1:$-1)/19.49);
    end;
endfunction

function out = dbv(in)
    in(find(in==0))= -%inf;
    out = 20 * log10(abs(in));
endfunction

function s2f = filtrageVitesse(s2)
    Fs = 44100;
    [wft,wfm,fr]=wfir('bp',64,[1000/Fs 8000/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction


function s2f = filtrageHigh(s2)
    Fs = 44100;
    [wft,wfm,fr]=wfir('bp',64,[14000/Fs 22000/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction

function s2f = filtrage(s2,FreqMin,FreqMax)
    Fs = 44100;
    [wft,wfm,fr]=wfir('bp',64,[FreqMin/Fs FreqMax/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction

function s2f = filtrageVitesseSpin(s2)
    Fs = 44100;
    [wft,wfm,fr]=wfir('bp',33,[0/Fs 6000/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction

function s2f = filtrageSpin2(s2)
    Fs = 44100;
    [wft,wfm,fr]=wfir('bp',64,[0/Fs 200/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction


function afficheMesCourbes()
    chdir('D:\Users\f009770\Documents\Golf\portaudio_0.2\');
    exec('D:\Users\f009770\Documents\Golf\portaudio_0.2\loader.sce',-1)
    chdir('D:\Users\f009770\Documents\Golf\Radar');
    stacksize('max');
    fichier = 'BalleFil5Tombe.wav';
    fichier = 'fer7Radar.wav';
    [z,Fs,bits]=wavread(fichier); // lecture du fichier wav
    s2 = z(2,:);// prise en compte uniquement du canal 2, car le 1 n'est pas utilise dans mon appli
    s2 = s2 -mean(s2); // recentrage du signal autour de l'axe abscice.
    //s2f=filtrageVitesse(s2(6500:11000)); // fer7_5
    s2f=filtrageVitesse(s2(1:17500)); // fer7Radar.wav
    [tt1,f1,M1]=animFFT(s2f,44100,30,0);
    [tt2,f2,M2]=animFFT(s2f,44100,300,0);
    [tt3,f3,M3]=animFFT(s2f,44100,600,0);
    [tt4,f4,M4]=animFFT(s2f,44100,1200,0);
    [tt5,f5,M5]=animFFT(s2f,44100,3000,0);
    figure();
    subplot(3,2,1);plot(s2f);
    subplot(3,2,2);xset("colormap",hotcolormap(64));Sgrayplot(tt1,f1/19.49,M1/19.49);title("Fenetre 30 pts km/h filtre 1kHz-6kHz");
    subplot(3,2,3);xset("colormap",hotcolormap(64));Sgrayplot(tt2,f2/19.49,M2/19.49);title("Fenetre 300 pts km/h filtre 1kHz-6kHz");
    subplot(3,2,4);xset("colormap",hotcolormap(64));Sgrayplot(tt3,f3/19.49,M3/19.49);title("Fenetre 600 pts km/h filtre 1kHz-6kHz");
    subplot(3,2,5);xset("colormap",hotcolormap(64));Sgrayplot(tt4,f4/19.49,M4/19.49);title("Fenetre 1200 pts km/h filtre 1kHz-6kHz");
    subplot(3,2,6);xset("colormap",hotcolormap(64));Sgrayplot(tt5,f5/19.49,M5/19.49);title("Fenetre 3000 pts km/h filtre 1kHz-6kHz");

    s2f=filtrageVitesse(s2(1:7000)); 
    [tt5,f5,M5]=animFFT(s2f,44100,300,0);
    M5Sqr = M5.^2;
    figure();plot(f5/19.49,sum(M5Sqr,'r'));
    [v,l]=max(sum(M5Sqr,'r'));
    vBall = f5(l)/19.49
    vClubMax = vBall /1.2;
    vClubMin = vBall / 1.5;
    ll = find((f5/19.49) < vClubMax);
    [v,l]=max(sum(M5Sqr(:,ll),'r'));
    vClub = f5(l)/19.49
    SmashFactor = vBall / vClub

    s2f=filtrageSpin2(s2(1:30000));
    [tt1,f1,M1]=animFFT(s2f,44100,30,0);
    [tt2,f2,M2]=animFFT(s2f,44100,300,0);
    [tt3,f3,M3]=animFFT(s2f,44100,600,0);
    [tt4,f4,M4]=animFFT(s2f,44100,1200,0);
    [tt5,f5,M5]=animFFT(s2f,44100,3000,0);
    figure();
    subplot(3,2,1);plot(s2f);
    subplot(3,2,2);xset("colormap",hotcolormap(64));Sgrayplot(tt1,f1*60,M1*60);title("Fenetre 30 pts RPM filtre 0kHz-200Hz");
    subplot(3,2,3);xset("colormap",hotcolormap(64));Sgrayplot(tt2,f2*60,M2*60);title("Fenetre 300 pts RPM filtre 0kHz-200Hz");
    subplot(3,2,4);xset("colormap",hotcolormap(64));Sgrayplot(tt3,f3*60,M3*60);title("Fenetre 600 pts RPM filtre 0kHz-200Hz");
    subplot(3,2,5);xset("colormap",hotcolormap(64));Sgrayplot(tt4,f4*60,M4*60);title("Fenetre 1200 pts RPM filtre 0kHz-200Hz");
    subplot(3,2,6);xset("colormap",hotcolormap(64));Sgrayplot(tt5,f5*60,M5*60);title("Fenetre 3000 pts RPM filtre 0kHz-200Hz");

    s2f=filtrageVitesse(s2(1:6000));
    [tt1,f1,M1]=animFFT(s2f,44100,30,0);
    [tt2,f2,M2]=animFFT(s2f,44100,300,0);
    [tt3,f3,M3]=animFFT(s2f,44100,600,0);
    [tt4,f4,M4]=animFFT(s2f,44100,1200,0);
    [tt5,f5,M5]=animFFT(s2f,44100,3000,0);
    figure();
    subplot(3,2,1);plot(s2f);
    subplot(3,2,2);xset("colormap",matcolormap(64));Sgrayplot(tt1,f1*60,M1*60);title("Fenetre 30 pts RPM filtre 1kHz-6kHz");
    subplot(3,2,3);xset("colormap",matcolormap(64));Sgrayplot(tt2,f2*60,M2*60);title("Fenetre 300 pts RPM filtre 1kHz-6kHz");
    subplot(3,2,4);xset("colormap",matcolormap(64));Sgrayplot(tt3,f3*60,M3*60);title("Fenetre 600 pts RPM filtre 1kHz-6kHz");
    subplot(3,2,5);xset("colormap",matcolormap(64));Sgrayplot(tt4,f4*60,M4*60);title("Fenetre 1200 pts RPM filtre 1kHz-6kHz");
    subplot(3,2,6);xset("colormap",matcolormap(64));Sgrayplot(tt5,f5*60,M5*60);title("Fenetre 3000 pts RPM filtre 1kHz-6kHz");
endfunction


function [vClub, vBall, SmashFactor,thetaLoft, ShafLeanImp, launchAngle, SpinZ] = Info(M5,f5,Club)
    M5Sqr = M5.^2;
    //figure();g=gca();g.axes_reverse=["on","off","off"];plot(sum(M5.^2,'r'),f5/19.49);
    [v,l]=max(sum(M5Sqr,'r')); // 2 version, a confirmer !!
    //[v,l]=max(M5Sqr,'c');
    vBall = max(f5(l)/19.49);
    vClubMax = vBall /1.2;
    vClubMin = vBall / 1.5;
    ll = find(((f5/19.49) >= vClubMin) & ((f5/19.49) <= vClubMax));
    [v,l]=max(sum(M5Sqr(:,ll),'r'));
    vClub = f5(ll(l))/19.49;
    SmashFactor = vBall / vClub;
    [thetaLoft, ShafLeanImp, launchAngle, SpinZ] = LaunchAngle(vBall, vClub, Club);
    //disp(SmashFactor,vClub, vBall);
endfunction

function [vBall, vClub, SmashFactor, thetaLoft, ShafLeanImp, launchAngle, SpinZC, SpinZM, SpinLR, gamaFacePath]=Info2(u, Club)
    //
    //  Recherche de la vitesse de la Balle
    //
    [wft,wfm,fr] = wfir('bp',256,[1300/Fs 5000/Fs ],'hm',[-1 -1]); // passe bande
    xf = filter(wft,1,u); // passe bande filtrage centre sur 1kHz 6kHz
    [M5,tt5,f5]=animDensite(xf,44100, 256 ,32 , 0, -15,1);
    M5Sqr = M5.^2;
    [v,l]=max(sum(M5Sqr,'r')); // 2 version, a confirmer !!
    FBall = max(f5(l));
    vBall = FBall / 19.49;
    [wft1,wfm,fr] = wfir('sb',255,[(FBall*.9)/Fs (FBall*1.1)/Fs ],'hm',[-1 -1]); // coupe bande autour de la balle 

    //
    // Recherche de la vitesse du Club
    //
    [M5,tt5,f5]=animDensite(filter(wft,1,xf),44100, 256 ,32 , 0, -150,0);
    [m,k] = max(sum(M5,'c')); tt5(k);// temps du shoot
    [m,k] = max(sum(M5,'r')); 
    FClub = f5(k);
    vClub = FClub/19.49
    [wft2,wfm,fr] = wfir('sb',255,[(FClub*.9)/Fs (FClub*1.1)/Fs ],'hm',[-1 -1]); // coupe bande autour de la club 
    //
    //
    //
    [wft3,wfm,fr] = wfir('hp',255,[(FBall*1.1)/Fs (FBall*3)/Fs ],'hm',[-1 -1]); // Passe haut arpès de la balle 
    [M5,tt5,f5]=animDensite(filter(wft3,1,xf),44100, 1024 ,128 , 0, -150,1);
    //fig = figure();fig.color_map = jetcolormap(64);Sgrayplot(tt5,f5,M5(:,1:$-1));
    //f=figure();plot(f5,sum(M5(1:$,1:$-1),'r'),'r'); // vitesse du shaft (1er pic), vitesse de la balle 2eme pic)
    [m,k] = max(sum(M5,'r')); 
    FreqSpinMax = f5(k);    
    pause
    [wft4,wfm,fr] = wfir('lp',255,[(FBall*0.9)/Fs (FBall*3)/Fs ],'hm',[-1 -1]); // Passe bas avant de la balle 
    [M5,tt5,f5]=animDensite(filter(wft4,1,xf),44100, 1024 ,128 , 0, -150,1);
    [m,k] = max(sum(M5,'r')); 
    FreqSpinMin = f5(k);
    //FBall - FreqSpinMin;
    //FreqSpinMax - FBall;
    SpinLR = Freq2RpmSpin( 2*FBall - FreqSpinMin -FreqSpinMax); // spin Left Rigth
    SpinZM = Freq2RpmSpin(( - FreqSpinMin + FreqSpinMax )/2);
    SmashFactor = vBall / vClub;
    [thetaLoft, ShafLeanImp, launchAngle, SpinZC, gamaFacePath] = LaunchAngle(vBall, vClub, Club, SpinLR);
    //disp(SmashFactor,vClub, vBall);
endfunction




function [test, M5, tt5, f5, vClub, vBall, SmashFactor,thetaLoft, ShafLeanImp, launchAngle, SpinZ] = LaunchMonitoring(test, Coeff, spin)
    /////////////////////////// Affichage des courbes Simulé de références //////////////
    /////////////////////////// avec la fft capturée                       //////////////
    // lecture du signal
    // lecture de largeur de spectre se fait à -20db
    //
    //fichier = 'serie211.wav';
    forder = 64;
    //[test,Fs,bits] = wavread(fichier); // serie211 : 122.68kmh et 154.23kmh
    test = test - mean(test);
    [wft, wfm, fr] = wfir('bp',forder,[0.044 0.09],'hm',[-1 -1]);
    //Fs = 44100;
    nbEchantillon = 1024*1;
    // boucle de détection de début de swing, ou le joueur bouge
    // l'indice ii donne le début du signal
    for ii=2:size(test , 2)/nbEchantillon,
        s2_fft = abs(real(fft(filter(wft,1, test((ii)*nbEchantillon+1:nbEchantillon*(ii+1))))));
        if (max(s2_fft, 'c') > 3) then,
            break;
        end;
    end;//
    // Identificatin de la vitesse de club
    //[wft,wfm,fr] = wfir('bp',48,[0.044 0.09],'hm',[-1 -1]);
    s2_fft = abs(real(fft(filter(wft,1, test((ii)*nbEchantillon+1:nbEchantillon*(ii+1))))));
    f1 = Fs*(0:(size(s2_fft,2))-1)/size(s2_fft,2);
    //figure();plot(f1(1:$/2)/19.49, s2_fft(1:$/2)/max(s2_fft(1:$/2)),'b');
    [m,k] = max(s2_fft,'c');
    VClub = Fs*((k)-1)/size(s2_fft,2)/19.49;//vitesse probable du club, qui est la première détection de vitesse seuille

    // Identification de la vitesse de balle probable
    s2_fft = abs(real(fft(filter(wft,1, test((ii+4)*nbEchantillon+1:nbEchantillon*(ii+5))))));
    //f1 = Fs*(0:(size(s2_fft,2))-1)/size(s2_fft,2);
    //plot(f1(1:$/2)/19.49, s2_fft(1:$/2)/max(s2_fft(1:$/2)),'r');
    [m,k] = max(s2_fft,'c');
    VBall = Fs*((k)-1)/size(s2_fft,2)/19.49;//vitesse probable de la balle, qui est la première détection de vitesse seuil f1 = Fs*((k)-1)/size(s2_fft,2)

    [M5,tt5,f5]=animDensite(filter(wft,1, test((ii-1)*nbEchantillon+1:nbEchantillon*(ii+10))),44100, 1024 ,16 , 0, -70, 1);
    //fig = figure();fig.color_map = jetcolormap(64);Sgrayplot(tt5,f5/19.49,M5/19.49);
    [vClub, vBall, SmashFactor,thetaLoft, ShafLeanImp, launchAngle, SpinZ] = Info(M5,f5,'7');

    // identification précise de la vitesse de la balle avec un filtrage passe bande fin
    freqC = VBall*19.49/Fs ;
    [wft,wfm,fr] = wfir('bp',forder,[freqC freqC+0.000001 ],'hm',[-1 -1]);
    s2_fft = abs(real(fft(filter(wft,1, test((ii+4)*nbEchantillon+1:nbEchantillon*(ii+8))))));
    //f1 = Fs*(0:(size(s2_fft,2))-1)/size(s2_fft,2);
    //plot(f1(1:$/2)/19.49, s2_fft(1:$/2)/max(s2_fft(1:$/2)),'r');
    [m,k] = max(s2_fft,'c');
    VBall = Fs*((k)-1)/size(s2_fft,2)/19.49;//vitesse probable de la balle, qui est la première détection de vitesse seuil

    ///////////////////////////
    // calcul du signal de référence simulé en fonction de la vitesse de balle pour identifier le spin
    //
    //t = (0:size(f1, 2)-1)/Fs;
    //spin = 5500; //a déterminer par corrélation entre simulation et capture

    Ref_total = GenereSignalSimu(44100, 4096, 0.03, VClub, VBall, spin, Coeff, 0);
    ff1 = Fs*(0:(size(Ref_total,2))-1)/size(Ref_total,2); 

    [wft,wfm,fr] = wfir('bp',forder,[(VBall-5)*19.49/Fs (VBall+5)*19.49/Fs],'hm',[-0 -0]);
    //Ref_total_fft = abs(real(fft(Ref_total)));//
    Ref_total_fft = abs(real(fft(filter(wft,1,Ref_total))));

    Ref_spin  = GenereSignalSimu(44100, 4096, 0.03, VClub, VBall, spin, [0, 1, 0],0);
    [wft,wfm,fr] = wfir('bp',forder,[(VBall-5)*19.49/Fs (VBall+5)*19.49/Fs],'hm',[-1 -1]);
    Ref_spin_fft = abs(real(fft( Ref_spin)));//

    Ref_ball = GenereSignalSimu(44100, 4096, 0.03, VClub, VBall, spin, [1, 0, 0],0);
    [wft,wfm,fr] = wfir('bp',forder,[(VBall-5)*19.49/Fs (VBall+5)*19.49/Fs],'hm',[-1 -1]);
    Ref_ball_fft = abs(real(fft(filter(wft,1,Ref_ball)))); // 

    Ref_club = GenereSignalSimu(44100, 4096, 0.03, VClub, VBall, spin, [0, 0, 1],0);
    [wft,wfm,fr] = wfir('bp',forder,[(VClub-5)*19.49/Fs (VClub+5)*19.49/Fs],'hm',[-1 -1]);
    Ref_club_fft = abs(real(fft(Ref_club))); // 

    //////////////////////////////////////////
    // affichage des courbes simulées et captées
    figure();
    plot2d(ff1(1:$/2)/19.49,[ ...
    Ref_total_fft(1:$/2)/max(Ref_total_fft(1:$/2)); ...
    Coeff(1)*Ref_ball_fft(1:$/2)/max(Ref_ball_fft(1:$/2));...
    Coeff(2)*Ref_spin_fft(1:$/2)/max(Ref_spin_fft(1:$/2));...
    Coeff(3)*Ref_club_fft(1:$/2)/max(Ref_club_fft(1:$/2))]');
    f1 = Fs*(0:(size(s2_fft,2))-1)/size(s2_fft,2);
    plot(f1(1:$/2)/19.49, s2_fft(1:$/2)/max(s2_fft(1:$/2)),'r');

    //    freqC = VBall*19.49/Fs ;
    //    [wft,wfm,fr] = wfir('sb',129,[freqC freqC+0.0000001 ],'re',[-1 -1]);
    //    s2_fft = abs(real(fft(filter(wft,1, test((ii+4)*nbEchantillon+1:nbEchantillon*(ii+8))))));
    //    plot(f1(1:$/2)/19.49, s2_fft(1:$/2)/max(s2_fft(1:$/2)),'r');
    //

    legends(['Signal Total';'Signal Ball: ' + string(VBall) + ' kmh';'Signal Spin: '+ string(spin(1))+' '+string(spin($))+'rpm';'Signal Capturé'; 'Signal Club VClub: ' + string(VClub) + ' kmh'],[1 2 3 5 4],opt=1);



    //    Pxy = fft(filter(wft,1, test((ii+4)*nbEchantillon+1:nbEchantillon*(ii+8))));
    //    figure();
    //    subplot(2,1,1);plot(ff1(1:$/2),Pxy(1:$/2));
    //    a=angle(Pxy(1:$/2));
    //    subplot(2,1,2);plot(ff1(1:$/2),a);
    //
    //    Pxy = fft(filter(wft,1, Ref_total/10));
    //    //figure();
    //    subplot(2,1,1);plot(ff1(1:$/2),Pxy(1:$/2),'r');
    //    a=angle(Pxy(1:$/2));
    //    subplot(2,1,2);plot(ff1(1:$/2),a,'r');
endfunction



//-----------------------------------------------------------------------------
// Written by Philippe.CASTAGLIOLA@univ-nantes.fr
// Université de Nantes & IRCCyN UMR CNRS 6597
//-----------------------------------------------------------------------------
function Y=savitzkygolayM(X,p,nL,nR)
    //-----------------------------------------------------------------------------
    [argout,argin]=argn()
    if (argin<3)|(argin>4)
        error("incorrect number of arguments")
    end
    if (p<=0)|(p~=floor(p))
        error("argument ''p'' must be an integer >= 1")
    end
    if (nL<0)|(nL~=floor(nL))
        error("argument ''nL'' must be an integer >= 0")
    end
    if argin==3
        nR=nL
    end
    if (nR<0)|(nR~=floor(nR))
        error("argument ''nR'' must be an integer >= 0")
    end
    n1=nL+nR+1
    if n1<p
        error("condition nL+nR+1 >= p not satisfied")
    end
    [row,col]=size(X)
    n=row*col
    X=[X(1)*ones(nL,1);matrix(X,n,1);X(n)*ones(nR,1)]
    n=n+nL+nR
    C=pinv(cumprod([ones(n1,1),(-nL:nR)'*ones(1,p)],"c"))
    c=C(1,:)
    Y=zeros(X)
    for i=1:n1
        Y(nL+1:n-nR)=Y(nL+1:n-nR)+X(i:n-n1+i)*c(i)
    end
    Y=matrix(Y(nL+1:n-nR),row,col)
endfunction

////////////////////////////////////////////////////////////////////////////////////////////////
//This file is part of the Cardiovascular Wawes Analysis toolbox
//Copyright (C) 2014 - INRIA - Serge Steer
//This file must be used under the terms of the CeCILL.
//This source file is licensed as described in the file COPYING, which
//you should have received as part of this distribution.  The terms
//are also available at
//http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
function y=sgolayfilt(X,varargin)
    //filter signal using  Savitzky-Golay Filter.
    // y=sgolayfilt(X,B)
    // y=sgolayfilt(X,k,nf [,w]) 
    //
    //   X :
    //   B : a real n by n array: the set of filter coefficients: the early rows
    //       of B smooth based on future values and later rows smooth based on
    //       past values, with the middle row using half future and half past.
    //       In particular, you can use row i to estimate x(k) based on the i-1
    //       preceding values and the n-i following values of x values as 
    //       y(k) = B(i,:) * x(k-i+1:k+n-i).

    //   k : a positive scalar with integer value: the polynomial order, must
    //        be odd
    //   nf : a positive scalar with integer value: the FIR filter length,
    //        must be odd and greater the k+1 
    //   w : a real vector of length nf with positive entries: the weights.
    //         If omitted no weights are applied.   
    //   
    //   References:

    //   - Abraham Savitzky et Marcel J. E. Golay, « Smoothing and
    //     Differentiation of Data by Simplified Least Squares Procedures »,
    //     Analytical Chemistry, vol. 8, no 36,‎ 1964, p. 1627–1639 (DOI 10.1021/ac60214a047)

    //   - http://en.wikipedia.org/wiki/Savitzky%E2%80%93Golay_filter
    if type(X)<>1|~isreal(X) then
        error(msprintf(_("%s: Wrong type for argument %d: Real matrix expected.\n"),...
        "sgolayfilt",1))
    end
    if size(X,1) == 1 then X = X(:);end

    if or(size(varargin)==[2 3]) then
        B = sgolay(varargin(:))
    else
        B=varargin(1)
        if type(B)<>1|~isreal(B) then
            error(msprintf(_("%s: Wrong type for argument %d: Real matrix expected.\n"),...
            "sgolayfilt",2))
        end
    end
    n=size(B,1);
    if size(X,1) < n, 
        error(msprintf(_("%s: Wrong size for argument %d: At least %d expected.\n"),"sgolayfilt",1,size(B,1)))
    end

    // The first k rows of B are used to filter the first k points
    // of the data set based on the first n points of the data set.
    // The last k rows of B are used to filter the last k points
    // of the data set based on the last n points of the dataset.
    // The remaining data is filtered using the central row of B.
    k = floor(n/2);
    z = filter(B(k+1,:), 1, X);
    y = [B(1:k,:)*X(1:n,:) ; z(n:$,:) ; B(k+2:n,:)*X($-n+1:$,:) ];
endfunction

///////////////////////////////////////////////////////////////////////////////////////////////

//This file is part of the Cardiovascular Wawes Analysis toolbox
//Copyright (C) 2014 - INRIA - Serge Steer
//This file must be used under the terms of the CeCILL.
//This source file is licensed as described in the file COPYING, which
//you should have received as part of this distribution.  The terms
//are also available at
//http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
function [B,C] = sgolay(k,nf,w)
    // Savitzky-Golay Filter Design.
    //   k : a positive scalar with integer value: the polynomial order
    //   nf : a positive scalar with integer value: the FIR filter length,
    //        must be odd and greater the k+1 
    //   w : a real vector of length nf with positive entries: the
    //       weights. If omitted no weights are applied.

    //   B : a real n by n array: the set of filter coefficients: the early rows
    //       of B smooth based on future values and later rows smooth based on
    //       past values, with the middle row using half future and half past.
    //       In particular, you can use row i to estimate x(k) based on the i-1
    //       preceding values and the n-i following values of x values as 
    //       y(k) = B(i,:) * x(k-i+1:k+n-i).

    //   C : a real n by k+1 array: the matrix of differentiation filters.  Each
    //       column of C is a differentiation filter for derivatives of order
    //       P-1 where P is the column index.  Given a signal X with length nf,
    //       an estimate of the P-th order derivative of its middle value can be
    //       found from:
    //                      (P)
    //                     X   ((nf+1)/2) = P!*C(:,P+1)'*X
    //   References:

    //   - Abraham Savitzky et Marcel J. E. Golay, « Smoothing and
    //     Differentiation of Data by Simplified Least Squares Procedures »,
    //     Analytical Chemistry, vol. 8, no 36,‎ 1964, p. 1627–1639 (DOI 10.1021/ac60214a047)

    //   - http://en.wikipedia.org/wiki/Savitzky%E2%80%93Golay_filter

    if type(k)<>1|int(k)<>k|size(k,'*')<>1 then
        error(msprintf(_("%s: Wrong value for input argument #%d: An integer value expected.\n"),"sgolay",2))
    end

    if k > nf-1 then
        error('The degree must be less than the frame length.'),
    end
    if type(k)<>1|int(k)<>k|size(k,'*')<>1 then
        error(msprintf(_("%s: Wrong type for input argument #%d: a scalar with integer value expected.\n"),...
        "sgolay",1))
    end

    if type(nf)<>1|int(nf)<>nf|size(nf,'*')<>1 then
        error(msprintf(_("%s: Wrong type for input argument #%d: a scalar with integer value expected.\n"),...
        "sgolay",2))
    end

    if modulo(nf,2)<>1 then
        error(msprintf(_("%s: Wrong value for input argument #%d: Must be odd.\n"),"sgolay",2))
    end
    if nf<=k then
        error(msprintf(_("%s: Incompatible input arguments #%d and #%d: Argument #%d expected to be less than argument #%d.\n"),"sgolay",1,2,2,1))
    end

    //compute the Vandermonde matrix
    J=(ones(k+1,1)*(-(nf-1)./2:(nf-1)./2)).^((0:k)'*ones(1,nf));
    if argn(2)==3 then
        if type(w)<>1|~isreal(w) then
            error(msprintf(_("%s: Wrong type for argument %d: Real vector expected.\n"),...
            "sgolay",3))
        end
        if size(w,"*")<>nf then
            error(msprintf(_("%s: Incompatible input arguments #%d and #%d\n"),"sgolay",2,3))
        end
        // Check to see if all elements are positive
        if min(w) <= 0 then
            error(msprintf(_("%s: Wrong values for input argument #%d: Elements must be positive.\n"),...
            "sgolay",3))

        end
        // Diagonalize the vector to form the weighting matrix
        J = J*diag(sqrt(w))
    end
    //Compute the matrix of differentiators C=J'/(J*W*J')
    C = pinv(J); 
    // Compute the projection matrix B
    B = C*J;

endfunction

///////////////////////////////////////////////////////////////////////////////////////////////

function [s1, s2_fft] = HighSpeed()
    figure();plot(1);ax = gca();ax.auto_clear = 'on';
    Fs = 44100;
    N = 512;//Fs*0.01;
    f = Fs*(0:(N)-1)/N;
    [wft,wfm,fr] = wfir('bp',64,[0.04 0.09],'hm',[-1 -1]);
    //[s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande

    while %T
        //y = pa_recordwav(N,Fs ,1);
        s2_fft = abs(real(fft(filter(wft,1,pa_recordwav(N,Fs ,1)'))));
        //plot(f(2:$/2),s2_fft(2:$/2));
        //s2_densite_real = abs(real(s2_fft.*conj(s2_fft)));
        //plot(f(2:$/16),s2_densite_real(2:$/16));
        //[m,k]=max(s2_densite_real);
        //m
        //f(k)/19.49
        if (max(s2_fft,'c') > 3) then,
            break;
        end;
    end
    s1 = pa_recordwav(N1*1500,Fs ,1)';
    plot(s1);
endfunction


function Ref = GenereSignalSimu(Fs, N, TImpact, VClub, VBall, RPMSpin,Coeff, Phase)
    f1 = Fs*(0:N-1)/N;
    t = (0:size(f1,2)-1)/Fs;

    tclub=t;
    kImpact = find(TImpact==t);
    kFin = find((TImpact+0.02)==t);
    Fvb = zeros(tclub);
    Fvb(kImpact:$) = VBall*19.49;
    tvb=t;
    tvb(1:kImpact)=0;
    tclub(kFin-1:$)=0;
    Fclub = zeros(tclub);
    Fclub(1:kImpact*3) = (VClub*19.49);//*(-(linspace(-1.,1,size(tclub(1:kImpact*3),2))).^2+0);
    Fclub(1:kImpact*3) = Fclub(1:kImpact*3) - min(Fclub);
    if (size(RPMSpin,2) == 1)
        Fspin1 = zeros(tvb);
        Fspin1(kImpact:$) = RpmSpin2Freq(RPMSpin);
        Fspin2 = zeros(tvb);
        Fspin2(kImpact:$) = RpmSpin2Freq(RPMSpin);
    else
        Fspin1 = zeros(tvb);
        Fspin1(kImpact:$) = RpmSpin2Freq(RPMSpin(1));
        Fspin2 = zeros(tvb);
        Fspin2(kImpact:$) = RpmSpin2Freq(RPMSpin(2));
    end;

    CoeffClub = [-sin(linspace(%pi,2*%pi,size(find(tclub~=0),2))) * Coeff(3) ];
    CoeffClub = [CoeffClub tclub(kFin-2:$)];
    Ref = Coeff(1)*sin(2*%pi*Fvb.*tvb + Phase) + Coeff(2)*(1*sin(2*%pi*(Fvb - Fspin1).*tvb + Phase) + 1*sin(2*%pi*(Fvb + Fspin2).*tvb) + Phase) + Coeff(3).*sin(2*%pi*CoeffClub.*Fclub.*tclub + 0) ;//;
    Ref = 0.15*Ref/max(Ref);
endfunction

function F=TOC(f,psi,A,B)
    // f expression littérale de la fonction
    // psi expression littérale de psi
    // A facteur d'échelle
    // B valeur de temps
    // Le résultat est une matrice comportant autant de lignes
    // que de facteurs d'échelle A et autant de colonnes
    // que de valeurs de temps
    F=zeros(length(A),length(B));
    [nbl nbc]=size(F);
    // Valeur du facteur d'échelle
    for i=1:nbl
        a=A(i);
        // Valeur de temps
        for j=1:nbc
            b=B(j);
            // Intégration du produit de l'ondelette par la
            // fonction au point a,b
            w=inttrap(t,eval(f).*eval(psi));
            F(i,j)=w;
        end
    end
endfunction
///////////////////////////////////////////////////////////////////////////////////////////////
function [VBall, VClub, Spin, SpinAxis, xresult]=GetSwing(x, Fs, FreqMin, FreqMax, seuil)
    x = x - mean(x);
    v = format();
    format(5);
    nbEchantillon = 1024*1;
    // boucle de détection de début de swing, ou le joueur bouge
    // l'indice ii donne le début du signal
    ii=1;
    s2_fft = 0;
    //for ii=2:size(x , 2)/nbEchantillon,
    while ((max(s2_fft,'c') < seuil)),
        ii=ii+1;
        s2_fft = FftFiltree(x(nbEchantillon*(ii)+1:nbEchantillon*(ii+1)),Fs, FreqMin, FreqMax, 0);
        //if (max(s2_fft,'c') > seuil) then,
        //    break;
        //end;
    end;
    // Identification de la vitesse du Club
    [s2_fft, f1] = FftFiltree(x((ii+0.5)*nbEchantillon+1:nbEchantillon*(ii+1.5)),Fs,FreqMin,FreqMax, 0);
    [m,k] = max(s2_fft,'c');VClub = Fs*((k)-1)/size(s2_fft,2)/19.49;//vitesse probable du club, qui est la première détection de vitesse seuille

    // Identification de la vitesse de balle probable
    //[s2_ffta, f1] = FftFiltree(x((ii+4)*nbEchantillon+1:nbEchantillon*(ii+8)),Fs,FreqMin,FreqMax, 0);
    //[m,k] = max(s2_ffta,'c');VBall = Fs*((k)-1)/size(s2_ffta,2)/19.49;//vitesse probable de la balle, qui est la première détection de vitesse seuil f1 = Fs*((k)-1)/size(s2_fft,2)
    // itération 4 x, on prend le mas d chaque itération, puis le max des max.
    [s2_ffta, f1] = FftFiltree(x((ii+4)*nbEchantillon+1:nbEchantillon*(ii+5)),Fs,FreqMin,FreqMax, 0);
    [m1,k1] = max(s2_ffta,'c');VBall1 = Fs*((k1)-1);//vitesse probable de la balle, qui est la première détection de vitesse seuil f1 = Fs*((k)-1)/size(s2_fft,2)
    [s2_ffta, f1] = FftFiltree(x((ii+5)*nbEchantillon+1:nbEchantillon*(ii+6)),Fs,FreqMin,FreqMax, 0);
    [m2,k2] = max(s2_ffta,'c');VBall2 = Fs*((k2)-1);//vitesse probable de la balle, qui est la première détection de vitesse seuil f1 = Fs*((k)-1)/size(s2_fft,2)
    [s2_ffta, f1] = FftFiltree(x((ii+6)*nbEchantillon+1:nbEchantillon*(ii+7)),Fs,FreqMin,FreqMax, 0);
    [m3,k3] = max(s2_ffta,'c');VBall3 = Fs*((k3)-1);//vitesse probable de la balle, qui est la première détection de vitesse seuil f1 = Fs*((k)-1)/size(s2_fft,2)
    [s2_ffta, f1] = FftFiltree(x((ii+7)*nbEchantillon+1:nbEchantillon*(ii+8)),Fs,FreqMin,FreqMax, 0);
    [m4,k4] = max(s2_ffta,'c');VBall4 = Fs*((k4)-1);//vitesse probable de la balle, qui est la première détection de vitesse seuil f1 = Fs*((k)-1)/size(s2_fft,2)
    VBall = max([VBall1 VBall2 VBall3 VBall4])/size(s2_ffta,2)/19.49;
    
    //[s2_fft, f1] = FftFiltree(x((ii+4)*nbEchantillon+1:nbEchantillon*(ii+8)),Fs,(VBall-0.5)*19.49 , (VBall+.5)*19.49, 0);
    //[s2_fftb, f1] = FftFiltree(x((ii+4)*nbEchantillon+1:nbEchantillon*(ii+8)),Fs,(VBall*19.49-RpmSpin2Freq(10000)) , (VBall*19.49-RpmSpin2Freq(2000)), 0);
    //[m k]=max(s2_fftb); MIN = (f1(k));
    [s2_fftb, f1] = FftFiltree(x((ii+4)*nbEchantillon+1:nbEchantillon*(ii+5)),Fs,(VBall*19.49-RpmSpin2Freq(10000)) , (VBall*19.49-RpmSpin2Freq(2000)), 0);
    [m1 k1]=max(s2_fftb); MIN1 = (f1(k1));
    [s2_fftb, f1] = FftFiltree(x((ii+5)*nbEchantillon+1:nbEchantillon*(ii+6)),Fs,(VBall*19.49-RpmSpin2Freq(10000)) , (VBall*19.49-RpmSpin2Freq(2000)), 0);
    [m2 k2]=max(s2_fftb); MIN2 = (f1(k2));
    [s2_fftb, f1] = FftFiltree(x((ii+6)*nbEchantillon+1:nbEchantillon*(ii+7)),Fs,(VBall*19.49-RpmSpin2Freq(10000)) , (VBall*19.49-RpmSpin2Freq(2000)), 0);
    [m3 k3]=max(s2_fftb); MIN3 = (f1(k3));
    [s2_fftb, f1] = FftFiltree(x((ii+7)*nbEchantillon+1:nbEchantillon*(ii+8)),Fs,(VBall*19.49-RpmSpin2Freq(10000)) , (VBall*19.49-RpmSpin2Freq(2000)), 0);
    [m4 k4]=max(s2_fftb); MIN4 = (f1(k4));
    MIN = min([MIN1 MIN2 MIN3 MIN4]);
//    [wft,wfm,fr] = wfir('bp',64,[(VBall*19.49 - RpmSpin2Freq(10000))/Fs (VBall*19.49  - RpmSpin2Freq(2000))/Fs ],'re',[-1 -1]);
//    s2_fftb = real(abs(fft(filter(wft,1,x((ii+4)*nbEchantillon+1:nbEchantillon*(ii+8))))));
//    f1 = Fs*(0:(size(s2_fftb,2))-1)/size(s2_fftb,2);
//    [m k]=max(s2_fftb); MIN = (f1(k));
//    
    //[s2_fftc, f1] = FftFiltree(x((ii+4)*nbEchantillon+1:nbEchantillon*(ii+8)),Fs,(VBall*19.49+RpmSpin2Freq(2000)) , (VBall*19.49+RpmSpin2Freq(10000)), 0);
    //[m k]=max(s2_fftc); MAX = (f1(k));
    [s2_fftc, f1] = FftFiltree(x((ii+4)*nbEchantillon+1:nbEchantillon*(ii+5)),Fs,(VBall*19.49+RpmSpin2Freq(2000)) , (VBall*19.49+RpmSpin2Freq(10000)), 0);
    [m1 k1]=max(s2_fftc); MAX1 = (f1(k1));
    [s2_fftc, f1] = FftFiltree(x((ii+5)*nbEchantillon+1:nbEchantillon*(ii+6)),Fs,(VBall*19.49+RpmSpin2Freq(2000)) , (VBall*19.49+RpmSpin2Freq(10000)), 0);
    [m2 k2]=max(s2_fftc); MAX2 = (f1(k2));
    [s2_fftc, f1] = FftFiltree(x((ii+6)*nbEchantillon+1:nbEchantillon*(ii+7)),Fs,(VBall*19.49+RpmSpin2Freq(2000)) , (VBall*19.49+RpmSpin2Freq(10000)), 0);
    [m3 k3]=max(s2_fftc); MAX3 = (f1(k3));
    [s2_fftc, f1] = FftFiltree(x((ii+7)*nbEchantillon+1:nbEchantillon*(ii+8)),Fs,(VBall*19.49+RpmSpin2Freq(2000)) , (VBall*19.49+RpmSpin2Freq(10000)), 0);
    [m4 k4]=max(s2_fftc); MAX4 = (f1(k4));
    MAX = max([MAX1 MAX2 MAX3 MAX4]);
    //Spin = [(Freq2RpmSpin(-MIN+VBall*19.49) + Freq2RpmSpin(-VBall*19.49+MAX))/2 Freq2RpmSpin((MAX-VBall*19.49)-(VBall*19.49-MIN))];
    Spin = [(Freq2RpmSpin(-MIN+VBall*19.49) ) Freq2RpmSpin((MAX - VBall*19.49)) Freq2RpmSpin((MAX-VBall*19.49)-(VBall*19.49-MIN))];

    SpinAxis = asin(Spin(3)/sqrt(((Spin(1)+Spin(2))/2)^2+Spin(3)^2))*180/%pi;
    //V0Ballms*sin(LaunchAngle);                   // Vy
    //gamaFacePath = asin(Spin(3) / (V0initms(4)* Sac.coeffSpinLift(Sac.Type == Club)));// 

    xresult = x((ii)*nbEchantillon+1:nbEchantillon*(ii+8));
    figure();
    f1 = Fs*(0:(size(s2_ffta,2))-1)/size(s2_ffta,2);
    plot(f1(1:$/2), s2_ffta(1:$/2)/max(s2_ffta(1:$/2)),'black'); // Centré sur le mouvement de la balle avec un passe bande large
    f1 = Fs*(0:(size(s2_fft,2))-1)/size(s2_fft,2);
    plot(f1(1:$/2), s2_fft(1:$/2)/max(s2_fft(1:$/2)),'r');       // Centré sur la vitesse du Club avec un passe bande étroit +/- 10Hz
    f1 = Fs*(0:(size(s2_fftb,2))-1)/size(s2_fftb,2);
    plot(f1(1:$/2), s2_fftb(1:$/2)/max(s2_fftb(1:$/2)),'cyan');  // centré sur le Spin MIN
    f1 = Fs*(0:(size(s2_fftc,2))-1)/size(s2_fftc,2);
    plot(f1(1:$/2), s2_fftc(1:$/2)/max(s2_fftc(1:$/2)),'b');     // centré sur le Spin Max
    title(['VClub: '+ string(VClub) + '  VBall: ' + string(VBall)+ '  Spin: ' +  string(Spin(1)) + ' ' + string(Spin(2)) + ' ' + string(Spin(3))]);
    format(10);
endfunction 

function[x,Vm,Vc]=fmmod(Ec,Em,fm,fc,fs)
    //Ec -carrier amplitude in volts
    //Em - message signal amplitude in volts
    //fm - modulating signal frequency Hz
    //fc - carrier signal frequency in Hz
    //fs - sampling frequency in samples/sec
    //k - frequency sensitivity in Hz/volts
    t = 0:1/fs:1;
    Vm = Em*sin(2*%pi*fm*t);
    Vc = Ec*sin(2*%pi*fc*t);
    k = 1.5; 
    x =  Ec*sin((2*%pi*fc*t)+(k*Em/fm)*cos(2*%pi*fm*t));
    //x=2.5*cos ((1*3000*2*%pi*t) + 0.35* sin( 2*%pi*(3000-2000)*t)) ;
    subplot(3,1,1)
    plot(Vm)
    title('Modulating Signal')
    subplot(3,1,2)
    plot(Vc)
    title('Carrier Signal')
    subplot(3,1,3)
    plot(x);
    legend('FM Signal')
    title('Frequency Modulated Signal')
endfunction

function[y] = fmdemod(x,Vc,fc,fs)
    //x - FM modulated signal
    //Vc- carrier amplitude signal
    //Em - Message signal amplitude in volts
    //Ec - Carrier signal amplitude in volts
    //fc - Carrier signal frequency in Hz
    //fs - Sampling frequency in samples/sec
    Xdiff = diff(x); //Converting the FM signal into AM signal
    //Envelope changes are recovered by taking the difference
    //between successive samples
    Xdiff = [Xdiff,Xdiff($)];
    //AM demodulation using envelope detector
    Xdem = Xdiff.*Vc;
    //Digital IIR butterworth filter of 5th order, cutoff freuency = fc/fs
    H =  iir(5,'lp','butt',[fc/fs,0],[0,0]);
    num = coeff(H(2));
    den = coeff(H(3));
    num = num(length(num):-1:1);
    den = den(length(den):-1:1);
    [y,zi] =  filter(num,den,abs(Xdem));//AC to DC conversion and LPF filtering
    y = filter(num,den,y,zi);
    //plot(y,'r');
    //title('FM demodulated Signal')
endfunction

function[y] = pmdemod(x,Vc,Em,Ec,fc,fs)
    //x - FM modulated signal
    //Vc- carrier amplitude signal
    //Em - Message signal amplitude in volts
    //Ec - Carrier signal amplitude in volts
    //fc - Carrier signal frequency in Hz
    //fs - Sampling frequency in samples/sec
    Xdiff = diff(x); //Converting the FM signal into AM signal
    //Envelope changes are recovered by taking the difference
    //between successive samples
    Xdiff = [Xdiff,Xdiff($)];
    //AM demodulation using envelope detector
    Xdem = Xdiff.*Vc;
    //Digital IIR butterworth filter of 5th order, cutoff freuency = fc/fs
    H =  iir(5,'lp','butt',[fc/fs,0],[0,0]);
    num = coeff(H(2));
    den = coeff(H(3));
    num = num(length(num):-1:1);
    den = den(length(den):-1:1);
    [y,zi] =  filter(num,den,abs(Xdem));//AC to DC conversion and LPF filtering
    y = filter(num,den,y,zi);
    plot(y,'r');
    title('PM demodulated Signal')
endfunction

function [Rxx] = autocorrelation(x)
//Autocorrelation of a given Input Sequence
//Finding out the period of the signal using autocorrelation technique

L = length(x);
h = zeros(1,L);
for i = 1:L
  h(L-i+1) = x(i);
end
N = 2*L-1;
Rxx = zeros(1,N);
for i = L+1:N
   h(i) = 0;
end
for i = L+1:N
    x(i) = 0;
end
for n = 1:N
  for k = 1:N
    if(n >= k)
      Rxx(n) = Rxx(n)+x(n-k+1)*h(k);
    end
  end
end
disp('Auto Correlation Result is')
Rxx
disp('Center Value is the Maximum of autocorrelation result')
[m,n] = max(Rxx)
disp('Period of the given signal using Auto Correlation Sequence')
n
endfunction

function[y]=ampdemod(x,Vc,fc,fs)
    //x - AM modulated signal
    //Vc - carrier signal
    //fc - carrier frequency
    //Em - message signal amplitude
    //Ec- carrier signal amplitude
    xdem = x.*Vc;
    //IIR digital butterworth Low Pass filter of cutoff
    //frequency fc/fs and order 7
    H = iir(7,'lp','butt',[fc/fs,0],[.1,.1]);
    num = coeff(H(2));
    den = coeff(H(3));
    num = num(length(num):-1:1);
    den = den(length(den):-1:1);
    y = filter(num,den,xdem);
//    y = y/Em;
//    y = y-Ec;
//    plot(y,'r');
//    title('AM Demodulated Signal')
endfunction 
