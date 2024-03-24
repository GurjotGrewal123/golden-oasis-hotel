import './App.css';
import TopNavbar from './components/TopNavbar';
import {BrowserRouter, Routes, Route} from 'react-router-dom';
import Home from './components/pages/Home';

function App() {
  return (

    <BrowserRouter>

      <div>
        <TopNavbar/>

        <Routes>
          <Route path="/" element = {<Home/>} />
        </Routes>
      </div>

    </BrowserRouter> 
  );
}

export default App;
