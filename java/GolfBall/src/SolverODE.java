public class SolverODE
{
	private int j;
	private int numEqns;
	private double q[]		= new double[numEqns];
	private double dq1[] 	= new double[numEqns];
	private double dq2[] 	= new double[numEqns];
	private double dq3[] 	= new double[numEqns];
	private double dq4[] 	= new double[numEqns];
	private double ds;
	private double sCurrent;
	private EquationODE eqn;
	private boolean zeroCrossing;

	// Constructor
	/**
	 * @author 
	 * {@literal} Description : constructeur du solver Runge Kutta
	 * @param (String pMarque, int pNbAlveoles, int pNbPieces, double pTemperature, GolfClub pGolfClub, double pdt, double pTimeMax, double pdt)
	 */
	public SolverODE(EquationODE pEqn, double ps, double pds, double[] pq) {
		/**
		 * @param double ps, double pds, double[] pq
		 * 
		 */
		eqn 		= pEqn;
		sCurrent 	= ps;					// temps intiale
		ds 			= pds;					// step temporel
		q 			= pq;					// parametres depedants
		numEqns 	= q.length ; 			// nombre d'equations
		zeroCrossing = false;
	}	


	public double getCurrentS() {
		return sCurrent;
	}
	public void setCurrentS(double s) {
		sCurrent = s;
	}
	public double getQ(int index ) {
		return q[index];
	}	
	public void setQ(double value, int index ) {
		q[index] = value;
	}	
	public double[] getAllQ() {
		return q;
	}	
	public void setAllQ(double[] allQ) {
		q = allQ;
	}	
	public boolean getZeroCrossing() {
		return zeroCrossing;
	}	
	public void resetZeroCrossing() {
		zeroCrossing = false;
	}	
	public EquationODE getEquationODE()
	{
		return eqn;
	}
	
	/**
	 *  Fourth-order Runge-Kutta ODE solver.
	 */
	public void rungeKutta4() {
		double dqnew[] = new double[numEqns];

		// dZ1 = v(tn, zn)*dt
		dq1 = eqn.getEvaluation(sCurrent		, q);
		for(j=0; j < numEqns; ++j) {
			dq1[j] = dq1[j]*ds;
		}

		// dZ2 = v(tn+0.5*dt , zn+0.5*dz1)*dt
		for(j=0; j < numEqns; ++j) {
			dqnew[j] = q[j] + 0.5*dq1[j];
		}
		dq2 = eqn.getEvaluation(sCurrent + 0.5 * ds, dqnew);
		for(j=0; j < numEqns; ++j) {
			dq2[j] = dq2[j]*ds;
		}

		// dZ3 = v(tn+0.5*dt , zn+0.5*dz2)*dt
		for(j=0; j < numEqns; ++j) {
			dqnew[j] = q[j] + 0.5*dq2[j];
		}		
		dq3 = eqn.getEvaluation(sCurrent + 0.5 * ds, dqnew);
		for(j=0; j < numEqns; ++j) {
			dq3[j] = dq3[j]*ds;
		}

		// dZ4 = v(tn+dt , zn+dz3)*dt
		for(j=0; j < numEqns; ++j) {
			dqnew[j] = q[j] + dq3[j];
		}	
		dq4 = eqn.getEvaluation(sCurrent + ds	, dqnew);
		for(j=0; j < numEqns; ++j) {
			dq4[j] = dq4[j]*ds;
		}	

		for(j=0; j < numEqns; ++j) {
			q[j] = q[j] + (dq1[j] + 2.0*dq2[j] + 2.0*dq3[j] + dq4[j])/6.0;
		}
		sCurrent = sCurrent + ds; 			// evolution du temps au step suivant
		return;
	}


	/**
	 * ZeroCrossing Solver using Runge Kutta.
	 * @param event
	 * @param precision
	 */
	public void zeroCrossing(EquationODE event, double precision) {
		double sCurrentOrg;						// temps intiale
		double dsOrg;							// step temporel
		double[] qOrg	= new double[numEqns];	// parametres depedants
		double[] qRes	= new double[numEqns];	// parametres depedants
		boolean iter	= true;

		// initialisation à la valeur avant calcul
		sCurrentOrg = sCurrent;
		dsOrg 		= ds;
		qOrg 		= (double[]) q.clone();

		rungeKutta4();
		// si les valeurs de qRes sont positives, on renvoie le q de rungeKutta en sortant
		// si l'une des valeurs de retour qRes est < (-precision) on reprend le pas precedent positif avec un calcul à ds/2.
		// si les valeurs de retour qRes sont comprises entre (-precision) < qRes < 0 on arrete car on a traverse le zero a la precision.
		iter 	= true;
		zeroCrossing = false;
		while (iter){ // iteration sur un pas plus petit / 2
			q = (double[]) qOrg.clone(); 			// on remet la valeur avant le pas si on itere. Si c'est la premiere iteration, alors les valeurs n'ont pas changees
			sCurrent = sCurrentOrg; 				// on remet la valeur avant le pas
			rungeKutta4();
			qRes 	= event.getEvaluation(sCurrent, q);
			iter 	= false; // pas defaut, il n'y a a pas besoin d'iterer.
			for (double i : qRes) 
				iter = ((i < -precision) || iter);	// si l'une des valeurs est qRes(i) < - precision on reprend le pas positif precedent avec ds/2 (on itere pour trouver le zerocrossing
			ds =ds/2.0;								// on diminue le pas de temps
		}
		ds = dsOrg;									// on reprend le pas de temps intiale
		zeroCrossing = true;
		for (double i : qRes) 
			zeroCrossing = (((-precision <= i) && (i <= 0)) && zeroCrossing); // si l'un des q n'est pas dans le range entre (-precision) < qRes < 0, pas de zero crossing
	} 
}