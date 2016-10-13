import java.awt.event.ActionEvent;
import java.util.Vector;
import javax.swing.AbstractAction;


public class RunAction extends AbstractAction  {
	/**
	 * Runs the ball's simulator and launch the graphic result window.
	 * @author Matthieu PHILIPPE
	 * @version  1.0
	 * @category A
	 * @see 
	 * @param 
	 * @return N/A	 
	 */
	private static final long serialVersionUID = 2L;
	private SaisieData fenetre;
	private	GraphXYSeries graphLongHaut = null;

	public RunAction(SaisieData saisieData, String texte){
		super(texte);
		this.fenetre = saisieData;
	}
	public SaisieData getFenetre() {
		return this.fenetre;
	}
	public void actionPerformed(ActionEvent e) {
		Vector<double[]> matriceFlight;
		/**
		 * Nouvelle balle lancee
		 */
		Ball theBall = new Ball("Décathlon 520 Soft", 350, 2, this.fenetre.getClub(), 18.0, 0.01);

		/**
		 * Lancement de la simulation du vol
		 */		
		theBall.runSimu();

		/**
		 * Recuperation des donnees x, y z du vol
		 */
		matriceFlight = theBall.getMatriceFlight(); // recuperation des donnees x, y z du vol

		/**
		 * affichage des données dans les graphiques
		 */
		if (this.fenetre.getPlotInSameFrame()){
			try {
				graphLongHaut.addLinePlot3d("Ball Flight", matriceFlight) ;
				graphLongHaut.addLinePlot2d("", matriceFlight);
			}
			finally {	
			}
		}
		else {
			graphLongHaut = new GraphXYSeries("Ball Flight","Longueur", "Hauteur",matriceFlight, String.format(
					String.format("<HTML><CENTER><b>Club : </b>" + this.fenetre.getClub().getType() + "</CENTER></HTML>|")
					+String.format("<HTML><CENTER><b>Masse : </b>" + this.fenetre.getClub().getPoids() + "kg</CENTER></HTML>|")
					+String.format("<HTML><CENTER><b>VClub</b><BR> %4.2f km/h</CENTER></HTML>|",this.fenetre.getClub().getClubV0ms()*3.6)
					+String.format("<HTML><CENTER><b>ClubPath</b><BR> %4.2f°</CENTER></HTML>|",this.fenetre.getClub().getAlphaClubPathRadian()*180/Math.PI)
					+String.format("<HTML><CENTER><b>Loft</b><BR> %4.2f°</CENTER></HTML>|",this.fenetre.getClub().getLoft())
					+String.format("<HTML><CENTER><b>VBall</b><BR> %4.2f km/h</CENTER></HTML>|",theBall.getV0BallInitms()*3.6)
					+String.format("<HTML><CENTER><b>ClubAngle</b><BR> %4.2f°</CENTER></HTML>|",this.fenetre.getClub().getGamaFacePathRadian()*180/Math.PI)
					+String.format("<HTML><CENTER><b>ShaftLean</b><BR> %4.2f°</CENTER></HTML>|",this.fenetre.getClub().getShaftLeanImp())
					+String.format("<HTML><CENTER><b>BackSpin</b><BR> %4.0f rpm</CENTER></HTML>|",theBall.getSpinYOrgrpm())
					+String.format("<HTML><CENTER><b>launchAngle</b><BR> %4.2f°</CENTER></HTML>|",theBall.getLaunchAngle()*180/Math.PI)
					+String.format("<HTML><CENTER><b>DynamicLoft</b><BR> %4.2f°</CENTER></HTML>|",this.fenetre.getClub().getDynamiqueLoftDegre())
					+String.format("<HTML><CENTER><b>SideSpin</b><BR> %4.0f rpm</CENTER></HTML>|",theBall.getSpinZOrgrpm())
					+String.format("<HTML><CENTER><b>impactAngle</b><BR> %4.2f°</CENTER></HTML>|",theBall.getImpactAngle()*180/Math.PI)
					+String.format("<HTML><CENTER><b>XFall</b><BR> %4.2fm</CENTER></HTML>|",matriceFlight.get((int) theBall.getIndexChute())[0])
					+String.format("<HTML><CENTER><b>XTotal</b><BR> %4.2fm</CENTER></HTML>|",matriceFlight.get(matriceFlight.size()-1)[0])
					+String.format("<HTML><CENTER><b>Temps Total</b><BR> %4.2fs</CENTER></HTML>|",theBall.getTempsTotal())
					+String.format("<HTML><CENTER><b>YFall</b><BR> %4.2fm</CENTER></HTML>|",matriceFlight.get((int) theBall.getIndexChute())[2])
					+String.format("<HTML><CENTER><b>YTotal</b><BR> %4.2fm</CENTER></HTML>|",matriceFlight.get(matriceFlight.size()-1)[2])
					+String.format("<HTML><CENTER><b>Temperature</b><BR> %4.2f°C</CENTER></HTML>|",this.fenetre.getClub().getTemperature())
					+String.format("<HTML><CENTER><b>Max Height</b><BR> %4.2fm</CENTER></HTML>|",theBall.getMaxHeight())
					+String.format("<HTML><CENTER><b>Same Frame</b><BR> %5b</CENTER></HTML>|",this.fenetre.getPlotInSameFrame())
					));		
			}
	}
} 

