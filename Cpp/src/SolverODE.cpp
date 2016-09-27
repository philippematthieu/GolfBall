/*
 * SolverODE.cpp
 *
 *  Created on: 27 sept. 2016
 *      Author:
 */

#include "SolverODE.h"
#include "EquationODE.h"

SolverODE::SolverODE() {
}
SolverODE::SolverODE(EquationODE *pEqn, double ps, double pds, std::vector<double> pq):  sCurrent(ps), ds(pds), q(pq) ,numEqns(pq.size()), bzeroCrossing(false) {
	eqn = pEqn;
}

SolverODE::~SolverODE() {
}

// Constructor
/**
 * @author
 * {@literal} Description : constructeur du solver Runge Kutta
 * @param (String pMarque, int pNbAlveoles, int pNbPieces, double pTemperature, GolfClub pGolfClub, double pdt, double pTimeMax, double pdt)
 */
double SolverODE::getCurrentS() {
	return sCurrent;
}
void SolverODE::setCurrentS(double s) {
	sCurrent = s;
}
double SolverODE::getQ(int index ) {
	return q[index];
}
void SolverODE::setQ(double value, int index ) {
	q[index] = value;
}
std::vector<double> SolverODE::getAllQ() {
	return q;
}
void SolverODE::setAllQ(std::vector<double> allQ) {
	q = allQ;
}
bool SolverODE::getZeroCrossing() {
	return bzeroCrossing;
}
void SolverODE::resetZeroCrossing() {
	bzeroCrossing = false;
}


/**
 *  Fourth-order Runge-Kutta ODE solver.
 */
void SolverODE::rungeKutta4() {
	std::vector<double> dqnew(numEqns);
	int j;

	// dZ1 = v(tn, zn)*dt
	dq1 = eqn->getEvaluation(getCurrentS()		, q);
	for(j=0; j < numEqns; ++j) {
		dq1[j] = dq1[j]*ds;
	}

	// dZ2 = v(tn+0.5*dt , zn+0.5*dz1)*dt
	for(j=0; j < numEqns; ++j) {
		dqnew[j] = q[j] + 0.5*dq1[j];
	}
	dq2 = eqn->getEvaluation(getCurrentS() + 0.5 * ds, dqnew);
	for(j=0; j < numEqns; ++j) {
		dq2[j] = dq2[j]*ds;
	}

	// dZ3 = v(tn+0.5*dt , zn+0.5*dz2)*dt
	for(j=0; j < numEqns; ++j) {
		dqnew[j] = q[j] + 0.5*dq2[j];
	}
	dq3 = eqn->getEvaluation(getCurrentS() + 0.5 * ds, dqnew);
	for(j=0; j < numEqns; ++j) {
		dq3[j] = dq3[j]*ds;
	}

	// dZ4 = v(tn+dt , zn+dz3)*dt
	for(j=0; j < numEqns; ++j) {
		dqnew[j] = q[j] + dq3[j];
	}
	dq4 = eqn->getEvaluation(getCurrentS() + ds	, dqnew);
	for(j=0; j < numEqns; ++j) {
		dq4[j] = dq4[j]*ds;
	}

	for(j=0; j < numEqns; ++j) {
		q[j] = q[j] + (dq1[j] + 2.0*dq2[j] + 2.0*dq3[j] + dq4[j])/6.0;
	}
	setCurrentS(getCurrentS() + ds); 			// evolution du temps au step suivant
	return;
}


/**
 * ZeroCrossing Solver using Runge Kutta.
 * @param event
 * @param precision
 */
void SolverODE::zeroCrossing(EquationODE *event, double precision) {
	double 				sCurrentOrg;						// temps intiale
	double 				dsOrg;							// step temporel
	std::vector<double> qOrg(numEqns);	// parametres depedants
	std::vector<double> qRes(numEqns);	// parametres depedants
	bool iter	= 		true;

	// initialisation a la valeur avant calcul
	sCurrentOrg = 		getCurrentS();
	dsOrg 		= 		ds;
	qOrg 		= 		getAllQ();

	rungeKutta4();
	// si les valeurs de qRes sont positives, on renvoie le q de rungeKutta en sortant
	// si l'une des valeurs de retour qRes est < (-precision) on reprend le pas precedent positif avec un calcul � ds/2.
	// si les valeurs de retour qRes sont comprises entre (-precision) < qRes < 0 on arrete car on a traverse le zero a la precision.
	iter 			= true;
	bzeroCrossing 	= false;
	while (iter){ // iteration sur un pas plus petit / 2
		setAllQ(qOrg); 			// on remet la valeur avant le pas si on itere. Si c'est la premiere iteration, alors les valeurs n'ont pas changees
		setCurrentS(sCurrentOrg); 				// on remet la valeur avant le pas
		rungeKutta4();
		qRes 	= event->getEvaluation(getCurrentS(), getAllQ());
		iter 	= false; // pas defaut, il n'y a a pas besoin d'iterer.
		for (int i=0; i < qRes.size(); i++)
			iter = ((qRes[i] < precision) || iter);	// si l'une des valeurs est qRes(i) < - precision on reprend le pas positif precedent avec ds/2 (on itere pour trouver le zerocrossing
		ds =ds/2.0;								// on diminue le pas de temps
	}
	ds = dsOrg;									// on reprend le pas de temps intiale
	bzeroCrossing = true;
	for (int i=0; i < qRes.size(); i++)
		bzeroCrossing = (((precision <= qRes[i]) && (qRes[i] <= 0)) && bzeroCrossing); // si l'un des q n'est pas dans le range entre (-precision) < qRes < 0, pas de zero crossing
}
