/*
 * EquationODEEventFlight.cpp
 *
 *  Created on: 21 sept. 2016
 *      Author:
 */

#include "EquationODEEventFlight.h"
#include <string>
#include <vector>
#include <iostream>
using namespace std;

EquationODEEventFlight::EquationODEEventFlight(){
}

EquationODEEventFlight::EquationODEEventFlight(std::vector<double> pParametres): qRes(6,0){
}

EquationODEEventFlight::~EquationODEEventFlight() {
	//delete qRes; plus besoin de delete sur vector
}

std::vector<double>  EquationODEEventFlight::getEvaluation(double s, std::vector<double>  q) {
	qRes[0] = 0.0;
	qRes[1] = 0.0;
	qRes[2] = 0.0;
	qRes[3] = 0.0;
	qRes[4] = q[4]; // je cherche si Z passe sous zero
	qRes[5] = 0.0;
	return qRes;
}


