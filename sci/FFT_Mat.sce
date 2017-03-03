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
/////////////////////////////////////////////////////////////////

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
//fichier = 'Driver5.wav';
//fichier = 'Driver4.wav';
//fichier = 'Driver3.wav';
//fichier = 'Driver2.wav';
//fichier = 'Driver1.wav';
//fichier = 'Fer7_5.wav';
//fichier = 'Fer7_4.wav';
//fichier = 'Fer7_3.wav';
//fichier = 'Fer7_2.wav';
//fichier = 'Fer7_1.wav';
//fichier = '1150_TrMin_Bruit.wav';
//fichier = '1150_TrMin.wav';
//fichier = 'BalleRoule1_dimpled.wav';
//fichier = '400_TrMinbruit.wav';
[z,Fs,bits]=wavread(fichier); // lecture du fichier wav
//[wft,wfm,fr]=wfir('bp',48,[1000/22050 5000/22050],'hm',[-1 -1]);
[wft,wfm,fr]=wfir('bp',33,[1000/Fs 10000/Fs],'hm',[-1 -1]); // définition de la fenetre du filtre passa bande
N=size(z,'c'); // definition du nombre d'échantillons
tau = 1 / Fs; // interval temporel de l'echantillonnage
t = (0:N - 1) * tau; // construction du vecteur temps
w = 6000*%pi/180;
//s2 = sin(w*t).*sin(w/3*t);
s2 = z(2,:);// prise en compte uniquement du canal 2, car le 1 n'est pas utilise dans mon appli
s2 = s2 -mean(s2); // recentrage du signal autour de l'axe abscice.
s2(abs(s2)<0.02)=0; // filtrage bourin pour supprimer les valeur faible
//s2=s2(1:9000)=0;
f=Fs*(0:(N)-1)/N;
[s2f zf] = filter(wft,1,s2); // filtrage du signal par le filtre passe bande

//densite spectrale 
s2_fft = fft(s2);
s2f_fft = fft(s2f);
conjuguee_s2 = conj(s2_fft);
conjuguee_s2f = conj(s2f_fft);

s2_densite = s2_fft.*conjuguee_s2;
s2f_densite = s2f_fft.*conjuguee_s2f;


s2f_densite_real = abs(real(s2f_densite));
n=50;
s2f_densite_real_moy = filter(ones(1,n),n,s2f_densite_real);
//
s2_fft_real = abs(real(s2_fft));
s2f_fft_real = abs(real(s2f_fft));

[m,n]=max(s2f_fft_real(2:$/2));
// Create a new figure
//fenetre = figure("layout", "gridbag", ...
//"toolbar", "none", ...
//"menubar", "none", ...
//"backgroundcolor", [1 1 1]);
//// Create the frames where each graph is put
//graph_frame = uicontrol(fenetre, "Position", [15 19 2400 1050], ...
//"Style", "frame", ...
//"Relief", "groove",...
//"BackgroundColor", [0.8 0.8 0.8]);
//c = createConstraints("gridbag", [1 1 1 1], [1 1], "both");
//top_left = uicontrol(fenetre, "style", "frame","constraints", c);
//c.grid = [2 1 1 1];
//top_right = uicontrol(fenetre, "style", "frame", "constraints", c);
//c.grid = [1 2 1 1];
//bottom_left = uicontrol(fenetre, "style", "frame", "constraints", c);
//c.grid = [2 2 1 1];
//bottom_right = uicontrol(fenetre, "style", "frame", "constraints", c);
//c.grid = [1 3 0.2 1];
//bottom_bottom_left = uicontrol(fenetre, "style", "frame", "constraints", c);
//
//a_tl = newaxes(top_left);a_tl.auto_clear = 'on';
//a_tr = newaxes(top_right);
//a_bl = newaxes(bottom_left);a_bl.auto_clear = 'on';
//a_br = newaxes(bottom_right);
//
//title(a_tr,"Signal Original");plot(a_tr,t,s2);
//title(a_br,"FFT Originale");plot(a_br,f(2:$/2),s2_fft_real(2:$/2));a_br.log_flags = 'lnn';
figure();title(fichier + ' signal');plot2d(t,s2);
figure();title(fichier + ' fft complète');plot2d('ln',f(2:$/2),s2_fft_real(2:$/2));plot2d('ln',fr*Fs,wfm);
figure();title(fichier + ' fft filtrée');plot2d('ln',f(2:$/2),s2f_fft_real(2:$/2));plot2d('ln',fr*Fs,wfm);
figure();title(fichier + ' densite complète');plot2d('ln',f(2:$/2),s2_densite(2:$/2));plot2d('ln',fr*Fs,wfm);
figure();title(fichier + ' densite filtrée');plot2d('ln',f(2:$/2),s2f_densite(2:$/2));plot2d('ln',fr*Fs,wfm);
figure();title(fichier + ' densite filtrée moyenne');plot2d('ln',f(2:$/2),s2f_densite_real_moy(2:$/2));plot2d('ln',fr*Fs,wfm);

//title(a_tl,"Signal Filtré");plot(a_tl,t,s2f);
//title(a_bl,"FFT Filtrée");plot(a_bl,f(2:$/2),s2f_fft(2:$/2));

//////////////////////////////////////////////////////////////////////
// Frame containing a slider
//function slider_update()
//    sl = get("demo_slider");
//    speedtext = get("speed_text");
//    txt = get("slider_text");
//    drawlater();
//    Freqmin = max(0,get(sl, "Value")-200);
//    FreqMax = min(get(sl, "Value")+200,22050);
//    set(txt, "String","Fenêtre de " + string(Freqmin)+ " à " + string(FreqMax)+ " Hz");
//    [wft,wfm,fr]=wfir('bp',48,[Freqmin/44100 FreqMax/44100],'hm',[-1 -1]);
//    [s2f zf] = filter(wft,1,s2);
//    s2f_fft_real = abs(real(fft(s2f)));
//    [m,n]=max(s2f_fft_real(2:$/2));
//    set(speedtext,"String","Vitesse Max : "+ string(f(n)/19.49) + " km/h à " + string(f(n)) + " Hz");
//    plot(a_bl,f(2:$/2),s2f_fft_real(2:$/2));
//    plot(a_tl,t,s2f);
//    //figure();plot2d('ln',f(2:$/2),s2f_fft(2:$/2));
//    drawnow();
//    a_bl.log_flags='ln';
//endfunction
//
//theslider = uicontrol(bottom_bottom_left, "Position", [0 100 300 25],...
//"Style", "slider",...
//"Min", 0,...
//"Max", 22050,...
//"Value", 11000,...
//"SliderStep", [20 100],...
//"Tag", "demo_slider",...
//"Callback", "slider_update();");
//
//slider_text = uicontrol(bottom_bottom_left, "Position", [0 80 300 25],...
//"Style", "text",...
//"String","Fenêtre Fréquentielle",...
//"FontSize", 11,...
//"FontWeight", "bold",...
//"BackgroundColor",[1 1 1],...
//"HorizontalAlignment", "center",...
//"Tag", "slider_text");
//
//speed_text = uicontrol(bottom_bottom_left, "Position", [0 40 300 25],...
//"Style", "text",...
//"String","Vitesse Max: ",...
//"FontSize", 11,...
//"FontWeight", "bold",...
//"BackgroundColor",[1 1 1],...
//"HorizontalAlignment", "center",...
//"Tag", "speed_text");
//// Update the text displayed
//slider_update();

/////////////////////////////////////////////////////////////////////////
// Tracking ball
////////////////////////////////////////////////////////////////////////
//
//n = aviopen('red-car-video.avi');
//im = avireadframe(n); //get a frame
//obj_win = camshift(im, [12, 6, 15, 13]); //initialize tracker
//
//while ~isempty(im),
//      obj_win = camshift(im); //camshift tracking          
//      obj_win
//      im = rectangle(im, obj_win, [0,255,0]);
//      imshow(im);
//
//      im = avireadframe(n);
//end;
//
//aviclose(n);
//
//n = aviopen('red-car-video.avi');
//im = avireadframe(n); //get a frame
//obj_win = meanshift(im, [220. 40. 15. 14]); //initialize tracker
//
//while ~isempty(im),
//      obj_win = meanshift(im); //meanshift tracking
//
//      im = rectangle(im, obj_win, [0,255,0]);
//      imshow(im);
//
//      im = avireadframe(n);
//end;
//
//aviclose(n);
//
function [s2f, s2f_fft, s2f_densite] = affiche_fft()
    fmin = 1000;
    fmax = 6000;
    
    fichier = uigetfile('*.wav');   
    [z,Fs,bits]=wavread(fichier);
    [wft,wfm,fr]=wfir('bp',10,[fmin/Fs fmax/Fs],'hm',[-1 -1]);
    N=size(z,'c'); //nombre d'échantillons
    tau = 1 / Fs;
    t = (0:N - 1) * tau;
    w = 6000*%pi/180;
    //s2 = sin(w*t).*sin(w/3*t);
    s2 = z(2,:); // prise en compte uniquement du canal 2, car le 1 n'est pas utilise dans mon appli
    s2 = s2 -mean(s2); // centrage sur l'axe des abscice
    figure();title(fichier + ' signal brut2');plot2d(t,s2);
    [ibutton,xcoord,ycoord,iwin,cbmenu]=xclick();
    s2(abs(s2)<ycoord)=0;//s2=s2(1:9000)=0;
    f=Fs*(0:(N)-1)/N;
    [s2f zf] = filter(wft,1,s2);

    //densite spectrale 
    s2_fft = fft(s2);
    s2f_fft = fft(s2f);
    conjuguee_s2 = conj(s2_fft);
    conjuguee_s2f = conj(s2f_fft);

    s2_densite = s2_fft.*conjuguee_s2;
    s2f_densite = s2f_fft.*conjuguee_s2f;

    s2_fft_real = abs(real(s2_fft));
    s2f_fft_real = abs(real(s2f_fft));

    // FFT Bourin
    fcmin = f < fmin;
    fcmax = f > fmax;

    s2_fft_real_b = s2_fft_real;
    s2_fft_real_b = s2_fft_real;
    s2_fft_real_b(fcmin) = 0;
    s2_fft_real_b(fcmax) = 0;

    s2f_densite_real = abs(real(s2f_densite));
    n = 50;
    s2f_densite_real_moy = filter(ones(1,n),n,s2f_densite_real);

    [m,n]=max(s2f_fft_real(2:$/2));

    figure();title(fichier + ' signal filtré');plot2d(t,s2f);
    figure();title(fichier + ' fft');plot2d('ln',f(2:$/2),s2f_fft_real(2:$/2));plot2d('ln',fr*Fs,wfm);
    figure();title(fichier + ' densite spectrale');plot2d('ln',f(2:$/2),s2f_densite(2:$/2));plot2d('ln',fr*Fs,wfm);
    figure();title(fichier + ' densite moyennées');plot2d('ln',f(2:$/2),s2f_densite_real_moy(2:$/2));plot2d('ln',fr*Fs,wfm);
    figure();title(fichier + ' densite bourin');plot2d('ln',f(2:$/2),s2_fft_real_b(2:$/2));plot2d('ln',fr*Fs,wfm);
endfunction


// Copyright (C) 2017 - Corporation - Author
//
// About your license if you have any
//
// Date of creation: 2 mars 2017
//

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%% fenetre de Hanning
function H=hanning(N)
    t=[1:N];
    H=0.5-0.5*cos(2*%pi*t/N);
endfunction

//%recouvrement avec des fenetres de 30ms toutes les 10 ms
function [T,X1,H1,k]=trames(signal,fs)
    H1 = [];
    H2=[];
    N=length(signal);
    Nf=0.03*fs;
    Nr=0.01*fs;
    H=hanning(Nf);
    b=modulo(N,Nf);
    signal=[signal; zeros(Nf-b,1)];
    N=N+Nf-b;
    H1=[H zeros(1,N-Nf)];
    k=1;
    while (N-(k*Nr+Nf)>0)
        k=k+1;
    end
    for n=1:k
        H2=[zeros(1,n*Nr) H zeros(1,N-(n*Nr+Nf))];
        H1=[H1;H2];
    end
    h1=H(1,Nf-Nr:Nf);
    h2=H(1,Nf-2*Nr:Nf);
    h3= H(Nf:-1:Nf-Nr);
    h4= H(Nf:-1:Nf-2*Nr);
    h1=[h1 zeros(1,N-length(h1))];
    h2=[h2 zeros(1,N-length(h2))];
    h3=[zeros(1,N-length(h3)) h3];
    h4=[zeros(1,N-length(h4)) h4];
    H1=[h1;h2;H1;h3;h4];
    u=size(H1);
    for i=1:u(1,1)
        T(i,:)=H1(i,:).*signal.';
    end
    X1=sum(T);
endfunction


//%recouvrement avec des fenetres de 30ms toutes les 10 ms
function [T,X1,H1,k]=splitSignal(s2,Fs)
    T=0;
    X1=0;
    H1=0;
    N=length(s2);
    Nf=0.03*Fs; // nb echantillons pour fenetre de 30ms
    Nr=0.01*Fs; // nb echantillons pour fenetre de 10ms
    //H=hanning(Nf);
    b=modulo(N,Nf);
    s2=[s2, zeros(Nf-b,1)'];
    //N=N+Nf-b;
    
    N=length(s2);
    tau = 1 / Fs;
    t = (0:N - 1) * tau;


    k=1;
    M=[];
    f_y = Fs*(0:(Nf)-1)/Nf;
    while (N-(k*Nr+Nf)>0)
        M = [M;abs(real(fft(s2((1:Nf)+ Nr*(k-1)))))];
        k=k+1; // calcul le nb echantillon de 10ms
    end
    f_y_save = f_y;
    M_save = M;
    t_x = (0:k - 2) * tau;
    
    // affichage en RPM
    figure();
    xset("colormap",hotcolormap(64));

    LimiteHaute = f_y > 500; // inférieur à 500Hz
    f_y(LimiteHaute) = [];
    M(:,LimiteHaute) = [];
    LimiteBasse = f_y < 80; // supérieur à 80Hz
    f_y(LimiteBasse) = [];
    M(:,LimiteBasse) = [];
    colorbar(min(M),max(M));
    Sgrayplot(t_x,f_y*9.55/(19.49*0.0215),M*9.55/(19.49*0.0215));
    
    // affichage de la vitesse des objets > 50km/h
    figure();
    xset("colormap",hotcolormap(64));
    f_y = f_y_save;
    M = M_save;
    LimiteHaute = f_y/19.49 > 300; // inférieur à 300 km/h
    f_y(LimiteHaute) = [];
    M(:,LimiteHaute) = [];
    LimiteBasse = f_y/19.49 < 50; // supérieur à 50 km/h
    f_y(LimiteBasse) = [];
    M(:,LimiteBasse) = [];
    colorbar(min(M)/19.49,max(M)/19.49);
    Sgrayplot(t_x,f_y/19.49,M/19.49);

//    for n=1:k
//        H2=[zeros(1,n*Nr) H zeros(1,N-(n*Nr+Nf))];
//        H1=[H1;H2];
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
//    for i=1:u(1,1)
//        T(i,:)=H1(i,:).*s2.;
//    end
//    X1=sum(T);
endfunction
