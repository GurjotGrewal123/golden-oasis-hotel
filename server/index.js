const express = require("express");
const app = express();
const cors = require("cors");
const pool = require("./db");

// Middleware
app.use(cors());
app.use(express.json()); 



// API Calls //

//Get hotel information
app.get("/hotel_info", async(req, res) => {
  try{
    const hotels = await pool.query(
      "SELECT  h.chain_name,street_name, street_number, city, province_state, category, available_rooms FROM hotels h, available_rooms_per_hotel arph where h.hotel_id = arph.hotel_id"
    );
    

    res.json(hotels.rows);
  }catch(err){
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});

// get all the rooms for specific hotel
app.get("/hotel_info/room/:id", async(req, res) => {

  try{
    const { id } = req.params;

    const hotels = await pool.query("SELECT * FROM rooms where hotel_id = $1", [
      id
    ]);
    

    res.json(hotels.rows);
  }catch(err){
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});

//Get customer information
app.get("/customer_info", async(req, res) => {
  try{

    const customers = await pool.query(
      "SELECT full_name, customer_email, street_number,street_name, city, province_state FROM customers"
    );

    res.json(customers.rows);
  }catch(err){
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});

//Get Bookings
app.get("/bookings_info", async(req, res) => {
  try{

    const bookings = await pool.query(
      "SELECT booking_id,chain_name,room_number,start_date,end_date,status,customer_email FROM bookings b,customers cu,hotels h WHERE b.customer_id = cu.customer_id AND h.hotel_id = b.hotel_id"
    );

    res.json(bookings.rows);
  }catch(err){
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});


//Get Rentings
app.get("/rentings_info", async(req, res) => {
  try{

    const rentings = await pool.query(
      "SELECT * FROM rentings"
    );

    res.json(rentings.rows);
  }catch(err){
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});

//Avg Rating of each hotel chain
app.get("/hotel_avg", async(req, res) => {
  try{

    const chain_avgs = await pool.query(
      "SELECT chain_name, avg(category) AS avg_rating FROM hotels GROUP BY chain_name;"
    );

    res.json(chain_avgs.rows);
  }catch(err){
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});

//Select 5 Star Rated hotels, where the chains do not have 1 or 2 rated hotels
app.get("/five_star", async(req, res) => {
  try{

    const fives = await pool.query(
      "select chain_name,street_name, street_number, city, province_state from hotels where category = 5 and chain_name not in (select chain_name from hotels where category = 2) and chain_name not in (select chain_name from hotels where category = 1)"
    );

    res.json(fives.rows);
  }catch(err){
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});

// customer creates a booking
app.post("/bookings", async (req, res) => {
  try {
    const { status, customer_id, start_date, end_date, room_number, hotel_id } = req.body;

    const newBooking = await pool.query(
      "INSERT INTO bookings (status, customer_id, start_date, end_date, room_number, hotel_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW()) RETURNING *",
      [status, customer_id, start_date, end_date, room_number, hotel_id]
    );

    res.json(newBooking.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});


app.put('/bookings/:bookingId', async (req, res) => {
  const { bookingId } = req.params;

  try {
    const result = await pool.query(
      'UPDATE bookings SET status = $1 WHERE booking_id = $2 RETURNING *',
      ['active', bookingId]
    );

    res.json({ message: 'Booking status updated successfully.' });

  } catch (error) {
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});



app.put('/rentings/:rentingId', async (req, res) => {
  const { rentingId } = req.params;

  try {
    const result = await pool.query(
      'UPDATE rentings SET status = $1 WHERE renting_id = $2 RETURNING *',
      ['completed', rentingId]
    );

    const bookingUpdate = await pool.query(
      'UPDATE bookings SET status = $1 WHERE booking_id = (SELECT booking_id FROM rentings WHERE renting_id = $2) RETURNING *',
      ['completed', rentingId]
    );

    res.json({ message: 'Renting status updated successfully.' });

  } catch (error) {
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});


app.listen(3001, () => {
  console.log("server has started on port 3001");
});