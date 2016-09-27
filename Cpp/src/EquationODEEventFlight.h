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
	EquationODEEventFlight(std::vector<double> pParametres);
	~EquationODEEventFlight();
	std::vector<double>  getEvaluation(double s, std::vector<double> q ) ;

private :	
	std::vector<double>  qRes;
};

#endif /* EQUATIONODEEVENTFLIGHT_H_ */

