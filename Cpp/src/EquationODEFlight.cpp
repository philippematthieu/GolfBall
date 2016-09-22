/*
 * EquationODEFlight.cpp
 *
 *  Created on: 21 sept. 2016
 *      Author:
 */

#include "EquationODEFlight.h"

EquationODEFlight::EquationODEFlight(){
}

EquationODEFlight::EquationODEFlight(double* pParametres){
	//EquationODE::EquationODE();
	parametres = pParametres;
}

double* EquationODEFlight::getEvaluation(double s, double* q ) {
	return q;
}

