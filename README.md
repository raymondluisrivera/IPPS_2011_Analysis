# IPPS_2011_Analysis
An analysis on Medicare Hospital Inpatient Prospective Payment System (IPPS) data for 2011
   
   Welcome to the 2011 Medicare Hospital Inpatient Prospective Payment System (IPPS) analysist. This analysis will take information from IPPS 2011 data file and try to acquire some insights into how hospitals function under the Medicare System.
   
   This data set contains inpatient discharge information on all 50 states in 2011, totaling 160,847 rows of data. Although we can gather some useful information about inpatient trends in the country and payments related to services offered, I want to focus this analysis on one state. So, in the spirit of state-pride, this analysis will focus solely on the data acquired from my home state of New York.
	So that anyone reading this can fully understand what exactly is going on, we have a few terms that need to be defined before we get into the nitty-gritty of the data. These terms are:
	
•	Diagnosis-Related-Group (DRG) - The DRG is a system of codes developed by the Center for Medicare and Medicaid Services (CMS) to assist hospitals in documenting the services they provide.  This is how CMS determines how much money they will pay to a hospital for a particular service
•	Provider ID – Provider ID’s are used to identify hospitals in the US that do business with CMS *all of them*
•	Average Covered Charges – This is the average amount a hospital charges for a service provided under a specific diagnosis
•	Average Medicare Payments – This is the average amount of money CMS will pay a hospital for the service they’ve provided under a specific DRG code *This is important*
•	Average Total Payments – This is the average amount of money a hospital receives for a service they provided under a specific diagnosis (including Medicare payments)
Now that we have the technical stuff out of the way, let’s gain some insights into our data. The first thing we want to know is “what is the most ‘popular’ service hospital’s provide in New York?”. We’re using SQL to manipulate the IPPS 2011 data and after a few commands we get [bleep, bleep, bloop]:
871 ' SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC' 
with 21,596 total discharges for this diagnosis in NY for 2011. 

<div class='tableauPlaceholder' id='viz1620094593615' style='position: relative'><noscript><a href='#'><img alt='TOP 5 DRG&#39;S IN NY ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;dr&#47;drgdata&#47;Sheet2&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='drgdata&#47;Sheet2' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;dr&#47;drgdata&#47;Sheet2&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en' /></object></div> 

   We’ll use this diagnosis to focus our analysis. From this point on, all inquiries will be centered around 871 ' SEPTICEMIA OR SEVERE SEPSIS W/O MV 96+ HOURS W MCC', hereby known as 871, in NY for 2011. So, what is this DRG with the ridiculously long name. Well, Septicemia is when bacteria enter the bloodstream and literally poison you, Sepsis is the escalation of Septicemia to the point where major damage to tissue, organ failure, and death can occur (What’s the difference between sepsis and septicemia? 2019). *Yikes* The ‘W/O MV’ part means that no mechanical ventilation was used to support the patient during their inpatient stay (i.e., positive pressure ventilation, negative pressure ventilation). The ‘96+ Hours W MCC’ means that the patient experienced major complications for at least 96 hours during their stay at the hospital. 
   
   OK, so because were dealing with CMS data, we should check what the average Medicare payment was for 871 in NY for 2011. The dataset collects information for each DRG a hospital billed to CMS in 2011. The ‘total discharges’ column is produced as a sum of all the discharges for a specific diagnosis that specific hospital reported to CMS. This will require us to take the weighted mean of ‘average Medicare payments’. Let’s go back to our SQL machine and [beep, beep, beep]: 
The average Medicare payments for 871 in NY for 2011 was ~$16,195.60 USD

   That’s quite a big number. If we take this number and multiply it by the total amount of discharges for the 871, we learn that CMS paid roughly *very rough* $349,760,177.60 USD to NY hospitals to treat 871. Now, this may sound ridiculous. You’re probably thinking, “there is no way the Federal Government paid that much to one state alone. Check your math, idiot”. But, we have to keep in mind that CMS spent $555 billion USD in 2011 alone, and that numbers only increased, so…
	
   Alright, now we’re cooking. We know the average amount Medicare paid for 871, so let’s figure out what the average amount hospitals in NY charged for treating 871. Again, we’ll have to take the weighted Average. Let’s return to our handy SQL machine and [blup, blap, blop]:
The average covered charges for 871 in NY for 2011 was ~$47,609.05 USD.
	
   Hmm, I guess that ‘average Medicare payment’ number doesn’t seem so big in comparison. In fact, the average covered charges are over twice as much as the average Medicare payment; this isn’t looking too hot. Ahh, but we still have average total payments, this will cover our deficit. Again, lets go to our SQL machine – making sure to calculate the weighted mean – and [flim, flang, flong] (okay, I’m out of computer noises):
The average total payments for 871 in NY for 2011 was ~$17,315.26
	
   Wait so if the average hospital in NY charged ~$47,609.05 USD for 871 and the average total payment for 871 was ~$17,315.26, then that means… OH MY GOD, all the hospitals in NY are in financial ruin! 
	
   Well, now that we’ve composed ourselves, I’m interested to see what hospitals charge the most for 871. We’re going to perform a few more SQL queries to represent this data, so let’s do a sub-query to locate which hospitals charged above the weighted mean for ‘average covered charges’, order them in descending order according to ‘average covered charged’ and return the first three:
1.	Westchester Medical Center with an ‘averaged covered charge’ of $133,997.27
2.	Lenox Hill Hospital with an ‘averaged covered charge’ of $119,899.16
3.	NYU Hospitals Center with an ‘averaged covered charge’ of $91,776.62
Wow, that is astonishing. And on average Medicare only paid ~$23,424.73USD to these hospitals. Ok, so a few things we notice from this list is that 2/3 of these are located within NYC limits, those two being Lenox Hill Hospital and NYU Hospital Center. The other one, Westchester Medical Center, is located in Westchester county which is right outside of city-limits. Another interesting commonality between these three hospitals is that they are non-profit facilities 

<div class='tableauPlaceholder' id='viz1620095471687' style='position: relative'><noscript><a href='#'><img alt='Difference Between Weighted Mean Medicare Payments and Weighted Mean Cover Charges For Top 11 Cover Charges Above The Average-Weighted Mean For Septicemia Cover Charges In NY ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;dr&#47;drgdata&#47;Sheet6&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='drgdata&#47;Sheet6' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;dr&#47;drgdata&#47;Sheet6&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en' /><param name='filter' value='publish=yes' /></object></div>

   Alright, how about the bottom 3 above the weighted mean for ‘average covered charges’ for 874. How much did they charge?
1.	Mercy Medical Center with an ‘averaged covered charge’ of $49,295.43
2.	Franklin Hospital with an ‘averaged covered charge’ of $48,273.17
3.	South Hampton Hospital with an ‘averaged covered charge’ of $47,739.02

   We did it for the top 3, so let’s find out how much CMS pays the bottom 3 on our list. On average, CMS pays these facilities ~$ 13,263.60 for 871. All three of these hospitals are located a ways away from NYC city limit (Long Island), but still relatively close. These hospital’s profit statuses are a little ambiguous. Mercy Medical, Franklin and South Hampton all say they are non-profit however, Franklin and South specify that donations are accepted through a separate company they hold, which is designates as a non-profit.
   
<div class='tableauPlaceholder' id='viz1620095722258' style='position: relative'><noscript><a href='#'><img alt='Difference Between Weighted Mean Medicare Payments and Weighted Mean Cover Charges For Bottom 11 Cover Charges Above The Average-Weighted Mean For Septicemia Cover Charges In NY  ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;dr&#47;drgdata&#47;Sheet5&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='drgdata&#47;Sheet5' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;dr&#47;drgdata&#47;Sheet5&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en' /><param name='filter' value='publish=yes' /></object></div>                <script type='text/javascript'>                    var divElement = document.getElementById('viz1620095722258');                    var vizElement = divElement.getElementsByTagName('object')[0];                    vizElement.style.width='100%';vizElement.style.height=(divElement.offsetWidth*0.75)+'px';                    var scriptElement = document.createElement('script');                    scriptElement.src = 'https://public.tableau.com/javascripts/api/viz_v1.js';                    vizElement.parentNode.insertBefore(scriptElement, vizElement);                </script>

   Okay, so the non-profit/profit theory didn’t pan out. But maybe we can use median income to find a pattern. According to the Census Bureau, the median income in NYC was $63,998 (2019 dollars) and in Long Island it was $116,100 (2019 dollars). Wait, what? This doesn’t make sense. Wouldn’t it make more sense for the location with higher median income to have more expensive medical care? So, we can’t use hospital profit status or income. What should we look at next?
	
   Alright, I think we should answer two questions first: how can hospitals keep treating 871 when they don’t even get reimbursed for half the treatment they provide? And, how exactly is DRG calculated? I think these two questions will help us determine why the price for treating 871 is so high, and how is median income negatively correlated to 871 treatment cost.
	
   Let’s start of with the first question, how can hospitals keep treating 871 when they stand to gain less than half of the capital they invested in treatment? Well, when you think about it, there seems to be an obvious answer; the alternative is death. They can’t pick and chose who they treat based on whether they undertake a financial loss in doing so. But, that begs the question; why not try and find ways to lower overall cost of treatment for 871? It seems I’m not the first person to ask this question! And, the answer is not simple. 871 is very difficult to treat. Once diagnosed with 871, admission in to the Intensive Care Unit (ICU) is necessary. Treating 871 requires constant care. Labs must be taken frequently to gauge the progress of treatment, nurses must service patients around the clock, and physician are required to be on standby constantly to assess the patients state and redirect treatment if things go sideways (Kulick, Bina, Vaghela, 2020). The length of stay (LOS) for treatment also affects covered charges drastically, and because 871 has one of the highest LOS – On average 75% longer that other diagnosis requiring inpatient treatment – covered charges will be high regardless if slightly cheaper forms of treatment are employed (Kulick, Bina, Vaghela, 2020). Lastly – and this ties very well with our second question – being readmitted for 871 treatment is likely. 13% of all patients that get treated for 871 will have to return to the ICU immediately after discharge (Kulick, Bina, Vaghela, 2020). This is very important because CMS does not like when this happens. There’s actually a long history of CMS fighting with hospitals about this very thing that is outside the scope of this analysis, but all you need to know is that CMS penalizes hospitals that readmit patients under the same DRG within very close timeframes with lower Medicare payments. 
	
   Now, we have to find out how CMS decides how much to pay hospitals. Payments depend on a variety of factors, but all build on the ‘DRG Weights’ system (). Basically, the weight reflects the average level of resources for an average Medicare patient treated under a DRG, relative to the average level of resources for all Medicare patients (Office of Inspector General, 2001). The ‘DRG Weights’ do not take into account varying treatment cost across the country and use all covered charges associated with that DRG in the US to determine weights. That’s not to say that CMS doesn’t recognize price differentiations across the country, in fact, CMS offers additional payments depending on: wage indexes, cost outliers, whether the hospital is a teaching hospital, and if the majority of the patient’s they are treating for that DRG can be categorized as low income (Office of Inspector General, 2001). However, what CMS giveth, CMS taketh away. CMS does not like to pay more than it has too for treatments and penalizes hospitals that provide substandard treatment, like readmissions. 
	
   This actually worked, with these key pieces of information we can develop a hypothesis. Westchester Medical Center, Lenox Hill and NYU are all teaching hospitals. With the exception of Mercy Medical Center, Franklin Hospital and South Hampton Hospital are not teaching hospitals. So, we can hypothesize that because teaching hospitals are training medical personnel, the number of test and interventions will be higher than that of private hospitals. We already know that 871 requires many labs, interventions, personnel, and medications to be administered in order to treat, so it makes sense that private hospitals, composed of experienced physician and personnel, wont need as many of these resources to treat, as opposed to medical professional straight out of school that require constant supervision and much practice to hone their skills. 
	
   So, we have our hypothesis, but one thing is still bothering me; the income questions. People in Long Island, on average, make more money than those living in NYC, so it should follow that they would pay more for medical treatment, not less. Digging a little deeper in to 871 tells us that adults over the age of 65 are 13 times more likely to be hospitalized with 871 (Sepsis.org, 2021). Ok, now we’re getting somewhere. It turns that according to data collected by Center for an Urban Future, Long Island had a little over 480,000 residents over the age of 65 in 2017 (Center for an Urban Future, 2019) In NYC, that number was over 1 million (NYC Comptroller’s Office, 2017). That’s a pretty big difference, and with this we come to our second hypothesis. Because the over 65 population in NYC is much higher, they see more 871 cases than a hospital in Long Island would, and in turn, the average covered charges for 871 will be higher in NYC than in Long Island because of this. In order to test these hypotheses, we’ll need more detailed information on 871 treatments in NY, but this analysis is a good start. 

   Thanks for reading this all the way through. I actually only have a general understanding of the economics surrounding the health care field, so I learned a lot from this analysis. I definitely want to test these hypotheses out in the future. I wasn’t able to develop any meaningful insights from this data, but the analysis definitely did produce fruitful avenues for further research on the topic of CMS reimbursement and the hospital business model. One last thing, because I was really interested, the lowest average covered charge in NY was $8,886.46 USD and the hospital was Wyoming County Community Hospital, located in North-western New York. Interestingly enough, they ended up making money from 871 treatment. The average Medicare payment for 871 in this hospital was $13,181.23 USD. I guess the moral of this story is that if you’re going to open a hospital make sure it’s small and remote or else, you’ll never make any money. 
