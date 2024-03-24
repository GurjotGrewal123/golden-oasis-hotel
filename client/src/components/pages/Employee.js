import React from "react";
import { useState, useEffect } from "react";


function Employee(){

    const [dataCust, setDataCust] = useState({customers:[]})

    useEffect(() => {
        fetch("http://localhost:3001/customers")
        .then((response) => response.json())
        .then((dataCust) => setDataCust({customers: dataCust}));
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

    return(

        <div>
            <h1 className="down2 text-center">
                Employee View Page
            </h1>
        <div className="container">
            <div className="row"><h2 className="text-center">Customers</h2></div>
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
                        <tbody>{(dataCust["customers"]).map(showCust)}</tbody>
                    </table>
                </div>
            </div>
        </div>

    );

}

export default Employee;