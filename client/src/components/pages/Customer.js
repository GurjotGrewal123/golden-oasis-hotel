import React from "react";
import { useState, useEffect } from "react";
import { Button, Collapse, Modal } from 'react-bootstrap';
import HotelModal from "../subcomponents/HotelModal";


function Customer(){

    const [open, setOpen] = useState(false);
    const [hotelInfo, setHotelInfo] = useState([]);
    const [modalOpen, setModalOpen] = useState(false);
    const [selectedHotel, setSelectedHotel] = useState(null); 

    useEffect(() => {
        fetch("http://localhost:3001/hotel_info")
          .then((response) => response.json())
          .then((data) => setHotelInfo(data))
          .catch((error) => console.error('Error fetching hotel info:', error));
      }, []);

    const openModal = (hotel) => {
        setSelectedHotel(hotel); 
        setModalOpen(true); 
    };

    const closeModal = () => {
        setModalOpen(false); 
    };

    return(
        <div className="p-5">
            <div className="d-flex flex-column align-items-center justify-content-center">
                <Button
                    className="mt-5"
                    onClick={() => setOpen(!open)}
                    aria-controls="example-collapse-text"
                    aria-expanded={open}
                    variant="warning"
                >
                    Toggle Hotels
                </Button>
                </div>
        <Collapse in={open}>
        <div className="mt-3">
      {hotelInfo.map((hotel, index) => (
        <div className="card text-center" key={index}>
          <div className="card-body d-flex flex-column justify-content-center align-items-center">
            <img
              src={`https://picsum.photos/200/300?random=${index}`}
              className="card-img-top"
              alt="Random"
              style={{ maxWidth: '250px', maxHeight: '250px', objectFit: 'cover' }}
            />
            <div className="mt-3">
              <h5 className="card-title">{hotel.chain_name}</h5>
              <p>Street: {hotel.street_name}</p>
              <p>Number: {hotel.street_number}</p>
              <p>City: {hotel.city}</p>
              <p>State: {hotel.province_state}</p>
              <Button variant="warning" onClick={() => openModal(hotel)} className="btn btn-primary">View Rooms</Button>
            </div>
          </div>
        </div>
      ))}
    </div>
        </Collapse>
        <HotelModal show={modalOpen} onHide={closeModal} hotel={selectedHotel} />

        </div>

    );

}

export default Customer;