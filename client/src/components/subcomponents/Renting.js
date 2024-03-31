import React, { useState, useEffect } from 'react';
import { Modal, Button } from 'react-bootstrap';
import 'react-date-range/dist/theme/default.css';



function Renting({ show, onHide }) {


    const handleSubmit = async (event) => {
        event.preventDefault(); 
        
        const formData = new FormData(event.target);
        const data = Object.fromEntries(formData.entries());
      
        try {
          const response = await fetch('http://localhost:3001/rentings', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
          });
      
          if (response.ok) {
            const newRenting = await response.json();
            console.log('New renting:', newRenting);
            onHide();
          } else {
            console.error('Failed to create renting:', response.statusText);
          }
        } catch (error) {
          console.error('Error creating renting:', error.message);
        }
      };
      


    return (
        <Modal show={show} onHide={onHide}>
        <Modal.Header closeButton>
            <Modal.Title>Customer Rental</Modal.Title>
        </Modal.Header>
        <Modal.Body>
            <form onSubmit={handleSubmit}>
            <div className="form-group">
                <label htmlFor="employee_id">Employee ID:</label>
                <input type="text" className="form-control" id="employee_id" name="employee_id" required />
            </div>
            <div className="form-group">
                <label htmlFor="customer_id">Customer ID:</label>
                <input type="text" className="form-control" id="customer_id" name="customer_id" required />
            </div>
            <div className="form-group">
                <label htmlFor="start_date">Start Date:</label>
                <input type="date" className="form-control" id="start_date" name="start_date" required />
            </div>
            <div className="form-group">
                <label htmlFor="end_date">End Date:</label>
                <input type="date" className="form-control" id="end_date" name="end_date" required />
            </div>
            <div className="form-group">
                <label htmlFor="room_number">Room Number:</label>
                <input type="number" className="form-control" id="room_number" name="room_number" required />
            </div>
            <div className="form-group">
                <label htmlFor="hotel_id">Hotel ID:</label>
                <input type="number" className="form-control" id="hotel_id" name="hotel_id" required />
            </div>
            <button type="submit" className="btn btn-primary mt-2">Submit</button>
            </form>
        </Modal.Body>
        <Modal.Footer>
            <Button variant="secondary" onClick={onHide}>
            Close
            </Button>
        </Modal.Footer>
        </Modal>

    );
}

export default Renting;
