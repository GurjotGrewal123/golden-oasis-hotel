import React from "react";
import Button from 'react-bootstrap/Button';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Image from 'react-bootstrap/Image';
import gold_lobby from './Images/gold_lobby.jpg';
import Card from 'react-bootstrap/Card';

function Home(){

    return(

        <Row>
            <Image src={gold_lobby} fluid />
            <div className='adjust'>
                <div className="right1 text-center">
                    <Card border="warning" style={{ position:'absolute',right:'42%', width: '14rem' ,height:'6rem'}} >
                        <Card.Body>
                            <Card.Title>Welcome To</Card.Title>
                            <Card.Title>Golden Oasis Hotels</Card.Title>
                        </Card.Body>
                    </Card>
                </div>
                
                
                <div className="down text-center" style={{position:'absolute', right:'32%'}}>
                    <Col>
                        <Button href="/Customer" variant="warning" size="lg">
                            Customer View                        
                        </Button>
                    </Col>
                    <Col className="down2">
                        <Button href="/Employee" variant="secondary" size="lg">
                            Employee View
                        </Button>
                    </Col>
                </div>
            </div>
        </Row>

    );

}


export default Home;