import React from "react";
import { useState, useEffect } from "react";
import { Button, Collapse} from 'react-bootstrap';


function Employee(){

    const [dataCust, setDataCust] = useState({customers:[]});
    const [dataBook, setDataBook] = useState({bookings:[]});
    const [open1, setOpen1] = useState(false);
    const [open2, setOpen2] = useState(false);

    useEffect(() => {
        fetch("http://localhost:3001/customer_info") 
        .then((response) => response.json())
        .then((data) => setDataCust({customers: data}));
    }, []);

    useEffect(() => {
        fetch("http://localhost:3001/bookings_info")
        .then((response) => response.json())
        .then((data) => setDataBook({bookings: data}));
    }, []);

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
        </tr>);
    }

    return(

        <div className="down2 text-center">
            <Button
                className="mt-2"
                onClick={() => setOpen1(!open1)}
                aria-controls="example-collapse-text"
                aria-expanded={open1}
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
                    onClick={() => setOpen2(!open2)}
                    aria-controls="example-collapse-text"
                    aria-expanded={open2}
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