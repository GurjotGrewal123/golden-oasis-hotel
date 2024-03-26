import './App.css';
import TopNavbar from './components/subcomponents/TopNavbar';
import {BrowserRouter, Routes, Route} from 'react-router-dom';
import Home from './components/pages/Home';
import Customer from './components/pages/Customer';
import Employee from './components/pages/Employee'; 

function App() {

  return (

    <BrowserRouter>

      <div>
        <TopNavbar/>

        <Routes>
          <Route path="/" element = {<Home/>} />
          <Route path="/Customer" element = {<Customer/>} />
          <Route path="/Employee" element = {<Employee/>} />
        </Routes>
      </div>

    </BrowserRouter> 
  );
}

export default App;
