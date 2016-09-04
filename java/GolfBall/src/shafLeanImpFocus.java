import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;


public class shafLeanImpFocus implements FocusListener {
	private SaisieData fenetre;

	public shafLeanImpFocus(SaisieData saisieData){
		this.fenetre = saisieData;
	}
	public void focusGained(FocusEvent e) {
	}

	public void focusLost(FocusEvent e) {
		/**
		 * mise à jour de la donnee du club utilise
		 */
		this.fenetre.getClub().setShafLeanImpDegre(Double.parseDouble(this.fenetre.getShafLeanImpField()));
	}

}
