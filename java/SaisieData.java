import java.awt.GridLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import org.jfree.ui.ApplicationFrame;
import org.jfree.ui.RefineryUtilities;

public class SaisieData extends ApplicationFrame{
	/**
	 * 
	 */
	private static final long serialVersionUID = 2L;
	private JComboBox<Object> listClub;
	private Club[] sac;
	private JTextField poidsField;
	private JTextField clubFieldV0;
	private JTextField loftField;
	private JTextField ecoeffField;
	private JTextField coeffBackSpinField;
	private JTextField coeffSpinLiftField;
	private JTextField cl1Field;
	private JTextField alphaClubPathField;
	private JTextField gamaFacePathField;
	private JTextField shafLeanImpField;
	private Club club;

	public SaisieData(Club[] pSac){
		super("Simu");

		JPanel panel = new JPanel();
		//panel.setLayout(new FlowLayout());
		panel.setLayout(new GridLayout(12,2));
		sac 	= pSac;
		club 	= sac[0]; // initialisation avec le driver

		// creation des champs
		//Type,  Poids , Loft , Ecoeff, CoeffBackSpin,	CoeffSpinLift, 	Cl1,  	pClubV0, pAlphaClubPath, 	pGamaFacePath,	pShafLeanImp
		JLabel clubText 					= new JLabel("Club");
		JLabel poidsText 					= new JLabel("Poids (kg)");
		JLabel loftText 					= new JLabel("Loft (°)");
		JLabel ecoeffText 					= new JLabel("E coeff");
		JLabel backSpinText 				= new JLabel("Coeff BackSpin");
		JLabel spinLiftText 				= new JLabel("Coeff SpinLift");
		JLabel cl1Text 						= new JLabel("Cl1");
		JLabel vClubText 					= new JLabel("Vitesse Club (km/h)");
		JLabel clubPathText 				= new JLabel("Alpha ClubPath (°)");
		JLabel gamaPathText 				= new JLabel("Gama FacePath (°)");
		JLabel shaftLeanText 				= new JLabel("ShafLean Imp (°)");

		listClub 		= new JComboBox<Object>();
		listClub.addActionListener(new ListClubAction(this,"List"));

		poidsField							= new JTextField(Double.toString(sac[0].getPoids()));
		poidsField.addActionListener(new PoidsAction(this,"Poids"));
		
		loftField 							= new JTextField(Double.toString(sac[0].getLoft()));
		loftField.addActionListener(new LoftAction(this,"Loft"));

		ecoeffField 						= new JTextField(String.format(null,Double.toString(sac[0].getEcoeff())));
		ecoeffField.addActionListener(new ECoeffAction(this,"ECoeff"));

		coeffBackSpinField 					= new JTextField(Double.toString(sac[0].getCoeffBackSpin()));
		coeffBackSpinField.addActionListener(new CoeffBackSpinAction(this,"BackSpin"));

		coeffSpinLiftField 					= new JTextField(Double.toString(sac[0].getCoeffSpinLift()));
		coeffSpinLiftField.addActionListener(new CoeffSpinLiftAction(this,"Lift"));

		cl1Field 							= new JTextField(Double.toString(sac[0].getCl1()));
		cl1Field.addActionListener(new Cl1Action(this,"CL1"));

		clubFieldV0 						= new JTextField(Double.toString(sac[0].getClubV0ms()*3.6));
		clubFieldV0.addActionListener(new ClubVAction(this,"V0Club"));

		alphaClubPathField 		= new JTextField(Double.toString(sac[0].getAlphaClubPath()));
		alphaClubPathField.addActionListener(new AlphaClubPathAction(this,"Alpha"));
		
		gamaFacePathField 		= new JTextField(Double.toString(sac[0].getGamaFacePath()));
		gamaFacePathField.addActionListener(new GamaFacePathFieldAction(this,"Gama"));
		
		shafLeanImpField 		= new JTextField(Double.toString(sac[0].getShaftLeanImp()));
		shafLeanImpField.addActionListener(new shafLeanImpAction(this,"ShaftLean"));
		
		/**
		 * Lancement du calcul de la modélisation.
		 * RunAction(this,"Swing")		
		 */
		JButton boutonRun 					= new JButton( new RunAction(this,"Swing")); // Lance le le calcul de la modélisation.
	/**
	 * creation de la list de choix deroulant des clubs du sac
	 */
		for (Club j : pSac){
			listClub.addItem(j.getType());
		}
		panel.add(clubText);
		panel.add(listClub);
		panel.add(poidsText);
		panel.add(poidsField);
		panel.add(loftText);
		panel.add(loftField);
		panel.add(ecoeffText);
		panel.add(ecoeffField);
		panel.add(backSpinText);
		panel.add(coeffBackSpinField);
		panel.add(spinLiftText);
		panel.add(coeffSpinLiftField);
		panel.add(cl1Text);
		panel.add(cl1Field);
		panel.add(vClubText);
		panel.add(clubFieldV0);
		panel.add(clubPathText);
		panel.add(alphaClubPathField);
		panel.add(gamaPathText);
		panel.add(gamaFacePathField);
		panel.add(shaftLeanText);
		panel.add(shafLeanImpField);
		panel.add(boutonRun);

		this.getContentPane().add(panel);
		
		this.pack();
		this.getContentPane();
		RefineryUtilities.centerFrameOnScreen(this);
		this.setVisible(true);
	}
	/**
	 * fin du constructeur
	 */
	public JComboBox<Object> getListClub(){
		return listClub;
	}
	public String getPoidsField(){
		return poidsField.getText();
	}
	public void setPoidsField(String poids){
		poidsField.setText(poids);
	}
	public String getECoeffField(){
		return ecoeffField.getText();
	}
	public void setECoeffField(String poids){
		ecoeffField.setText(poids);
	}
	public String getCoeffBackSpinField(){
		return coeffBackSpinField.getText();
	}
	public void setCoeffBackSpinField(String poids){
		coeffBackSpinField.setText(poids);
	}
	public String getCoeffSpinLiftField(){
		return coeffSpinLiftField.getText();
	}
	public void setCoeffSpinLiftField(String poids){
		coeffSpinLiftField.setText(poids);
	}	
	public void setCl1Field(String loft){
		cl1Field.setText(loft);
	}
	public String getCl1Field(){
		return cl1Field.getText();
	}
	public void setLoftField(String loft){
		loftField.setText(loft);
	}
	public String getLoftField(){
		return loftField.getText();
	}
	public String getClubV0Field(){
		return clubFieldV0.getText();
	}
	public int getSelectedIndex(){
		return listClub.getSelectedIndex();
	}
	public Club getClub(){
		return club;
	}
	public void setClub(int index){
		club = sac[index];
	}
	public String getAlphaClubPathField(){
		return alphaClubPathField.getText();
	}
	public String getGamaFacePathField(){
		return gamaFacePathField.getText();
	}
	public String getShafLeanImpField(){
		return shafLeanImpField.getText();
	}
}
