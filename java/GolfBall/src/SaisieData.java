import java.awt.GridLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class SaisieData extends JFrame  {
	/**
	 * Launch the input data window.
	 * @author Matthieu PHILIPPE
	 * @version  1.0
	 * @category A
	 * @see 
	 * @param 
	 * @return N/A	 
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
	private JTextField temperatureField;
	private Club club;
	private JCheckBox boutonCheck;
	
	public SaisieData(Club[] pSac){
		super("Simu");

		JPanel panel = new JPanel();
		panel.setLayout(new GridLayout(13,2));
		sac 	= pSac;
		club 	= sac[0]; // initialisation avec le driver

		// creation des champs
		//Type,  Poids , Loft , Ecoeff, CoeffBackSpin,	CoeffSpinLift, 	Cl1,  	pClubV0, pAlphaClubPath, 	pGamaFacePath,	pShafLeanImp
		JLabel clubText 					= new JLabel("Club");
		JLabel poidsText 					= new JLabel("Poids (kg)");
		JLabel temperatureText 				= new JLabel("Temperatuer (°C)");
		JLabel loftText 					= new JLabel("Loft (°)");
		JLabel ecoeffText 					= new JLabel("E coeff");
		JLabel backSpinText 				= new JLabel("Coeff BackSpin");
		JLabel spinLiftText 				= new JLabel("Coeff SideSpin");
		JLabel cl1Text 						= new JLabel("Cl1 (Smits and Smith)");
		JLabel vClubText 					= new JLabel("Vitesse Club (km/h)");
		JLabel clubPathText 				= new JLabel("Alpha ClubPath (°)");
		JLabel gamaPathText 				= new JLabel("Gama FacePath (°)");
		JLabel shaftLeanText 				= new JLabel("ShafLean Imp (°)");
		JButton boutonRun;
		
		listClub 		= new JComboBox<Object>();
		listClub.addActionListener(new ListClubAction(this,"List"));
		listClub.addFocusListener(new ListClubFocus(this));

		poidsField				= new JTextField(Double.toString(sac[0].getPoids()));
		poidsField.addActionListener(new PoidsAction(this,"Poids"));
		poidsField.addFocusListener(new PoidsFocus(this));

		temperatureField				= new JTextField(Double.toString(20.0));
		temperatureField.addActionListener(new TemperatureAction(this,"Poids"));
		temperatureField.addFocusListener(new TemperatureFocus(this));

		loftField 				= new JTextField(Double.toString(sac[0].getLoft()));
		loftField.addActionListener(new LoftAction(this,"Loft"));
		loftField.addFocusListener(new LoftFocus(this));

		ecoeffField 			= new JTextField(Double.toString(sac[0].getEcoeff()));
		ecoeffField.addActionListener(new ECoeffAction(this,"ECoeff"));
		ecoeffField.addFocusListener(new ECoeffFocus(this));

		coeffBackSpinField 		= new JTextField(Double.toString(sac[0].getCoeffBackSpin()));
		coeffBackSpinField.addActionListener(new CoeffBackSpinAction(this,"BackSpin"));
		coeffBackSpinField.addFocusListener(new CoeffBackSpinFocus(this));

		coeffSpinLiftField 		= new JTextField(Double.toString(sac[0].getCoeffSpinLift()));
		coeffSpinLiftField.addActionListener(new CoeffSpinLiftAction(this,"Lift"));
		coeffSpinLiftField.addFocusListener(new CoeffSpinLiftFocus(this));

		cl1Field 				= new JTextField(Double.toString(sac[0].getCl1()));
		cl1Field.addActionListener(new Cl1Action(this,"CL1"));
		cl1Field.addFocusListener(new Cl1Focus(this));

		clubFieldV0 			= new JTextField(Double.toString(sac[0].getClubV0ms()*3.6));
		clubFieldV0.addActionListener(new ClubVAction(this,"V0Club"));
		clubFieldV0.addFocusListener(new ClubVFocus(this));

		alphaClubPathField 		= new JTextField(Double.toString(sac[0].getAlphaClubPath()));
		alphaClubPathField.addActionListener(new AlphaClubPathAction(this,"Alpha"));
		alphaClubPathField.addFocusListener(new AlphaClubPathFocus(this));

		gamaFacePathField 		= new JTextField(Double.toString(sac[0].getGamaFacePath()));
		gamaFacePathField.addActionListener(new GamaFacePathFieldAction(this,"Gama"));
		gamaFacePathField.addFocusListener(new GamaFacePathFieldFocus(this));

		shafLeanImpField 		= new JTextField(Double.toString(sac[0].getShaftLeanImp()));
		shafLeanImpField.addActionListener(new shafLeanImpAction(this,"ShaftLean"));
		shafLeanImpField.addFocusListener(new shafLeanImpFocus(this));

		boutonRun 		= new JButton( new RunAction(this,"Swing"));
		boutonCheck 	= new JCheckBox( "Same Frame", false);

		for (Club j : pSac){
			listClub.addItem(j.getType());
		}
		panel.add(clubText);
		panel.add(listClub);
		panel.add(poidsText);
		panel.add(poidsField);
		panel.add(temperatureText);
		panel.add(temperatureField);
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
		panel.add(boutonCheck);

		this.getContentPane().add(panel);
		this.pack();
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
	public String getTemperatureField(){
		return temperatureField.getText();
	}	
	public Boolean getPlotInSameFrame(){
		return boutonCheck.isSelected();
	}
}
