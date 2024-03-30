Golden Oasis Hotels
-

Authors:

Gurjot Grewal (300263760) 

Matthew Petrucci (300119235)

Ryan Frost-Garant (300114543)

This project is a website that allows users to book and rent hotels all across the United States for various chains. It was created for our CSI2132 Winter 2024 Final Project.

The main objective of this project was to implement foundational principles of database design in order to develop a tailored schema that meets the requirements of a specific domain. This schema was subsequently employed to support the development of a web application.

Specific steps to install the applications:

1. Go to the db.js file in the server folder.

    a. Change the password to your postgres password.
   
2. Go to the server folder in your terminal.

    a. Run the script by using “./script.sh” in your terminal
   
   
    b. Continue to enter your postgres password as it created the database.
   
    c .If you are having trouble running the script then you can enter each command manually in gitbash.
   
      psql -h localhost -U postgres -p 5432 -c "DROP DATABASE IF EXISTS goldenoasisdb;"
   
      psql -h localhost -U postgres -p 5432 -c "CREATE DATABASE goldenoasisdb;"
   
      psql -h localhost -d goldenoasisdb -U postgres -p 5432 -f database.sql
   
    d. Run “node index” in your terminal to start the server. You should see that it has started on port 3001.
   
3. Go to the client folder in a different terminal while the server is running.
   
    a. Run npm install.
   
    b. Run npm start. The website should launch.


The following is a video overview of the project:




