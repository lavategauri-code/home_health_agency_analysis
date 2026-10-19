Home Health Agency Analysis

For this project I looked at home health agencies in the US. I wanted to see how patient care ratings, Medicare spending, and the services agencies offer change across states and ownership types. 
I used SQL to clean and analyze the data and Tableau to build the dashboard.

<img width="959" height="539" alt="image" src="https://github.com/user-attachments/assets/2bb82605-dbe7-465d-bdfa-01378b30e79f" />


What I wanted to find out
- Do patient care star ratings differ by ownership type (nonprofit, for-profit, government)?
- Do agencies that cost Medicare more have better ratings?
- Which states spend more or less per episode?
- Which states have the most agencies that offer all six core services?

Data

- Source: CMS Home Health Agencies (data.cms.gov), downloaded [Aug, 2026]
- Tables: HHA_Info (agency information), HHA_QualityMeasures (star rating, Medicare spending index, number of episodes)
- Joined on: CMS Certification Number (CCN), which is each agency's unique ID

What I did
- Explored the data: counted agencies, checked for duplicate IDs, and looked at agencies per state and ownership types
- Joined the two tables into one temporary table
- Checked for missing values. Some are stored as text instead of NULL, so I used TRY_CAST to turn the measures into numbers
- Calculated average star ratings by state, ownership type, and agency
- Compared the Medicare spending index across states and against ratings
- Counted how many of six services each agency offers: nursing, physical therapy, occupational therapy, speech pathology, medical social services, and home health aide.
- Exported the results to Excel and used them to build the Tableau dashboard.

What I found
- Ownership: Nonprofit agencies had the highest average rating (3.36 stars), then for-profit (3.27), then government-operated (2.85). For-profit agencies are most of the data (6,087 agencies vs. 909 nonprofit) and 849 agencies have no ownership type listed.
- Spending vs ratings: Spending and ratings don't seem to be connected. Agencies that cost Medicare more did not have better ratings.
- Spending by state: Kansas (1.065), Arkansas (1.058), and Nebraska (1.043) had the highest spending indexes. Among states with a lot of agencies, Oregon was lowest (0.875). Puerto Rico had the lowest overall (0.694), but with only 29 agencies.
- Full-service agencies: New Jersey had the highest share of agencies offering all six services (97.4%), followed by Mississippi (88.1%) and Rhode Island (81.8%). Delaware (31.8%), Minnesota (31.9%), and Pennsylvania (34.5%) had the lowest.

Limits of this analysis
State numbers are plain averages, so a small agency counts the same as a big one.
Spending is not adjusted for how sick the patients are, so higher spending doesn't mean an agency is wasteful.
Some small states and territories have very few agencies, so their numbers can swing a lot. For the full-service comparison I only used states with at least 20 agencies.

- home_health_analysis.sql	My SQL code (exploring, cleaning, and analyzing the data)
- Portfolio_Project.twbx	My Tableau dashboard. It uses data exported from the SQL results.
- dashboard_preview.png	Screenshot of the dashboard

Tools
SQL, Tableau

About me
Gauri Lavate | lavategauri@gmail.com
