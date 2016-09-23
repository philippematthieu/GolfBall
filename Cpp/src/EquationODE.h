/*
 * EquationODE.h
 *
 *  Created on: 21 sept. 2016
 *  Author:
 */

#ifndef EQUATIONODE_H_
#define EQUATIONODE_H_

class EquationODE {
public:
	EquationODE();
	EquationODE(double* pParametres);

	virtual double* getEvaluation(double s, double q[] ) = 0;

	void setParamEq(double value, int index);
	double getParamEq(int index);
	int getSizeParamEq();
	virtual ~EquationODE();

protected:
	double* parametres;
};

#endif /* EQUATIONODE_H_ */
/**
 *
 * @author
 *
 */
