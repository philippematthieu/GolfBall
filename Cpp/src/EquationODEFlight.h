/*
 * EquationODEFlight.h
 *
 *  Created on: 21 sept. 2016
 *  Author:
 */

#include "EquationODE.h"

#ifndef EQUATIONODEFLIGHT_H_
#define EQUATIONODEFLIGHT_H_

class EquationODEFlight  : public EquationODE {
public:
	EquationODEFlight();
	EquationODEFlight(double* pParametres);
	virtual double* getEvaluation(double s, double* q );
};

#endif /* EQUATIONODEFLIGHT_H_ */
