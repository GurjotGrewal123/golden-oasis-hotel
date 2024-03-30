import React from "react";
import { useState, useEffect } from "react";
import { Button, Collapse} from 'react-bootstrap';


function Employee(){

    const [dataCust, setDataCust] = useState({customers:[]});
    const [dataBook, setDataBook] = useState({bookings:[]});
    const [dataRent, setDataRent] = useState({rentings:[]});
    const [open1, setOpen1] = useState(false);
    const [open2, setOpen2] = useState(false);
    const [open3, setOpen3] = useState(false);

    useEffect(() => {
        fetch("http://localhost:3001/customer_info") 
        .then((response) => response.json())
        .then((data) => setDataCust({customers: data}));
    }, []);

    useEffect(() => {
        fetch("http://localhost:3001/bookings_info")
        .then((response) => response.json())
        .then((data) => setDataBook({bookings: data}));
    }, [dataBook]);

    useEffect(() => {
        fetch("http://localhost:3001/rentings_info")
        .then((response) => response.json())
        .then((data) => setDataRent({rentings: data}));
    }, [dataRent]);

    const updateBooking = async (booking_id) => {
        try {
          const response = await fetch(`http://localhost:3001/bookings/${booking_id}`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({}), 
          });
      
          if (response.ok) {
            const data = await response.json();
            console.log(data.message); 
          } else {
            console.error('Failed to update booking status:', response.statusText);
          }
        } catch (error) {
          console.error('Error updating booking status:', error.message);
        }
      };

      const updateRenting = async (renting_id) => {
        try {
            const response = await fetch(`http://localhost:3001/rentings/${renting_id}`, {
              method: 'PUT',
              headers: {
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({}), 
            });
        
            if (response.ok) {
              const data = await response.json();
              console.log(data.message); 
            } else {
              console.error('Failed to update renting status:', response.statusText);
            }
          } catch (error) {
            console.error('Error updating renting status:', error.message);
          }
      };

    const showCust = (customer) => {
        return (<tr>
            <th scope="row">{customer.full_name}</th>
            <td>{customer.customer_email}</td>
            <td>{customer.street_number}</td>
            <td>{customer.street_name}</td>
            <td>{customer.city}</td>
            <td>{customer.province_state}</td>
        </tr>);
    }

    const showBookings = (bookings) => {
        return (<tr>
            <th scope="row">{bookings.chain_name}</th>
            <td>{bookings.room_number}</td>
            <td>{bookings.start_date}</td>
            <td>{bookings.end_date}</td>
            <td>{bookings.status}</td>
            <td>{bookings.customer_email}</td>
            <Button
                onClick={() => updateBooking(bookings.booking_id)}
                variant="warning"
            >
                Check-In
            </Button>      
            </tr>);
    }

    const showRentings = (rentings) => {
        return (<tr>
            <th scope="row">{rentings.hotel_id}</th>
            <td>{rentings.room_number}</td>
            <td>{rentings.start_date}</td>
            <td>{rentings.end_date}</td>
            <td>{rentings.status}</td>
            <td>{rentings.has_booked ? 'TRUE' : 'FALSE'}</td>
            <Button
                onClick={() => updateRenting(rentings.renting_id)}
                variant="warning"
            >
                Check-Out
            </Button>      
            </tr>);
    }

    return(

        <div className="down2 text-center">
            <Button
                className="mt-2"
                onClick={() => setOpen1(!open1)}
                aria-controls="example-collapse-text"
                aria-expanded={open1}
                variant="warning"
            >
                Toggle Bookings
            </Button>
            <Collapse in={open1}>
            <div className="container">
                    <div className="row"><h2 className="down2 text-center">Booking Information</h2></div>
                    <div className="row">
                        <table className="table table-striped">
                            <thead>
                                <tr>
                                    <th scope="col">Chain Name</th>
                                    <th scope="col">Room Number</th>
                                    <th scope="col">Start Date</th>
                                    <th scope="col">End Date</th>
                                    <th scope="col">Status</th>
                                    <th scope="col">Customer Email</th>
                                </tr>
                            </thead>
                            <tbody>
                                    {dataBook["bookings"].map(showBookings)}
                            </tbody>
                        </table>
                    </div>
                </div>
                
            </Collapse>
            <div>
                <Button
                    className="mt-2"
                    onClick={() => setOpen3(!open3)}
                    variant="warning"
                >
                    Toggle Rentings
                </Button>
            </div>
            <Collapse in={open3}>
            <div className="container">
                    <div className="row"><h2 className="down2 text-center">Renting Information</h2></div>
                    <div className="row">
                        <table className="table table-striped">
                            <thead>
                                <tr>
                                    <th scope="col">Hotel Id</th>
                                    <th scope="col">Room Number</th>
                                    <th scope="col">Start Date</th>
                                    <th scope="col">End Date</th>
                                    <th scope="col">Status</th>
                                    <th scope="col">Has Booked</th>
                                </tr>
                            </thead>
                            <tbody>
                                    {dataRent["rentings"].map(showRentings)}
                            </tbody>
                        </table>
                    </div>
                </div>
            </Collapse>


            <div>
                <Button
                    className="mt-2"
                    onClick={() => setOpen2(!open2)}
                    aria-controls="example-collapse-text"
                    aria-expanded={open2}
                    variant="warning"
                >
                    Toggle Customer Information
                </Button>
            </div>
            <Collapse in={open2}>
            <div className="container">
                    <div className="row"><h2 className="down2 text-center">Customer Information</h2></div>
                    <div className="row">
                        <table className="table table-striped">
                            <thead>
                                <tr>
                                    <th scope="col">Full Name</th>
                                    <th scope="col">Email</th>
                                    <th scope="col">Street Number</th>
                                    <th scope="col">Street Name</th>
                                    <th scope="col">City</th>
                                    <th scope="col">State</th>
                                </tr>
                            </thead>
                            <tbody>
                                    {dataCust["customers"].map(showCust)}
                            </tbody>
                        </table>
                    </div>
                </div>
            </Collapse>
        </div>

    );

}

export default Employee;