# Introduction

Hello everyone, and welcome to the code repository for the DOT Parking Regulations Project.

The New York City (NYC) Department of Transportation (DOT) is responsible for installing all the signage in the five boroughs of NYC. NYC DOT recently created a dataset of all our [parking regulation signs](https://data.cityofnewyork.us/Transportation/Parking-Regulation-Locations-and-Signs/nfid-uabd/about_data) and released it to the NYC Open Data website ([Open Data]([url](https://opendata.cityofnewyork.us/))). For public consumption, they also created a public facing map of all parking regulation signage. However, recently the Parking team at NYC DOT would like to map these regulations to the NYC sidewalk curbs, similar to the map for [San Francisco](https://data.sfgov.org/Transportation/Map-of-Parking-Regulations/qbyz-te2i) and [Philadelphia](https://demos.azavea.com/phila-curb-map/) curbs.  This has been done before, for example, by the private company [SmoothParking](smoothparking.com).  Unlike the online application Smoothparking, this new application will be updated in near-real time using the information NYC DOT releases to Open Data. The goal of this project is to use the data on Open Data to create a python script that takes the parking regulations point data feed and maps it to the NYC curb line. This data will be highlighted as a custom web map application of all parking regulations along NYC curbs.

The easiest place to begin is by having a look at our [presentation](https://github.com/Jada68/DOT-Parking-Regulations/blob/main/presentations/Open%20Data%20Week%202024%20presentation_final.pdf) from Open Data Week 2024.  We will have a link to the recording available as soon as it is posted by NYC OTI.  The recording will only be available for NYC employees, so we will provide a breakdown on how we did this project on this page.

The pyhon, sql, and front end code is located in the [scripts](https://github.com/Jada68/DOT-Parking-Regulations/blob/main/scripts/) folder. This is a work in progress, so we will be updating this code frequently.  Let us know is you see a bug or have a suggestion for a feature.

<details>

<summary>Question from our Open Data Week 2024 presentation</summary>

### Would love to be able to download these clean layers directly from the web app, if possible :)

We can add a download option on our list of things to do.  However, it might not be necessary since we may decide to upload this data (as is) to open data.  If that is the case, then you can access the data using the SODA api provided.

### Are you able to share contact info?

Sure! You can reach Jada at Jada.Macharie96@myhunter.cuny.edu, and Maddalena at mromano1@dot.nyc.gov

### I’m curious what the front end is built on?

We used as many open source tools as possible for this build--QGIS for spatial dataset exploration, PostGreSQL for the data engineering, and Python for the coding.  For the front end, we went with ESRI's Javascript API because it was easier.  As a student, Jada was able to create a developer account on ArcGIS Online and use the api.  However, the rontend could easily have been built with Open Layers or React.js with a basemap from Carto or Mapbox.  

### Do you anticipate publishing these parking regulations line features on OpenData?

That is the plan, but neither Jada or I make that decision--we need to go to the data owners and get the okay.  Matt Garcia, who spoke during presentation is one of those data owners, but there are others that also need to be consulted, hence, no timeline yet.

### This is awesome, so this is an enhancement to https://nycdotsigns.net/?

We're thinking of it as a separate applicaiton for now. No plans on retiring the OG website.

###  I am just generally curious about your experience with various mapping tools and what do you find to be the most seamless for various mapping tasks. 

I (Maddalena) started with ESRI products, because of course I did--they market their products to every school, public sector agency, and non-profit.  I also learned Transmap and Idrisi products, and a little bit of GRASS.  Once I got into the private sector, I learned just how expensive commerical of the shelf (COTS) software could be, and I started experimenting with other resources like Google Maps, Carto, Mapbox.  My love is web mapping, so that was my sandbox.  When QGIS became popular, I asked my team to use it because we could quickly create Leaflet maps.  

However, I now work in public sector, and we have access to ArcGIS Online.  This makes the ArcGIS Javascript API a viable option for creating frontends--as long as our data lives in REST services (which we create) or as geojson files (which are bigger and slow things down, but still a useful option.  But that doesn't mean that I don't use plotly, React, OpenLayers--use whatever works best I say.

As far as desktop software, I find free open source software (FOSS) to be less intuitive than COTS, which is both good and bad.  A power user can get lots of stuff done with QGIS--it reminds me of the original ArcGIS which required the user to be more savvy.  New products tend to have a better User Interface (UI), which is great for more casual users because it can help them to get started more quickly.  However, both require time to learn how to use it.

### The only suggestion I have is to user-test some prototypes of the web app map for varying degrees of vision levels/color maps.

Will do!  When in development, we test our app using the Google Chrome's Colorblindly extension.  It lets us view what the colors would look nice in all different types of colorblindness.  We do use colorbrewer often as well to get us started with color schemes--they have palettes that are colorblind friendly.  When we move to production, our ITT team checks for accessibilty of all types before an app goes public.

### I had questions about the python portion, when you used geopandas, which portion did you use geopandas for?

For this project we mainly use it for creating geodataframes and manipulating the data, but I've used it for much more.  If you've never used it, but are curious, check out [this link](https://github.com/geopandas/geopandas?tab=readme-ov-file) for a good description of what geopandas and shapely libraries do.

### What type of performance challenges did you have working with the large datasets and how did you overcome them?

Hahahahaha we haven't--yet.  We are still playing with the data.  I'm considering a docker, since it may help to distribute the data processing over multiple servers.  Stay tuned to hear about all our trials and tribulations.

### I will definitely like to follow up and see if there are plan to include other curb usage as that was something I did (measure each restaurant shed/citibike rack) and evening and Sunday parking.

There are!  We do plan to make the app more robust, and add more layers, filters, and other ways to parse the data.  As of 3/20/2024, we have figured out how to map to the curbline, and we are currently working on a frontend to display that.  Baby steps.

### Can you say a little more about how you were able to reduce query run time?

Sure...we reduced the size of the dataset U+1F643

00:56:21	Jack Rosacker (DCP):	Two questions if there's time: (1) Was there a specific design choice that led to you using the Esri JS API vs Experience Builder or similar, and (2) Looking back, would you have chosen any different tools or techniques?

00:58:45	Casey Smith (DCP):	Curious if you’ve considered containerizing the process in something like docker?

01:01:47	lucinachavez:	Lucina Chavez: chavezlucina1@gmail.com

01:04:19	Dan Levine:	Working at another city agency, I have had similar concerns about publishing processed data that has not been fully QA'ed. great to hear your consideration and thanks for sharing your work in progress!

01:04:32	Bartosz Bonczak:	Great work! Two questions: (1) is signage data available on Open Data is the same as DOT’s SIMS data base - does it also updates daily? (2) Are there plans to incorporate temporal aspect of the parking signs that would lead to something like SpotAngels App does?

01:04:39	Dennis's iPhone (2):	Will there be way to subscribe to changes occurring in parking regulations with in a region or a map of block

01:04:45	Jada Grandchamps:	Replying to "Can you say a little..."
Building spatial indices creates an organized tree so that SQL isn’t looping through all the data but through specific indices that fit the code

01:06:04	Casey Smith (DCP):	Replying to "Curious if you’ve co..."
I’m certainly not a docker—but its an open platform that allows you to separate your applications/processes from your own infrastructure to increase processing speeds

01:06:44	Jada Grandchamps:	I used the sqlalchemy package to pull my SQL queries into python

01:08:34	Emily Pramik (IBO):	Replying to "Wonderful work, Jada..."
colorbrewer could be a good place to start: https://colorbrewer2.org/

01:08:40	Jada Grandchamps:	Replying to "Curious if you’ve co..."
@Casey Smith (DCP) Thank you. I will definitely look into this

01:09:36	Amir Hassan:	Python Tutorial (w3schools.com)
@Sarah Ward, this is a great resource that I used to learn Python from

01:10:29	lucinachavez:	Having just spent the past 4 months collecting parking data, I appreciate how multi-pronged this issue is—particularly vis-a-vis congestion pricing and curb management where parking is under crossfire—how do you see this tool benefitting/supporting the public as we enter this new NYC DOT era?

01:14:36	Bartosz Bonczak:	Simply switching to code-based processing (like Python and GeoPandas) might help in performance as it doesn’t need to render all of the data points saving memory. Of course there are other options when moving away from the single machine.

01:17:15	Amir Hassan:	NYC DOT folks, how about roadwalks that are on PANYNJ property, such as JFK, but have NYC DOT signage on it?



</details>
