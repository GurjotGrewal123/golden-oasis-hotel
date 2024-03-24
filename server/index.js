const express = require("express");
const app = express();
const cors = require("cors");
const pool = require("./db");

// Middleware
app.use(cors());
app.use(express.json()); 



// API Calls //

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

// employee approves a booking in the system that is in the 'scheduled' state or creates a renting for a customer
app.post("/rentings", async (req, res) => {
  try {
    const { booking_id, employee_id, customer_id, status, start_date, end_date, room_number, hotel_id } = req.body;

    const newRenting = await pool.query(
      "INSERT INTO rentings (booking_id, employee_id, customer_id, status, start_date, end_date, room_number, hotel_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW()) RETURNING *",
      [booking_id, employee_id, customer_id, status, start_date, end_date, room_number, hotel_id]
    );

    res.json(newRenting.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send("Internal Server Error");
  }
});





// The following is just an example of a API calls. It does not have anything to do with the hotels.
//create a todo
app.post("/todos", async (req, res) => {
  try {
    const { description } = req.body;
    const newTodo = await pool.query(
      "INSERT INTO todo (description) VALUES($1) RETURNING *",
      [description]
    );

    res.json(newTodo.rows[0]);
  } catch (err) {
    console.error(err.message);
  }
});

//get all todos
app.get("/todos", async (req, res) => {
  try {
    const allTodos = await pool.query("SELECT * FROM todo");
    res.json(allTodos.rows);
  } catch (err) {
    console.error(err.message);
  }
});

//get a todo
app.get("/todos/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const todo = await pool.query("SELECT * FROM todo WHERE todo_id = $1", [
      id
    ]);

    res.json(todo.rows[0]);
  } catch (err) {
    console.error(err.message);
  }
});

//update a todo
app.put("/todos/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { description } = req.body;
    const updateTodo = await pool.query(
      "UPDATE todo SET description = $1 WHERE todo_id = $2",
      [description, id]
    );

    res.json("Todo was updated!");
  } catch (err) {
    console.error(err.message);
  }
});

//delete a todo
app.delete("/todos/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const deleteTodo = await pool.query("DELETE FROM todo WHERE todo_id = $1", [
      id
    ]);
    res.json("Todo was deleted!");
  } catch (err) {
    console.log(err.message);
  }
});

app.listen(3001, () => {
  console.log("server has started on port 3001");
});