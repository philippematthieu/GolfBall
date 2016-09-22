/*
 * EquationODEEventFlight.h
 *
 *  Created on: 22 sept. 2016
 *      Author:
 */
#include "EquationODE.h"


#ifndef EQUATIONODEEVENTFLIGHT_H_
#define EQUATIONODEEVENTFLIGHT_H_

class EquationODEEventFlight  : public EquationODE {
public:
	EquationODEEventFlight();
	EquationODEEventFlight(double* pParametres);
	~EquationODEEventFlight();
	virtual double* getEvaluation(double s, double* q );

private :
	double* qRes;
};

#endif /* EQUATIONODEEVENTFLIGHT_H_ */
