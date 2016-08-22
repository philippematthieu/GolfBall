import java.util.Vector;


/**
 * @author f009770
 *
 * {@literal} Description : Class de definition des caracteristiques de la balle de golf
 * @param (String pMarque, int pNbAlveoles, int pNbPieces, double pTemperature, GolfClub pGolfClub, double pdt, double pTimeMax, double pdt)
 * 
 */
public class Ball {
	private String				marque; 			// marque de la balle de golf
	private double				masse; 				// masse de la ball de golf 
	private int					nbAlveoles;	 		// nombre d'alveole de la balle de golf
	private int					nbPieces; 			// nb de pieces de la bale de golf
	private double				area; 				// aire de la balle de golf
	private double				temperature;	 	// Temperature de l'aire en °C
	private double				rayon; 				// rayon de la balle de golf
	private double				rhoAir; 			// densite de l'aire
	private double				g; 					// acceleration terrestre en m/s2
	private double				rhoGreen;			// densite de green
	private double				launchAngle;		// angle de decollage de la balle en radian
	private double[]			v0Initms 	= new double[6]; // {x, vx, y, vy, z, vy } = q init
	private double[]			v0Currentms	= new double[6]; // {x, vx, y, vy, z, vy } = q courrant
	private double				v0BallInitms;		// Vitesse initiale de la balle 
	private int					numEqns 	= 6;	// nombre d'equations
	private double				timeMax;				// temps max de l'ODE
	private double				dt;					// pas de temps
	private SolverODE			solveFlight;
	private EquationODEFlight	eqnVolBalle;
	private SolverODE			solveRoll;
	private EquationODERoll		eqnRoulBalle;
	private EquationODEEventFlight 	event;
	private double				alphaClubPath;
	private double 				impactAngle = 0.0;
	private double[] 			paramEqn = new double[9];// wx, wy,wz, getRayon, getRhoAir, getBallArea, getCl1, getMasse, getG
	private Vector<double[]> 	matriceFlight = new Vector<double[]>(); // la dimension est faite par le .clone() plus loin
	private	int 				indexChute = 0;
	private double spinYOrgrpm, spinZOrgrpm;

	// Constructor
	public Ball(String pMarque, int pNbAlveoles, int pNbPieces, double pTemperature, Club pGolfClub, double pTimeMax, double pdt){
		/**
		 * @author f009770
		 * @param String pMarque, int pNbAlveoles, int pNbPieces, double pTemperature
		 */
		marque 			= pMarque;
		nbAlveoles 		= pNbAlveoles;
		nbPieces 		= pNbPieces;
		temperature 	= pTemperature; 					// en °C
		masse 			= 0.04545; 							// en kg
		rayon			= 0.0215; 							// en m
		area 			= Math.PI*rayon*rayon;				// air de la section en m^2
		rhoAir		 	= 1.292*273.15/(pTemperature + 273); // en kg/m^3
		rhoGreen	 	= 0.131; 							// en kg/m^3
		g 				= 9.81; 							// m/s^2
		timeMax 		= pTimeMax;
		dt 				= pdt;
		alphaClubPath	= pGolfClub.getAlphaClubPath();

		double v0Ballbfnms =  pGolfClub.getClubV0ms() * Math.cos(pGolfClub.getDynamiqueLoft())*(1.0 + pGolfClub.getEcoeff())/(1+masse/pGolfClub.getPoids()) ;// Vitesse longitudinale dans le referentiel de decollage après impact (ref: The physics of golf: The optimum loft of a driverA. Raymond Penner)
		double v0Ballbfpms = -pGolfClub.getClubV0ms() * Math.sin(pGolfClub.getDynamiqueLoft())/(1.0 + masse/pGolfClub.getPoids() + 2.5);     // Vitesse perpendiculaire dans le referentiel de decollage après impact

		// Calcul de l'angle de decollage de la balle
		launchAngle		= pGolfClub.getDynamiqueLoft() + Math.atan(v0Ballbfpms/v0Ballbfnms);    // angle de decollage de la balle

		// Calcul de la vitesse initiale de la balle
		v0BallInitms	= Math.sqrt(v0Ballbfnms*v0Ballbfnms + v0Ballbfpms*v0Ballbfpms)* (1.0 - 0.3556 * pGolfClub.getMiss()); // Vitesse de decollage de la balle
		v0Initms[1] 	=  v0BallInitms * Math.cos(launchAngle) * Math.cos(0.0);     // Vx
		v0Initms[3] 	= -v0BallInitms * Math.cos(launchAngle) * Math.sin(0.0);     // Vy 
		v0Initms[5] 	=  v0BallInitms * Math.sin(launchAngle);                   // Vz

		// initialisation de la position
		v0Initms[0] = 0.0;	// X = §Vx.dt
		v0Initms[2] = 0.0;	// Y = §Vy.dt 
		v0Initms[4] = 0.0;	// Z = §Vz.dt
		v0Currentms = (double[]) v0Initms.clone(); // copie des valeurs initiales v0Initms

		// Calcul des SPINs qui sont des paramètre de l'ODE
		paramEqn[0] = 0; 																									// wx Le SPIN sur l'axe X n'est pas une composante dans l'axe du chemin de club. Le spin est appliqué sur le plan du sol
		paramEqn[1] = v0Initms[1] * Math.sin(pGolfClub.getDynamiqueLoft())    * pGolfClub.getCoeffBackSpin() / 9.54929659643;	// wy Spin dans l'axe largeur backspin
		paramEqn[2] = v0Initms[5] * Math.sin(pGolfClub.getGamaFacePath()) * pGolfClub.getCoeffSpinLift() / 9.54929659643;	// wz Spin dans l'axe hauteur lift
		spinYOrgrpm = paramEqn[1]*9.54929659643; // sauvegarde des Spin d'origine
		spinZOrgrpm = paramEqn[2]*9.54929659643;

		paramEqn[3] = this.getRayon();
		paramEqn[4] = this.getRhoAir();
		paramEqn[5] = this.getBallArea();
		paramEqn[6] = pGolfClub.getCl1();
		paramEqn[7] = this.getMasse();
		paramEqn[8] = this.getG();

		// declaration des instances pour le vol de la balle
		eqnVolBalle	= new EquationODEFlight(paramEqn);
		event		= new EquationODEEventFlight(paramEqn);
		solveFlight = new SolverODE(eqnVolBalle, 0.0, this.getdt(), v0Initms);

		// declaration des instances de roullage de la balle
		eqnRoulBalle= new EquationODERoll(paramEqn);
		solveRoll 	= new SolverODE(eqnRoulBalle, 0.0, this.getdt(), v0Initms);
	}
	// methodes pour constantes et variables du systeme
	public int getNumEqns() {
		return numEqns;
	}	
	public String getMarque() {
		return marque;
	}	
	public int getNbAlveoles() {
		return nbAlveoles;
	}	
	public int getNbPieces() {
		return nbPieces;
	}	
	public double getTemperature() {
		return temperature;
	}	
	public double getMasse() {
		return masse;
	}	
	public double getBallArea() {
		return area;
	}	
	public double getRhoAir() {
		return rhoAir;
	}	
	public double getRhoG() {
		return rhoGreen;
	}	
	public double getRayon() {
		return rayon;
	}	
	public double getG() {
		return g;
	}	
	public double getV0BallInitms() {
		return v0BallInitms;
	}	
	public double getLaunchAngle() {
		return launchAngle;
	}	
	public double getImpactAngle() {
		return impactAngle;
	}	
	public double[] getV0Initms() {
		return v0Initms;
	}	
	//methodes pour vitesses Vx, Vy, Vz
	public double[] getVCurrentms() {
		return v0Currentms;
	}	
	public void setVCurrentms(double valeur ,int index ) {
		v0Currentms[index] = valeur;
		return;
	}	
	public void setVx(double vx) {
		v0Currentms[1] = vx;
		return;
	}	
	public double getVx() {
		return v0Currentms[1];
	}	
	public void setVy(double vy) {
		v0Currentms[3] = vy;
		return;
	}	
	public double getVy() {
		return v0Currentms[3];
	}	
	public void setVz(double vz) {
		v0Currentms[5] = vz;
		return;
	}	
	public double getVz() {
		return v0Currentms[5];
	}	
	// methodes pour position x, y ,z
	public void setX(double x) {
		v0Currentms[0] = x;
		return;
	}	
	public double getX() {
		return v0Currentms[0];
	}	
	public void setY(double y) {
		v0Currentms[2] = y;
		return;
	}	
	public double getY() {
		return v0Currentms[2];
	}	
	public void setZ(double z) {
		v0Currentms[4] = z;
		return;
	}
	public double getZ() {
		return v0Currentms[4];
	}	
	// methodes pour SPIN
	public double getSpinX() {
		return paramEqn[0];
	}	
	public void setSpinX(double wx) {
		paramEqn[0] = wx;
		return;
	}	
	public double getSpinY() {
		return paramEqn[1];
	}	
	public double getSpinYOrgrpm() {
		return spinYOrgrpm;
	}	
	public void setSpinY(double wy) {
		paramEqn[1] = wy;
		return;
	}	
	public double getSpinZ() {
		return paramEqn[2];
	}	
	public double getSpinZOrgrpm() {
		return spinZOrgrpm;
	}	
	public void setSpinZ(double wz) {
		paramEqn[2] = wz;
		return;
	}
	// gestion du temps
	public double getTimeMax() {
		return timeMax;
	}	
	public double getdt() {
		return dt;
	}	
	public double getIndexChute() {
		return indexChute-1;
	}	
	public Vector<double[]> getMatriceFlight()
	{
		return matriceFlight;
	}
	/**
	 * Debut de runSimu()
	 * author 
	 **/
	public void runSimu() {
		Vector<double[]> matrice = new Vector<double[]>(); // la dimension est faite par le .clone() plus loin

		double vi, thetaRebond, vixprime, vrxprime, vizprime, vrzprime, eBall, muFrictionCritic, wr, vr, vrx, vry, vrz; 
		final  double muFriction = 0.40;

		for (int i = 0;i < 3;i++) {
			/**
			 * Calcul de Runge ZeroCrossingODE
			 */
			while ( (solveFlight.getCurrentS() < this.getTimeMax()) && (! solveFlight.getZeroCrossing()) )  {
				solveFlight.zeroCrossing(event, 1e-2); // si pas de zero crossing une iteration, sinon, event est true
				matrice.add(solveFlight.getAllQ().clone());
			}
			solveFlight.resetZeroCrossing(); // reset du zero crossing pour les boucles suivantes.
			// sortie de la boucle while
			/**
			 *  calcul du vecteur vitesse et spin après rebond 
			 *  @param : double muFriction = 0.40;
			 *  @param : longueur Vx = getQ(1), lageur Vy = getQ(3), hauteur Vz = getQ(5),
			 *  @pram : rayon, getSpinY()
			 */
			vi			= Math.sqrt(solveFlight.getQ(1)*solveFlight.getQ(1)+solveFlight.getQ(3)*solveFlight.getQ(3)); // calcul de la nouvelle norme de la vitesse de la balle dans le plan vertical de lancement ==> Vy = 0 car on considere que la balle après rebond continue dans l'axe X (pour le moment)
			impactAngle = Math.atan(Math.abs(vi/solveFlight.getQ(5)));
			thetaRebond = 0.2687807 * Math.sqrt(vi*vi+solveFlight.getQ(5)*solveFlight.getQ(5))/18.6*(impactAngle/0.7749262 ); // en m/s et degre 
			vixprime 	= vi * Math.cos(thetaRebond) - Math.abs(solveFlight.getQ(5)) * Math.sin(thetaRebond);
			vizprime 	= vi * Math.sin(thetaRebond) + Math.abs(solveFlight.getQ(5)) * Math.cos(thetaRebond); 
			if (Math.abs(vizprime) < 20.0) {
				eBall 	= 0.510 - 0.0375 * Math.abs(vizprime) + 0.000903 * Math.abs(vizprime*vizprime);
			}
			else {
				eBall 	= 0.120;
			}
			muFrictionCritic = 2.0 * (vixprime + rayon * this.getSpinY()) / (7.0*(1+eBall) * Math.abs(vizprime));

			if (muFriction < muFrictionCritic) {
				vrxprime 	= vixprime - muFriction * Math.abs(vizprime) *(1.0 + eBall);
				vrzprime 	= eBall * Math.abs(vizprime);
				wr 			= this.getSpinY() - (5.0 * muFriction * 2.0 * rayon) * Math.abs(vizprime) * (1.0 + eBall); // nouveau spinY
			}
			else {
				vrxprime 	= 5.0/7.0*vixprime - 2.0/7.0*rayon*this.getSpinY();
				vrzprime 	= eBall * Math.abs(vizprime);
				wr 			= -vrxprime / rayon; 											// nouveau spinY
			}
			vr 		= vrxprime * Math.cos(thetaRebond) - vrzprime * Math.sin(thetaRebond); 	// nouvelle norme de la vitesse de la balle
			vrz 	= vrxprime * Math.sin(thetaRebond) + vrzprime * Math.cos(thetaRebond); 	// Hauteur
			vrx 	= vr / vi * solveFlight.getQ(1);										// longueur
			vry		= vr / vi * solveFlight.getQ(3);										// largeur
			/** 
			 * fin calcul du vecteur vitesse et spin apres rebond
			 */
			/**
			 *  mise a jour des nouvelles donnees apres rebond pour la resolution suivante.
			 */
			solveFlight.setQ(vrx, 1); 						// positionne les nouvelles valeurs à dt+1
			solveFlight.setQ(vry, 3);
			solveFlight.setQ(vrz, 5);
			solveFlight.setQ(0, 4);							// La nouvelle position de la hauteur est 0
			// mise a jour du spin
			solveFlight.getEquationODE().setParamEq(0,0);	// wx et le this.SpinX
			solveFlight.getEquationODE().setParamEq(wr,1);	// wy et le this.SpinY
			solveFlight.getEquationODE().setParamEq(0,2);	// wz et le this.SpinZ
			// enregistrement du point de chutte
			if (i == 0) 
				indexChute = matrice.size();
		} // fin de la boucle for 3 rebonds

		/**
		 *  Resolution du roullage avec nouvelle equation
		 *  @param : longueur Vx = getQ(1), lageur Vy = getQ(3), hauteur Vz = getQ(5),
		 */
		eqnRoulBalle.setParamEq(this.getRhoG(), 4);	// positionne le paramètre de densite de green.

		solveRoll.setQ(solveFlight.getQ(0), 0); 	// initialisation des positions vitesse au sol pour le roulage 
		solveRoll.setQ(solveFlight.getQ(1), 1);
		solveRoll.setQ(solveFlight.getQ(2), 2);
		solveRoll.setQ(solveFlight.getQ(3), 3);
		solveRoll.setQ(0, 4);
		solveRoll.setQ(0, 5);
		/**
		 * Calcul de Runge Kutta
		 */
		while ((solveRoll.getCurrentS() < this.getTimeMax()) && (solveRoll.getQ(1) > 0.01)) {
			solveRoll.rungeKutta4();
			// mise à jour des donnees courrantes
			matrice.add(solveRoll.getAllQ().clone());
		}
		/**
		 * fin du roullage
		 */
		for (double[] j : matrice) {
			// mise à jour des donnees courrantes et rotation vers nouveau referentiel prenant en compte la direction initiale du club
			this.setX( j[0]  * Math.cos(alphaClubPath) + j[2] * Math.sin(alphaClubPath));
			this.setVx(j[1]  * Math.cos(alphaClubPath) + j[3] * Math.sin(alphaClubPath));
			this.setY(-j[0]  * Math.sin(alphaClubPath) + j[2] * Math.cos(alphaClubPath));
			this.setVy(-j[1] * Math.sin(alphaClubPath) + j[3] * Math.cos(alphaClubPath));
			this.setZ( j[4]);
			this.setVz(j[5]);				
			matriceFlight.add(this.getVCurrentms().clone());
		}
		return;
	}
	/**
	 * Fin de runSimu()
	 *  
	 **/
} 
/**
 *  Fin de class GolfBall
 */
