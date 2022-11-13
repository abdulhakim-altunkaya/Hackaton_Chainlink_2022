import React from 'react';


function Upperbar() {
  const sameTab = url => {
    window.open(url, '_self', 'noopener,noreferrer');
  };

  return (
    <div id='upperbar'>
      <div id='heading' onClick={() => sameTab('https://euphonious-klepon-0acd11.netlify.app/')}> 
          <a href="https://euphonious-klepon-0acd11.netlify.app/" target="_self" rel="noopener noreferrer"> BERLIN CITY VOTING SYSTEM </a> 
      </div>
    </div> 
  )
}

export default Upperbar;