# Introduction

Hello everyone, and welcome to the code repository for the DOT Parking Regulations Project.

The New York City (NYC) Department of Transportation (DOT) is responsible for installing all the signage in the five boroughs of NYC. NYC DOT recently created a dataset of all our [parking regulation signs](https://data.cityofnewyork.us/Transportation/Parking-Regulation-Locations-and-Signs/nfid-uabd/about_data) and released it to the NYC Open Data website ([Open Data]([url](https://opendata.cityofnewyork.us/))). For public consumption, they also created a public facing map of all parking regulation signage. However, recently the Parking team at NYC DOT would like to map these regulations to the NYC sidewalk curbs, similar to the map for [San Francisco](https://data.sfgov.org/Transportation/Map-of-Parking-Regulations/qbyz-te2i) and [Philadelphia](https://demos.azavea.com/phila-curb-map/) curbs.  This has been done before, for example, by the private company [SmoothParking](smoothparking.com).  Unlike the online application Smoothparking, this new application will be updated in near-real time using the information NYC DOT releases to Open Data. The goal of this project is to use the data on Open Data to create a python script that takes the parking regulations point data feed and maps it to the NYC curb line. This data will be highlighted as a custom web map application of all parking regulations along NYC curbs.

The easiest place to begin is by having a look at our [presentation](https://github.com/Jada68/DOT-Parking-Regulations/blob/main/presentations/Open%20Data%20Week%202024%20presentation_final.pdf) from Open Data Week 2024.  We will have a link to the recording available as soon as it is posted by NYC OTI.  The recording will only be available for NYC employees, so we will provide a breakdown on how we did this project on this page.

The pyhon, sql, and front end code is located in the [scripts](https://github.com/Jada68/DOT-Parking-Regulations/blob/main/scripts/) folder. This is a work in progress, so we will be updating this code frequently.  Let us know is you see a bug or have a suggestion for a feature.

<details>

<summary>Question from our Open Data Week 2024 presentation, 20 March 2024</summary>

### Would love to be able to download these clean layers directly from the web app, if possible :)

We can add a download option on our list of things to do.  However, it might not be necessary since we may decide to upload this data (as is, since it needs A LOT of work, but will get better with time) to Open Data.  If that is the case, then you can access the data using the SODA api provided.

### Are you able to share contact info?

Sure! You can reach Jada at Jada.Macharie96@myhunter.cuny.edu, and Maddalena at mromano1@dot.nyc.gov

### I’m curious what the front end is built on? Was there a specific design choice that led to you using the Esri JS API vs Experience Builder or similar? Looking back, would you have chosen any different tools or techniques?

We used as many open source tools as possible for this build--QGIS for spatial dataset exploration, PostGreSQL for the data engineering, and Python for the coding.  For the front end, we went with ESRI's Javascript API because it was easier.  As a student, Jada was able to create a developer account on ArcGIS Online and use the api.  Unlike using Experience Builder (which is available with a developer account), the api allows you to customize your interface with both ESRI widgets and bespoke code.  However, the frontend could easily have been built with Open Layers or React.js with a basemap from Carto or Mapbox--in the end, they all use HTML, CSS, and Javascript.

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

Hahahahaha we haven't--yet.  We are still playing with the data.  I'm considering using docker to separate the application from our infrastructure, since it's an open platform and it may help the speed to distribute the data processing over multiple cloud servers.  Stay tuned to hear about all our trials and tribulations.

### I will definitely like to follow up and see if there are plan to include other curb usage as that was something I did (measure each restaurant shed/citibike rack) and evening and Sunday parking.

There are!  We do plan to make the app more robust, and add more layers, filters, and other ways to parse the data.  As of 3/20/2024, we have figured out how to map to the curbline, and we are currently working on a frontend to display that.  Baby steps.

### Can you say a little more about how you were able to reduce query run time?

Building spatial indices creates an organized tree so that SQL isn’t looping through all the data but through specific indices that fit the code. Jada used the sqlalchemy package to pull her SQL queries into python. That said...we reduced the size of the dataset too :)  We are still working on reducing runtime, that's why I'm considering haveing Jada implement a docker to our technology stack, so we can containerize the process.  

### Is signage data available on Open Data is the same as DOT’s SIMS data base - does it also updates daily? Are there plans to incorporate temporal aspect of the parking signs that would lead to something like SpotAngels App does?

Yep, this data is on [Open Data](https://data.cityofnewyork.us/Transportation/Parking-Regulation-Locations-and-Signs/nfid-uabd/about_data). It's a subset of the [Street Sign Work Orders](https://data.cityofnewyork.us/Transportation/Street-Sign-Work-Orders/qt6m-xctn/about_data) data that we export from DOT's Sign Information Management System (SIMS)--a custom database developed in-house using PostGreSQL. The Parking regulations data DOES have a temporal aspect to it, but its buried in the sign description.  We do plan to add a temporal aspect to this, just can't say went just yet.

### Will there be way to subscribe to changes occurring in parking regulations with in a region or a map of block?

Great suggestion.  We will definitely consider it, but no promises.

### How do you see this tool benefitting/supporting the public as we enter this new NYC DOT era of congestion pricing?

I don't know precisely how this will help when it comes to congestion pricing.  Ideally, this will be a tool that can help the public understand all parking regulations in most areas of NYC (there are some private communities that are not under our jurisdiction).  

### NYC DOT folks, how about roadways that are on PANYNJ property, such as JFK, but have NYC DOT signage on it?

This falls out of our jurisdiction, so it will not be included.  Please note that signage follows the guidelines of the Manual on Uniform Traffic Control Devices for Streets and Highways (MUTCD), so it may *look* like its an NYC DOT sign, but actually be under the jurisdiction of another agency or entity.

</details>
