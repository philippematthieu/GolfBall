/*
 * EquationODEEventFlight.cpp
 *
 *  Created on: 21 sept. 2016
 *      Author:
 */

#include "EquationODEEventFlight.h"
#include <string>
#include <iostream>
using namespace std;

EquationODEEventFlight::EquationODEEventFlight(){
	cout << "EquationODEEventFlight2.3: "<< endl;

}

EquationODEEventFlight::EquationODEEventFlight(double* pParametres){
	//EquationODE::EquationODE();
	qRes = new double[6];

	cout << "debut EquationODEEventFlight: "<< endl;
	cout << "EquationODEEventFlight fin: "<< endl;
}

EquationODEEventFlight::~EquationODEEventFlight() {
	cout << "~EquationODEEventFlight fin: "<< endl;
	delete qRes;
}

double* EquationODEEventFlight::getEvaluation(double s, double* q ) {

	qRes[0] = 0.0;
	qRes[1] = 0.0;
	qRes[2] = 0.0;
	qRes[3] = 0.0;
	qRes[4] = q[4]; // je cherche si Z passe sous zero
	qRes[5] = 0.0;
	return qRes;
}


