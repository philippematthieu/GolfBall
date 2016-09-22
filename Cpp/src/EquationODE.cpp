/*
 * EquationODE.cpp
 *
 *  Created on: 21 sept. 2016
 *  Author:
 */

#include "EquationODE.h"
#include <string>
#include <iostream>
using namespace std;
EquationODE::EquationODE(){
	cout << "EquationODE(): "<< endl;
}

EquationODE::EquationODE(double* pParametres){
	cout << "EquationODE: "<< endl;
	parametres = pParametres;
	cout << "EquationODE: fin"<< endl;

}

void EquationODE::setParamEq(double value, int index) {
	parametres[index] = value;
}

double EquationODE::getParamEq(int index) {
	return parametres[index];
}

int EquationODE::getSizeParamEq() {
	return sizeof(*parametres)+1 ;
}

EquationODE::~EquationODE() {}

