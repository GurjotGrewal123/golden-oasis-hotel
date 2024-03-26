import React, { useState, useEffect } from 'react';
import { Modal, Button } from 'react-bootstrap';
import { addDays } from 'date-fns'
import { DateRangePicker } from 'react-date-range';
import 'react-date-range/dist/styles.css';
import 'react-date-range/dist/theme/default.css';



function HotelModal({ show, onHide, hotel }) {
    const [rooms, setRooms] = useState([]); 
    const [date, setDate] = useState([
        {
          startDate: new Date(),
          endDate: addDays(new Date(), 7),
        },
      ])

    const [selectedRoomIndex, setSelectedRoomIndex] = useState(null);

    useEffect(() => {
        if (show && hotel) {
            fetch(`http://localhost:3001/hotel_info/room/${hotel.hotel_id}`)
                .then(response => response.json())
                .then(data => setRooms(data))
                .catch(error => console.error('Error fetching room info:', error));
        }
    }, [show, hotel]); 


    const handleToggleDatePicker = (index) => {
        if (selectedRoomIndex === index) {
            setSelectedRoomIndex(null); 
        } else {
            setSelectedRoomIndex(index);
        }
    };

    const handleBooking = async (room) => {
        try {
            const { room_number, hotel_id } = room;
    
            const bookingData = {
                status: "scheduled",
                customer_id: 1, 
                start_date: date[0].startDate, 
                end_date: date[0].endDate, 
                room_number: room_number,
                hotel_id: hotel_id
            };
    
            const response = await fetch('http://localhost:3001/bookings', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(bookingData)
            });
    
            if (response.ok) {
                const newBooking = await response.json();
                console.log('New Booking:', newBooking);
            } else {
                console.error('Failed to create booking:', response.statusText);
            }
        } catch (error) {
            console.error('Error creating booking:', error);
        }
    };
    

    return (
        <Modal show={show} onHide={onHide}>
            <Modal.Header closeButton>
                <Modal.Title>{hotel && hotel.chain_name}: Rooms</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                {rooms.map((room, index) => (
                    <div key={index}>
                        <p>Room Number: {room.room_number}</p>
                        <p>Price: {room.price}</p>
                        <p>Capacity: {room.capacity}</p>
                        {room.mountain_view && <p>Mountain View</p>}
                        {room.sea_view && <p>Sea View</p>}
                        {room.is_expandable && <p>Expandable</p>}
                        <p>Amenities: {room.amenities}</p>
                        <p>Damage: {room.damages}</p>
      
                        <Button className="mb-4" variant="primary" onClick={() => handleToggleDatePicker(index)}>Dates</Button>
                        {selectedRoomIndex === index && (
                            <div>
                            <DateRangePicker
                                onChange={(item) => {
                                    setDate([item.range1])
                                }}
                                showSelectionPreview={true}
                                moveRangeOnFirstSelection={false}
                                showDateDisplay={false}
                                months={1}
                                color="f6be00"
                                ranges={date}
                                direction="vertical"
                                inputRanges={[]}
                            />
                            <Button className="mb-1" variant="primary" onClick={() => handleBooking(room)}>Confirm</Button>
                            </div>
                        )}
                    
                        <hr />
                    </div>
                ))}
            </Modal.Body>
            <Modal.Footer>

                <Button variant="secondary" onClick={onHide}>
                    
                    Close
                </Button>
            </Modal.Footer>
        </Modal>
    );
}

export default HotelModal;
