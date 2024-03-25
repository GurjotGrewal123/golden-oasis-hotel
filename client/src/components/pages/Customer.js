import React from "react";
import { useState, useEffect } from "react";
import Button from 'react-bootstrap/Button';
import Collapse from 'react-bootstrap/Collapse';

function Customer(){

    const [open, setOpen] = useState(false);
    const [hotelInfo, setHotelInfo] = useState([]);

    useEffect(() => {
        fetch("http://localhost:3001/hotel_info")
          .then((response) => response.json())
          .then((data) => setHotelInfo(data))
          .catch((error) => console.error('Error fetching hotel info:', error));
      }, []);


    return(
        <div className="p-5">
            <div className="d-flex flex-column align-items-center justify-content-center">
                <div className="mt-5 text-center">Book from the hotels below</div>
                <Button
                    className="mt-2"
                    onClick={() => setOpen(!open)}
                    aria-controls="example-collapse-text"
                    aria-expanded={open}
                >
                    Collapse
                </Button>
                </div>
        <Collapse in={open}>
            <div className="mt-3">
                    {hotelInfo.map((hotel, index) => (
                        <div key={index}>
                        <h2>{hotel.chain_name}</h2>
                        <p>Street: {hotel.street_name}</p>
                        <p>Number: {hotel.street_number}</p>
                        <p>City: {hotel.city}</p>
                        <p>State: {hotel.province_state}</p>
                        </div>
                    ))}
                </div>
        </Collapse>

        </div>

    );

}

export default Customer;