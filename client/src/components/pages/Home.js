import React from "react";
import Button from 'react-bootstrap/Button';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

function Home(){

    return(

        <Row>
            <div className="down2 text-center">
                <h1>
                    Golden Oasis Hotels
                </h1>
            </div>
            <Row>
                <div className="down text-center">
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
            </Row>
        </Row>

    );

}


export default Home;