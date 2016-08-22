/**
 * @author 
 * @version  1.0
 * @category A
 * @see other
 * @param N/A
 * @return
 * 
 */
public class Simu {
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		Club[] sac = new Club[13];
		Club club;
		//				   Type,  Poids , Loft , Ecoeff, CoeffBackSpin,	CoeffSpinLift, 	Cl1,  	pClubV0, pAlphaClubPath, 	pGamaFacePath,	pShafLeanImp
		sac[0]  = new Club("Dr",  0.300 , 11   , 0.738,  200.00 , 		1500.0 , 		0.64, 	170.6, 	 0.0,		 		0.0,			 6.0);
		sac[1]  = new Club("B5",  0.280 , 18   , 0.78 ,  281.64 , 		500.0 , 		0.65, 	151.6, 	 5.0,	 			-5.0,			-3.0);
		sac[2]  = new Club("H3",  0.250 , 18   , 0.80 ,  322.00 , 		500.0 , 		0.54, 	136.8, 	 0.0,	 			0.0,			-2.5);
		sac[3]  = new Club("F5",  0.200 , 23   , 0.85 ,  335.00 , 		420.0 , 		0.54, 	127.1, 	 0.0,	 			0.0,			-5.0);
		sac[4]  = new Club("F6",  0.200 , 26   , 0.83 ,  355.00 , 		420.0 , 		0.54, 	125.5, 	 0.0,	 			0.0,			-5.0);
		sac[5]  = new Club("F7",  0.200 , 30   , 0.83 ,  380.00 , 		420.0 , 		0.54, 	122.3, 	 0.0,	 			0.0,			-6.5);
		sac[6]  = new Club("F8",  0.200 , 34.5 , 0.83 ,  400.74 , 		420.0 , 		0.53, 	120.0, 	 0.0,	 			0.0,			-8.0);
		sac[7]  = new Club("F9",  0.200 , 39   , 0.83 ,  400.99 , 		308.0 , 		0.53, 	115.9, 	 0.0,	 			0.0,			-8.0);
		sac[8]  = new Club("PW",  0.200 , 44   , 0.78 ,  438.24 , 		280.0 , 		0.52,	112.7, 	 0.0,	 			0.0,			-12.0);
		sac[9]  = new Club("AW",  0.200 , 52   , 0.78 ,  470.09 , 		308.0 , 		0.52, 	112.7, 	 0.0,	 			0.0,			-17.0);
		sac[10] = new Club("SW",  0.200 , 54   , 0.83 ,  498.52 , 		308.0 , 		0.51,	104.6, 	 0.0,	 			0.0,			-15.0);
		sac[11] = new Club("LW",  0.200 , 60   , 0.40 ,  500.00 , 		308.0 , 		0.51, 	100.0, 	 0.0,	 			-3.0,			-12.0);
		sac[12] = new Club("Pt",  0.300 , 03   , 0.68 ,  550.24 , 		308.0 , 		0.00, 	10.00, 	 0.0,	 			0.0,			 1.0);

		if (args.length == 5) {
			for (Club j : sac)
				if (j.getType().equals(args[0])) {
					club = new Club(args[0],  j.getPoids(), 
							j.getLoft() , j.getEcoeff() , j.getCoeffBackSpin() , j.getCoeffSpinLift() , j.getCl1(), 
							Double.parseDouble(args[1]), Double.parseDouble(args[2]), Double.parseDouble(args[3]), Double.parseDouble(args[4]));
					break;
				}
		}
		else
		{
			System.out.println("Les param�tres sont  Club Type, Club Speed, AlphaClubPath,GamaFacePath, ShafLeanImp");
			System.out.println("Club Type =  Dr, B5, H3, F5, F6, F7, F8, F9, PW, AW, SW, LW, Pt");
			System.out.println("AlphaClubPath est l'angle du chemin de club en degr�. (+) signifie un pull, (-) signifie un push");
			System.out.println("GamaFacePath est l'angle de la t�te de club en degr�. (+) signifie une t�te de club ouverte (Slice), (-) signifie une t�te de club ferm�e (Hook)");
			System.out.println("Exemple Golf.jar Dr 170.6 0.0 0.0 6.0");
			club = sac[0];
		}
		/**
		 * Lancement de la fenetre de saisie de parametres
		 */
		new SaisieData(sac);
	}
}
// Type	v km/h		Loft	Ball Speed (km/h)	meter		Lie		Max Height	Vertical Launch	attack angle	ShaftLean	BackSpin rpm
// D	170,6		11		223,698816			201,168		59		22,86		14				3				6			2628
// B5	141,6		18		205,996032			169,164		59		23,7744		12,2			-1,8			-3			4501
// H3	136,8		18		197,949312			163,6776	59		22,86		12,7			-3				-2.5		4693
// 5	127,1		23		180,246528			147,2184	61		21,0312		14,8			-1,9			-5			5081
// 6	125,5		26		175,418496			138,9888	61,5	22,86		17,1			-2,3			-5			5943
// 7	122,3		30		167,371776			128,9304	62		23,7744		19				-2,3			-6			6699
// 8	119,1		34,5	160,9344			118,872		62,5	22,86		20,8			-3,1			-9			7494
// 9	115,9		39		149,668992			108,8136	63		23,7744		23,9			-3,1			-9,1		7589
// PW	112,7		44		138,403584			97,8408		63,5	21,0312		25,6			-2,8			-11,5		8403
// Gap	112,7		52		128,74752			91,44		63,5	18,288		27				-2,8			-17,5		9000
// SW	104,6		54		120,7008			73,152		63,5	17,3736		30				-3				19			9300
// LW	96,6		60		120					33,8328		63,5	20			30				-3,3			-20			5500
