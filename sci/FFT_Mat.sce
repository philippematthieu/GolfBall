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
////


/////////////////////////////////////////////////////////////////

function phase = angle(A)
    phase = atan(imag(A),real(A))
endfunction;

////////////////////////////////////////////////////////////////////
function [s2Centre, s2f] = plotFFT(s2,Fs)
    //[wft,wfm,fr]=wfir('bp',48,[1000/22050 5000/22050],'hm',[-1 -1]);
    [wft,wfm,fr]=wfir('bp',64,[500/Fs 6000/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
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
    //s2_densite(1,$/2+1:$) = [];
    figure();title(fichier + ' signal');plot2d(t,s2Centre);
    figure();title(fichier + ' fft complète');plot2d(f(2:$/2),s2_fft_real(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(fichier + ' fft filtrée');plot2d(f(2:$/2),s2f_fft_real(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(fichier + ' densite complète');plot2d(f(2:$/2),s2_densite(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(fichier + ' densite filtrée');plot2d(f(2:$/2),s2f_densite(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(fichier + ' densite filtrée moyenne');plot2d(f(2:$/2),s2f_densite_real_moy(2:$/2));plot2d(fr*Fs,wfm);
    figure();title(fichier + ' densite  moyenne');plot2d(f(2:$/2),s2_densite_real_moy(2:$/2));plot2d(fr*Fs,wfm);    
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
function wrpm = Freq2Rpm(RadarFreq)
    wrpm = RadarFreq * 60 /(2*%pi*0.0215 * 19.49);
endfunction
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RadarFreq = Rpm2Freq(wrpm)
    RadarFreq = wrpm /(9.54929659643 / (0.0215 * 19.49));
endfunction
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// https://www.math.u-bordeaux.fr/~pjaming/stagetdsi2012/cohen.pdf
//%recouvrement avec des fenetres de 30ms toutes les 10 ms
function [T,X1,H1,k,M,tt,f_y]=splitSignal(s2Centre,Fs, Nf, Nr)
    T=0;
    X1=0;
    H1=0;
    N=length(s2Centre);
    //Nf=0.03*Fs; // nb echantillons pour fenetre de 30ms
    //Nr=0.01*Fs; // nb echantillons pour fenetre de 10ms

    b=modulo(N,Nf);
    s2Centre=[s2Centre, zeros(Nf-b,1)'];
    //N=N+Nf-b;
    
    N=length(s2Centre);
    tau = 1 / Fs;
    t = (0:N - 1) * tau;
    k=1;
    M=[];
    f_y = Fs*(0:(Nf)-1)/Nf;
    while (N-(k*Nr+Nf)>0)
        M1 = fft(s2Centre((1:Nf)+ Nr*(k-1)));
        conjuguee_s2 = conj(M1);
        s2_densite = abs(real(M1.*conjuguee_s2));
        M = [M;s2_densite/max(s2_densite)];
        k=k+1; // calcul le nb echantillon de 10ms ;
    end
    f_y_save = f_y;
    M_save = M;
    t_x = (0:k - 2) * tau;
    tt = (0:max(t)/(size(t_x,2)-1):max(t));
    // la balle volle de 50 km/h à 300km/h
    // soit une fréquence de 970 Hertz à 5900 Hertz
    // affichage de la vitesse des objets > 50km/h
    f_y = f_y_save;
    M = M_save;
    LimiteHaute = f_y/19.49 > 300; // inférieur à 300 km/h
    f_y(LimiteHaute) = [];
    M(:,LimiteHaute) = [];
    LimiteBasse = f_y/19.49 < 10; // supérieur à 50 km/h
    f_y(LimiteBasse) = [];
    M(:,LimiteBasse) = [];

//    figure();
//    xset("colormap",hotcolormap(64));
//    colorbar(min(M)/19.49,max(M)/19.49);
//    Sgrayplot(tt,f_y/19.49,M/19.49);

//    H=hanning(Nf);
//    H1 = [];
//    H2 = [];
//    for n=1:k
//        H2 = [zeros(1,n*Nr) H zeros(1,N-(n*Nr+Nf))];
//        H1 = [H1;H2];
//    end
//    h1=H(1,Nf-Nr:Nf);
//    h2=H(1,Nf-2*Nr:Nf);
//    h3= H(Nf:-1:Nf-Nr);
//    h4= H(Nf:-1:Nf-2*Nr);
//    h1=[h1 zeros(1,N-length(h1))];
//    h2=[h2 zeros(1,N-length(h2))];
//    h3=[zeros(1,N-length(h3)) h3];
//    h4=[zeros(1,N-length(h4)) h4];
//    H1=[h1;h2;H1;h3;h4];
//    u=size(H1);
//    T=[];
//    X1 = [];
//    M = M_save;
//    f_y = f_y_save;
//    for i=1:u(1,1),
//        T(i,:) = H1(i,:).*s2Centre;
//    end;
//    X1=sum(T);
endfunction
//
//chdir('D:\Users\f009770\Documents\Golf\portaudio_0.2\');
//exec('D:\Users\f009770\Documents\Golf\portaudio_0.2\loader.sce',-1)
//chdir('D:\Users\f009770\Documents\Golf\Radar');
//stacksize('max')
//  recorderID = pa_defaultinputdeviceid();
//  //pa_printdeviceinfo(recorderID);
//
//
//  N = 500000;
//  Fs = 44100;
//  nbChannels = 1;
//  datas1 = pa_recordwav(N, Fs, recorderID, nbChannels);
////  datas2 = pa_recordwav(nbSamples, sampleRate, recorderID, nbChannels);
//  figure();
////  subplot(2,1,1);
//  plot(datas1)
////  subplot(2,1,2);
////plot(datas2)
//
//z=[datas1'; datas1'];
//
////[z,Fs,bits]=wavread('ZU_instants_2014.wav',[1 1000]);
//

// La fréquence pour la rotation de la balle devrait être de 200tr/min à 100000 tr/min
// soit de 87Hz à 440Hz !
//
// pour la vitesse du club, il varie de 1500Hz à 4.8kHz
//
// pour la vitesse de la balle (smach Factor de 1.2 ammateur à 1.5 Bubba W., moyenne 1.38), la vitesse varie de 1.9kHz à 5.8kHz)
// Donc en supposant que la fréquence la plus élevé soit le swing Max du Club, la frequence à chercher 
// pour la vitesse de balle est FréquenceRadar de Swing * SmshFactor Moyen de 1.38
// 
// calcul de la vitesse de rotation en rpm de balle :     diam            = 0.043;// Diametre Balle
//  ((((Fqball - Fqradial)/19.49)/60)*1000)/(2*%pi*0.0215) ==> Wrpm = dFreq * 6.3302168
//       Hz :          km/h : km/min : m/min : tr/min
// v = 2 * %pi * cos(L) * R / t
//


function [tt,f,M1] = animFFT(s2,Fs,nbEchantillon,pas,anim)
    N = size(s2,2);
    tau = 1 / Fs; // interval temporel de l'echantillonnage
    t = (0:N - 1) * tau; // construction du vecteur temps
    f=Fs*(0:(nbEchantillon)-1)/nbEchantillon;

    s2Centre = s2 - mean(s2); // recentrage du signal autour de l'axe abscice.
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
        conjuguee_s2 = conj(s2_fft);
        s2_densite = abs(real(s2_fft.*conjuguee_s2));
        tt = [tt;t(ii)];
        M1 = [M1;s2_densite/max(s2_densite)];
        if (anim > 1) then 
            subplot(2,1,2);
            plot(f(1:$/2),s2_densite(1,1:$/2)/max(s2_densite(1,1:$/2)));
            drawnow();
        end;
    end;
    M1 = M1(:,1:$/2);
    f= f(1:$/2);
    if (anim > 0) then 
        subplot(2,1,2);
        xset("colormap",jetcolormap(64));
        Sgrayplot(tt,f/19.49,M1/19.49);
    end;pause;
endfunction

function s2f = filtrageVitesse(s2)
    [wft,wfm,fr]=wfir('bp',64,[1000/Fs 8000/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction


function s2f = filtrageHigh(s2)
    [wft,wfm,fr]=wfir('bp',64,[14000/Fs 22000/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction

function s2f = filtrage(s2,FreqMin,FreqMax)
    [wft,wfm,fr]=wfir('bp',64,[FreqMin/Fs FreqMax/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction

function s2f = filtrageVitesseSpin(s2)
    [wft,wfm,fr]=wfir('bp',33,[0/Fs 6000/Fs],'tr',[-1 -1]); // définition de la fenetre du filtre passa bande
    [s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande
endfunction

function s2f = filtrageSpin2(s2)
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


///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////

chdir('D:\Users\f009770\Documents\Golf\portaudio_0.2\');
exec('D:\Users\f009770\Documents\Golf\portaudio_0.2\loader.sce',-1)
chdir('D:\Users\f009770\Documents\Golf\Radar');
stacksize('max');
//fichier = '400_TrMin.wav';
//fichier = '1150_TrMin.wav';
//fichier = 'BalleRoule3_smooth.wav';
//fichier = 'BalleRoule4_smooth.wav';
//fichier = 'BalleRoule5_smooth.wav';
//fichier = 'BalleRoule2_dimpled.wav';
//fichier = 'BalleRoule5_smooth';
//fichier = 'Driver5.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(11300:14200);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'Driver4.wav';
//fichier = 'Driver3.wav';[z,Fs,bits]=wavread(fichier);s2 = z;s2test = s2(10000:14500);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'Driver2.wav';
//fichier = 'Driver1.wav';
fichier = 'Fer7_5.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(6500:11200);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'Fer7_4.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(16950:21000);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'Fer7_3.wav';
//fichier = 'Fer7_2.wav';
//fichier = 'Fer7_1.wav';
//fichier = 'fer7Radar.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(1:4500);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = '1150_TrMin_Bruit.wav';
//fichier = '1150_TrMin.wav';
//fichier = 'BalleRoule1_dimpled.wav';
//fichier = '400_TrMinbruit.wav';
//fichier = 'roulage1.wav';
//fichier = 'BalleRoule3.wav';
//fichier = 'voiture1.wav';
//fichier = 'testRadar.wav';[z,Fs,bits]=wavread(fichier);s2 = z;s2test = s2(20000:60000);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'testRadar2.wav';[z,Fs,bits]=wavread(fichier);s2 = z;s2test = s2(20000:70000);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'testRadar3.wav';[z,Fs,bits]=wavread(fichier);s2 = z;s2test = s2(1:10000);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'testRadar4.wav';[z,Fs,bits]=wavread(fichier);s2 = z;s2test = s2(1:10000);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'roulage2.wav';
//fichier = 'lancer.wav';
//fichier = 'BalleFil.wav';
//fichier = 'BalleFil4Tourne.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(1:10000);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'BalleFil5Tombe.wav';
//fichier = 'Fer7_seul_1.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(58000:60600);[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'Fer7_seul_2.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(52000:55500);
//fichier = 'Fer7_seul_3.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(52000:55500);
//fichier = 'Fer7_seul_4.wav';[z,Fs,bits]=wavread(fichier);s2 = z(2,:);s2test = s2(52000:55500);
//fichier = 'RecordAudio.wav';;[z,Fs,bits]=wavread(fichier);s2=z(2,14000:24000);s2test = s2;[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'test2_1_dehors_metal.wav';[z,Fs,bits]=wavread(fichier);s2=z(2,:);s2test = s2;[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'test2_2_dehors_metal.wav';[z,Fs,bits]=wavread(fichier);s2=z(2,:);s2test = s2;[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'test2_3_dehors_metal.wav';[z,Fs,bits]=wavread(fichier);s2=z(2,:);s2test = s2;[s2Centre, s2f] = plotFFT(s2test,Fs);
//fichier = 'test2_4_dehors_metal.wav';[z,Fs,bits]=wavread(fichier);s2=z(2,:);s2test = s2(1000:9000);[s2Centre, s2f] = plotFFT(s2test,Fs);
[z,Fs,bits]=wavread(fichier); // lecture du fichier wav
s2 = z(2,:);// prise en compte uniquement du canal 2, car le 1 n'est pas utilise dans mon appli
[s2Centre, s2f] = plotFFT(s2test,Fs);

// pour le fer7_5
s2test = s2( 6700:7600);// swing
s2test = s2( 7600:8400);// swing
s2test = s2( 8500:10000);// swing
s2test = s2(10000:11000);// 
s2test = s2(11000:12000);// 

s2test = s2(6800:12500);// 


[s2Centre, s2f] = plotFFT(s2test,Fs);
figure();plot(s2Centre);

s2backswing = s2test(1:2100);
s2swing = s2test(2100:4000);
s2ball = s2test(4000:$);
figure();plot(s2test);
figure();plot(s2backswing);
figure();plot(s2swing);
figure();plot(s2ball);
plotFFT(s2test,Fs);
plotFFT(s2backswing,Fs);
plotFFT(s2swing,Fs);
plotFFT(s2ball,Fs);

[T,X1,H1,k,M,tt, f_y]=splitSignal(s2Centre,Fs);
figure();xset("colormap",hotcolormap(64));plot3d1(M(:,1:$/4));
[xx,yy,zz]=genfac3d(tt,f_y,M);
figure();xset("colormap",hotcolormap(64));plot3d1(xx,yy,zz);

///////////////////////////////////////////////////////////////////////////////////

Fs = 44100;
N = 44100/6;
TImpact = 1500;
tau = 1 / Fs; // interval temporel de l'echantillonnage
t = (0:N - 1) * tau; // construction du vecteur temps
tclub=t;
Fvb = zeros(tclub);
Fvb(TImpact:$) = 3000;
tvb=t;
tvb(1:TImpact)=0;
tclub(TImpact*2+1:$)=0;
Fclub = zeros(tclub);
Fclub(1:TImpact*2) = (max(Fvb)/1.35)*(-(linspace(-0.7,1,size(tclub(1:TImpact*2),2))).^2+1);
Fspin = zeros(tvb);
Fspin(TImpact:$) = 70;
s2test = sin(2*%pi*Fvb.*tvb)+sin(2*%pi*Fvb.*tvb-2*%pi*Fspin.*tvb)+sin(2*%pi*Fvb.*tvb+2*%pi*Fspin.*tvb)+4*sin(Fclub.*2*%pi.*tclub);figure();plot(s2);
s2 =  filtrageVitesse(s2);

[s2Centre, s2f] = plotFFT(s2test,Fs);

s2f =  filtrageVitesse(s2Centre);
//s2f =  filtrageVitesseSpin(s2Centre);
//s2f =  filtrage(s2Centre,1,3000);
[tt5,f5,M5,M]=animFFT(s2f,44100,128,0);

[i,j]=find(M5 == max(M5));
f5(j)/19.49 // vitesse max

/////////////////////////////////////////////////////////////////////////
//////// Calcul de la vitesse de balle suite à la animFFT ///////////////
/////////////////////////////////////////////////////////////////////////

function[vClub, vBall, SmashFactor] = Info(M5,f5)
    M5Sqr = M5.^2;
    //figure();plot(f5/19.49,sum(M5Sqr,'r'));
    [v,l]=max(sum(M5Sqr,'r'));
    vBall = f5(l)/19.49;
    vClubMax = vBall /1.2;
    vClubMin = vBall / 1.5;
    ll = find(((f5/19.49) >= vClubMin) & ((f5/19.49) <= vClubMax));
    [v,l]=max(sum(M5Sqr(:,ll),'r'));
    vClub = f5(ll(l))/19.49;
    SmashFactor = vBall / vClub;
    disp(SmashFactor,vClub, vBall);
endfunction


tic;[tt5,f5,M5]=animFFT(s2Centre,44100, 512 ,50 , 2);toc
[VClub, VBall] = Info(M5);
// l'idee est de déterminer l'angle d'envole entre le SmashFactor donnee par le constructeur
// et le smashfactor observe. Du coup on obtien le loft dynamic
// en appairant la vitesse du club mesuré au radar et celui calculé par le modèle.
// attention toute fois, il faut revoir la définition de la vitesse de club par le radar.
// la vitesse max du club n'est pas la vitesse du club à l'impact....
// impact club = début du vol de balle (T(vitesse enregistrée max))

[V0Clubkmh,dynamicLoft_deg] = BallGolf(VBall, 30, 0,VBall / VClub,0.04545,0.2)
[t,VOL,Res] = Golfball(18, VClub, '7', 0,0,dynamicLoft_deg-30 ,1);

/////////////////////////////////////////////////////////////////////////////

f = figure();f.color_map = jetcolormap(64);Sgrayplot(tt5,f5,M5);title("Fenetre 3000 pts Hz non filtré");xlabel("s");ylabel("Hz");
f = figure();f.color_map = matcolormap(64);Sgrayplot(tt5,f5,M5);title("Fenetre 3000 pts RPM non filtré");xlabel("s");ylabel("Hz");
f = figure();f.color_map = hotcolormap(64);Sgrayplot(tt5,f5,M);title("Fenetre 3000 pts Hz non filtré");xlabel("s");ylabel("Hz");
f = figure();f.color_map = jetcolormap(64);Sgrayplot(tt5,f5,M);title("Fenetre 3000 pts Hz non filtré");xlabel("s");ylabel("Hz");

/////////////////////////////////////////////////////////////////////////////////////

s2Centre2 = sin(Fvb*2*%pi*t+%pi/4);
a=angle(fft(s2Centre));
figure();subplot(2,1,1);plot(a)
subplot(2,1,2);plot(abs(real(fft(s2Centre))))

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fichier = 'fer7Radar.wav';
[z,Fs,bits]=wavread(fichier); // lecture du fichier wav
s2 = z(2,:);// prise en compte uniquement du canal 2, car le 1 n'est pas utilise dans mon appli
[s2Centre, s2f] = plotFFT(s2(1:10000),Fs);
s2f =  filtrageVitesse(s2Centre);
[tt5,f5,M5,M]=animFFT(s2f,44100,300,0);

s2f =  filtrage(s2,14000,22000);
[s2Centre, s2f] = plotFFT(s2f,Fs);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fichier = 'Fer7_5.wav';
[z,Fs,bits]=wavread(fichier); // lecture du fichier wav
s2 = z(2,:);// prise en compte uniquement du canal 2, car le 1 n'est pas utilise dans mon appli
[s2Centre, s2f] = plotFFT(s2(6800:11300),Fs);
s2f =  filtrageVitesseSpin(s2Centre);
[tt5,f5,M5,M]=animFFT(s2f,44100,600,0);
