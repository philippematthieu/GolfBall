import java.awt.event.ActionEvent;
import java.util.Vector;
import javax.swing.AbstractAction;
import javax.swing.JFrame;

import org.jfree.ui.RefineryUtilities;

public class RunAction extends AbstractAction  {
	/**
	 * 
	 */
	private static final long serialVersionUID = 2L;
	private SaisieData fenetre;

	public RunAction(SaisieData saisieData, String texte){
		super(texte);
		this.fenetre = saisieData;
	}

	public SaisieData getFenetre() {
		return this.fenetre;
	}

	public void actionPerformed(ActionEvent e) {
		/**
		 * Nouvelle balle lancee
		 * qui calcul les parametre de vol
		 */
		Ball theBall = new Ball("Décathlon 520 Soft", 350, 2, 20.0, this.fenetre.getClub(), 18.0, 0.01);
		/**
		 * Lancement de la simulation de vol
		 */		
		theBall.runSimu();
		//Vector<double[]> matriceFlight = this.fenetre.getTheBall().getMatriceFlight();
		Vector<double[]> matriceFlight = theBall.getMatriceFlight();

		/**
		 * affichage des données graphiques sous forme de boutons
		 * par GraphXYSeries, ou le pLegend contient l'ensemble des données affiches dasn les boutons
		 */
		GraphXYSeries graphLongHaut = new GraphXYSeries("Ball Flight","Longueur", "Hauteur",String.format(
				String.format("<HTML><CENTER><b>Club : </b>" + this.fenetre.getClub().getType() + "</CENTER></HTML>|")
				+String.format("<HTML><CENTER><b>ECoeff</b><BR> %4.2f</CENTER></HTML>|",this.fenetre.getClub().getEcoeff())
				+String.format("<HTML><CENTER><b>VClub</b><BR> %4.2f</CENTER></HTML>|",this.fenetre.getClub().getClubV0ms()*3.6)
				+String.format("<HTML><CENTER><b>ClubPath</b><BR> %4.2f</CENTER></HTML>|",this.fenetre.getClub().getAlphaClubPath()*180/Math.PI)
				+String.format("<HTML><CENTER><b>ClubAngle</b><BR> %4.2f</CENTER></HTML>|",this.fenetre.getClub().getGamaFacePath()*180/Math.PI)
				+String.format("<HTML><CENTER><b>Loft</b><BR> %4.2f</CENTER></HTML>|",this.fenetre.getClub().getLoft())
				+String.format("<HTML><CENTER><b>ShaftLean</b><BR> %4.2f</CENTER></HTML>|",this.fenetre.getClub().getShaftLeanImp())
				+String.format("<HTML><CENTER><b>DynamiqueLoft</b><BR> %4.2f</CENTER></HTML>|",this.fenetre.getClub().getDynamiqueLoftDegre())
				+String.format("<HTML><CENTER><b>VBall</b><BR> %4.2f</CENTER></HTML>|",theBall.getV0BallInitms()*3.6)
				+String.format("<HTML><CENTER><b>BackSpin</b><BR> %4.0f</CENTER></HTML>|",theBall.getSpinYOrgrpm())
				+String.format("<HTML><CENTER><b>LiftSpin</b><BR> %4.0f</CENTER></HTML>|",theBall.getSpinZOrgrpm())
				+String.format("<HTML><CENTER><b>launchAngle</b><BR> %4.2f</CENTER></HTML>|",theBall.getLaunchAngle()*180/Math.PI)
				+String.format("<HTML><CENTER><b>XChute</b><BR> %4.2f</CENTER></HTML>|",matriceFlight.get((int) theBall.getIndexChute())[0]* Math.cos(this.fenetre.getClub().getAlphaClubPath()) + matriceFlight.get((int) theBall.getIndexChute())[2]* Math.sin(this.fenetre.getClub().getAlphaClubPath()))
				+String.format("<HTML><CENTER><b>YChute</b><BR> %4.2f</CENTER></HTML>|",-matriceFlight.get((int) theBall.getIndexChute())[0]* Math.sin(this.fenetre.getClub().getAlphaClubPath()) + matriceFlight.get((int) theBall.getIndexChute())[2]* Math.cos(this.fenetre.getClub().getAlphaClubPath()))
				+String.format("<HTML><CENTER><b>XTotal</b><BR> %4.2f</CENTER></HTML>|",matriceFlight.get(matriceFlight.size()-1)[0]* Math.cos(this.fenetre.getClub().getAlphaClubPath()) + matriceFlight.get(matriceFlight.size()-1)[2]* Math.sin(this.fenetre.getClub().getAlphaClubPath()))
				+String.format("<HTML><CENTER><b>YTotal</b><BR> %4.2f</CENTER></HTML>|",-matriceFlight.get(matriceFlight.size()-1)[0]* Math.sin(this.fenetre.getClub().getAlphaClubPath()) + matriceFlight.get(matriceFlight.size()-1)[2]* Math.cos(this.fenetre.getClub().getAlphaClubPath()))
				+String.format("<HTML><CENTER><b>impactAngle</b><BR> %4.2f</CENTER></HTML>",theBall.getImpactAngle()*180/Math.PI)));
		graphLongHaut.pack();
		graphLongHaut.getContentPane();
		RefineryUtilities.centerFrameOnScreen(graphLongHaut);
		/**
		 * mise à jour des donnees courrantes et rotation vers nouveau referentiel prenant en compte la direction initiale du club
		 */
		//matrice.add(this.getVCurrentms().clone());
		//matriceFlight.add(this.getVCurrentms().clone());

		for (double[] j : matriceFlight) {
			// mise à jour des donnees courrantes et rotation vers nouveau referentiel prenant en compte la direction initiale du club
			System.out.println((float)j[0]+" ; "+(float)j[1]+" ; "+(float)j[2]+" ; "+(float)j[3]+" ; "+(float)j[4]+" ; "+(float)j[5]);
			graphLongHaut.addSeries((float)j[0], (float)j[4]);	// Ajoute les nouvelles coordonees
			graphLongHaut.addSeries2((float)j[0], (float)j[2]);	// Ajoute les nouvelles coordonees
		}
		/**
		 *  affichage graphique de Matrice.
		 */
		graphLongHaut.setVisible(true);
	}
} 

