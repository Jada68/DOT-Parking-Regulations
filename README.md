# Introduction

Hello everyone, and welcome to the code repository for the DOT Parking Regulations Project.

The New York City (NYC) Department of Transportation (DOT) is responsible for installing all the signage in the five boroughs of NYC. NYC DOT recently created a dataset of all our [parking regulation signs](https://data.cityofnewyork.us/Transportation/Parking-Regulation-Locations-and-Signs/nfid-uabd/about_data) and released it to the NYC Open Data website ([Open Data]([url](https://opendata.cityofnewyork.us/))). For public consumption, they also created a public facing map of all parking regulation signage. However, recently the Parking team at NYC DOT would like to map these regulations to the NYC sidewalk curbs, similar to the map for [San Francisco](https://data.sfgov.org/Transportation/Map-of-Parking-Regulations/qbyz-te2i) and [Philadelphia](https://demos.azavea.com/phila-curb-map/) curbs.  This has been done before, for example, by the private company [SmoothParking](smoothparking.com).  Unlike the online application Smoothparking, this new application will be updated in near-real time using the information NYC DOT releases to Open Data. The goal of this project is to use the data on Open Data to create a python script that takes the parking regulations point data feed and maps it to the NYC curb line. This data will be highlighted as a custom web map application of all parking regulations along NYC curbs.

The easiest place to begin is by having a look at our [presentation](https://github.com/Jada68/DOT-Parking-Regulations/blob/main/presentations/Open%20Data%20Week%202024%20presentation_final.pdf) from Open Data Week 2024.  We will have a link to the recording available as soon as it is posted by NYC OTI.  The recording will only be available for NYC employees, so we will provide a breakdown on how we did this project on this page.

The pyhon, sql, and front end code is located in the [scripts](https://github.com/Jada68/DOT-Parking-Regulations/blob/main/scripts/) folder. This is a work in progress, so we will be updating this code frequently.  Let us know is you see a bug or have a suggestion for a feature.

<details>

<summary>Tips for collapsed sections</summary>

### You can add a header

You can add text within a collapsed section. 

You can add an image or a code block, too.

```ruby
   puts "Hello World"
```

</details>
