import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.ui.ApplicationFrame;
import java.awt.GridLayout;
import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import java.util.StringTokenizer;


public class GraphXYSeries  extends ApplicationFrame {
	/**
	 * 
	 */
	private XYSeries series = new XYSeries("Hauteur");
	private XYSeries series2 = new XYSeries("Largeur");
	
	private static final long serialVersionUID = 1L;

	public GraphXYSeries(final String title,String xTitle,String yTitle, String pLegend) {

		super(title);
		int 	i=0;
		final XYSeriesCollection data = new XYSeriesCollection(series);
		final XYSeriesCollection data2 = new XYSeriesCollection(series2);
		JPanel 		panel1 		= new JPanel();
		JPanel 		panel2 		= new JPanel();
		
		final JFreeChart chart = ChartFactory.createXYLineChart(
				title,
				"", 
				"Hauteur", 
				data,
				PlotOrientation.VERTICAL,
				false,
				true,
				false
				);
		final JFreeChart chart2 = ChartFactory.createXYLineChart(
				"",
				xTitle, 
				"Largeur", 
				data2,
				PlotOrientation.VERTICAL,
				false,
				true,
				false
				);
		
		final ChartPanel chartPanel  = new ChartPanel(chart);
		final ChartPanel chartPanel2 = new ChartPanel(chart2);
		
		chartPanel.setMouseWheelEnabled(true);
		chartPanel2.setMouseWheelEnabled(true);
		
		this.setLayout(new GridBagLayout());
		GridBagConstraints c = new GridBagConstraints();
		StringTokenizer multiTokenizer = new StringTokenizer(pLegend, "|");
		
		panel1.setLayout(new GridLayout(14,2));
		i = 1;
		/**
		 * tant que pLegend contient des string deparee par |
		 * la fonction while cree des boutons
		 */
		while (multiTokenizer.hasMoreTokens())
		{
			i++;
			panel1.setLayout(new GridLayout(i,2));
			panel1.add(new JButton(multiTokenizer.nextToken()));
		}
		
		panel2.setLayout(new GridLayout(2,1));
		panel2.add(chartPanel);
		panel2.add(chartPanel2);

		c.gridx = 0;
		c.gridy = 0;
	    c.weightx = 0;
	    c.weighty = 0;
	    c.fill = GridBagConstraints.BOTH;
		this.getContentPane().add(panel1, c);
		
		c.gridx = 1;
		c.gridy = 0;
		c.fill = GridBagConstraints.BOTH;
	    c.gridwidth = 1;
	    c.weightx = 1;
	    c.weighty = 1;
		this.getContentPane().add(panel2,c);
		this.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
	}
	public void setKey(String pLegend)
	{
		this.series2.setKey(pLegend);
	}
	public XYSeries getSeries()
	{
		return series;
	}
	public XYSeries getSeries2()
	{
		return series2;
	}
	public void addSeries(double X, double Y)
	{
		this.series.add(X, Y);
	}
	public void addSeries2(double X, double Y)
	{
		this.series2.add(X, Y);
	}
	public void removeSeries(int i)
	{
		series.remove(i);
	}
	public void removeSeries2(int i)
	{
		series2.remove(i);
	}
}
